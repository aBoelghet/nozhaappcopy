//
//  C_ReservationsListVC.swift
//  NozhaClient
//
//  Created by macbook on 19/02/2021.
//

import UIKit
import Segmentio
class C_ReservationsListVC: UIViewController {
    @IBOutlet weak var segmentioView: Segmentio!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    var refreshControl :UIRefreshControl = UIRefreshControl()
    var completedOrders :[Reservation]?
    var newOrders :[Reservation]?
    
    var paginate:Paginate?
    var paginateCompeted:Paginate?
    var isLoadMore = false
    var isCurrent:Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSegmento()
        refreshControl.addTarget(self, action: #selector(refreshData), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
        startRequestGetNewOrders()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
      
    }
    @objc func refreshData(){
        isLoadMore = false
        refreshControl.beginRefreshing()
        if isCurrent {
            
            if NozhaUtility.isLogin() {
                startRequestGetNewOrders()
            }
        }else {
            
            if NozhaUtility.isLogin() {
                startRequestGetCompletedOrders()
            }
        }
        
    }
    
    func initSegmento(){
        
        let segmentState = SegmentioStates(
            defaultState: SegmentioState(
                backgroundColor: .clear,
                titleFont: Constants.appFont14Regular,
                titleTextColor: Constants.gray_main_color
            ),
            selectedState: SegmentioState(
                backgroundColor: .clear,
                titleFont:Constants.appFont14Regular,
                titleTextColor: Constants.black_main_color
            ),
            highlightedState: SegmentioState(
                backgroundColor: .clear,
                titleFont:Constants.appFont14Regular,
                titleTextColor: Constants.black_main_color
            )
        )
        
        
        let segmentioIndicatorOptions = SegmentioIndicatorOptions(type: .bottom, ratio: 1, height: 2, color: Constants.black_main_color)
        
        let horizontalSeparatorOptions  = SegmentioHorizontalSeparatorOptions(type: .none, height: 0, color: .clear)
        let verticalSeparatorOptions = SegmentioVerticalSeparatorOptions(ratio: 0, color: .clear)
        
        let options = SegmentioOptions(
            backgroundColor:.white,
            segmentPosition: SegmentioPosition.fixed(maxVisibleItems: 5),
            scrollEnabled: false,
            indicatorOptions: segmentioIndicatorOptions,
            horizontalSeparatorOptions: horizontalSeparatorOptions,
            verticalSeparatorOptions: verticalSeparatorOptions,
            labelTextAlignment: .center,
            segmentStates: segmentState
        )
        
        
        let item1 = SegmentioItem(
            title: "Current Reservations".localized, image: nil
        )
        
        let item2 = SegmentioItem(
            title: "Previous Reservations".localized, image: nil
        )
        
        
        segmentioView.setup(
            content: [item1 ,item2],
            style: SegmentioStyle.onlyLabel,
            options: options
        )
        
        
        segmentioView.selectedSegmentioIndex = 0
        segmentioView.layer.borderColor = UIColor.white.cgColor
        
        
        
        segmentioView.valueDidChange = { [weak self] _, segmentIndex in
            
            self!.isCurrent = segmentIndex == 0
            if segmentIndex == 0 {
                
                if NozhaUtility.isLogin() {
                    self?.startRequestGetNewOrders()
                }
            }else{
                if NozhaUtility.isLogin() {
                    self?.startRequestGetCompletedOrders()
                }
            }
            self?.tableView.reloadData()
        }
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    
    
    
}


extension C_ReservationsListVC: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isCurrent  {
            return newOrders?.count ?? 2
        }else {
            return completedOrders?.count ?? 2
        }
    }
    //    func nextStoreRated(order:Order) {
    //        let mainStoryboard = UIStoryboard(name: "Order", bundle: nil)
    //        let vc :rateProductsVC = mainStoryboard.instanceVC()
    //        vc.order = order
    //        vc.delegate = self
    //        self.present(vc, animated: true, completion: nil)
    //
    //    }
    //
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isCurrent {
            let cell: C_ReservationTVC = tableView.dequeueReusableCell(withIdentifier: "C_ReservationTVC", for: indexPath) as! C_ReservationTVC
            if newOrders?.count ?? 0 > 0 {
                cell.reservation = self.newOrders?[indexPath.row]
                cell.reserListVC = self
            }
            return cell
        }else {
            let cell: C_ReservationTVC = tableView.dequeueReusableCell(withIdentifier: "C_ReservationTVC", for: indexPath) as! C_ReservationTVC
            if completedOrders?.count ?? 0 > 0 {
                cell.reservation = self.completedOrders?[indexPath.row]
                cell.reserListVC = self
            }
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
       
    }
}


//for load more
extension C_ReservationsListVC {
    
    func startRequestGetNewOrders(){
        
        self.emptyView.visibility = .invisible
        var params = [String:Any]()
        params["filter"] = "current"
        API.C_RESERVATIONS.startRequest(showIndicator: true, params: params) { (api, statusResult) in
            self.refreshControl.endRefreshing()
          
            
            if statusResult.isSuccess {
                let value = statusResult.data  as! [String:Any]
                
                let ordersData = try! JSONSerialization.data(withJSONObject:value["items"]!, options: .prettyPrinted)
                self.newOrders?.removeAll()
                self.newOrders = try! JSONDecoder().decode([Reservation].self, from: ordersData)
                let paging_data = try! JSONSerialization.data(withJSONObject: value["paginate"]!, options: [])
                let paging = try! JSONDecoder().decode(Paginate.self, from: paging_data)
                self.paginate = paging
                
                self.tableView.reloadData()
                
                if self.newOrders?.count ?? 0 > 0  {
                    self.emptyView.visibility = .invisible
                }else{
                    self.emptyView.visibility = .visible
                }
                
            }else{
                self.showOkAlert(title: "", message: statusResult.message)
            }
        }
    }
    
    func startRequestGetCompletedOrders(){
        if completedOrders?.count ?? 0 == 0 && completedOrders != nil {
            self.emptyView.visibility = .visible
        }else {
            self.emptyView.visibility = .invisible
        }
        var params = [String:Any]()
        params["filter"] = "previous"
        API.C_RESERVATIONS.startRequest(showIndicator: true, params: params) { (api, statusResult) in
            self.refreshControl.endRefreshing()
           
            if statusResult.isSuccess {
                let value = statusResult.data  as! [String:Any]
                
                let ordersData = try! JSONSerialization.data(withJSONObject:value["items"]!, options: .prettyPrinted)
                self.completedOrders?.removeAll()
                self.completedOrders = try! JSONDecoder().decode([Reservation].self, from: ordersData)
                let paging_data = try! JSONSerialization.data(withJSONObject: value["paginate"]!, options: [])
                let paging = try! JSONDecoder().decode(Paginate.self, from: paging_data)
                self.paginateCompeted = paging
                
                self.tableView.reloadData()
                
                if self.completedOrders?.count ?? 0 > 0  {
                    self.emptyView.visibility = .invisible
                }else{
                    self.emptyView.visibility = .visible
                }
            }else{
                self.showOkAlert(title: "", message: statusResult.message)
            }
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if (offsetY + 180)  > contentHeight - scrollView.frame.size.height {
            if isCurrent   &&   (paginate?.currentPage ?? 1 < paginate?.lastPage ?? 1){
                loadMoreDataFromServerNewOrders()
            }else if  (paginateCompeted?.currentPage ?? 1 < paginateCompeted?.lastPage ?? 1)  {
                loadMoreDataFromServerCompletedOrders()
            }
        }
    }
    
    
    func loadMoreDataFromServerNewOrders()
    { if !isLoadMore {
        isLoadMore.toggle()
       
        var params = [String:Any]()
        let page  = ((paginate?.currentPage ?? 1) + 1)
        params["page"] = "\(page)"
        params["filter"] = "current"
        if NozhaUtility.isLogin() {
            API.C_RESERVATIONS.startRequest(showIndicator: false,params: params,completion: responseLoadMoreNewOrders)
        }
    }
    
    }
    func loadMoreDataFromServerCompletedOrders(){
        if !isLoadMore {
            isLoadMore.toggle()
           
            var params = [String:Any]()
            let page  = ((paginateCompeted?.currentPage ?? 1) + 1)
            params["page"] = "\(page)"
            params["filter"] = "previous"
           
            if NozhaUtility.isLogin() {
                API.C_RESERVATIONS.startRequest(showIndicator: false,params: params,completion: responseLoadMoreCompletedOrders)
            }
        }
    }
    
    
    func responseLoadMoreNewOrders(api :API,statusResult :StatusResult){
        if statusResult.isSuccess {
            isLoadMore.toggle()
            let value = statusResult.data as! [String:Any]
            
            let ordersData = try! JSONSerialization.data(withJSONObject:value["items"]!, options: .prettyPrinted)
            let orders = try! JSONDecoder().decode([Reservation].self, from: ordersData)
            
            let paging_data = try! JSONSerialization.data(withJSONObject: value["paginate"]!, options: [])
            let paging = try! JSONDecoder().decode(Paginate.self, from: paging_data)
            self.paginate = paging
            if !orders.isEmpty {
                self.newOrders! += orders
                
            }
            if (paginate?.currentPage ?? 1 == paginate?.lastPage ?? 1){
                isLoadMore = true
            }
            self.tableView.reloadData()
        }else{
            print(statusResult.message)
        }
    }
    
    func responseLoadMoreCompletedOrders(api :API,statusResult :StatusResult){
        if statusResult.isSuccess {
            isLoadMore.toggle()
            let value = statusResult.data as! [String:Any]
            
            let ordersData = try! JSONSerialization.data(withJSONObject:value["items"]!, options: .prettyPrinted)
            let orders = try! JSONDecoder().decode([Reservation].self, from: ordersData)
            let paging_data = try! JSONSerialization.data(withJSONObject: value["paginate"]!, options: [])
            let paging = try! JSONDecoder().decode(Paginate.self, from: paging_data)
            self.paginateCompeted = paging
            
            if !orders.isEmpty {
                self.completedOrders! += orders
            }
            if (paginateCompeted?.currentPage ?? 1 == paginateCompeted?.lastPage ?? 1){
                isLoadMore = true
            }
            self.tableView.reloadData()
        }else{
            print(statusResult.message)
        }
    }
    
}

