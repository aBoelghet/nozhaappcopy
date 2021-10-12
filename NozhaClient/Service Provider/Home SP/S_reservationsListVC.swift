//
//  S_reservationsListVC.swift
//  NozhaClient
//
//  Created by macbook on 24/03/2021.
//

import UIKit

class S_reservationsListVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    var refreshControl :UIRefreshControl = UIRefreshControl()
    var reservationss :[Reservation]?
   
    
    var paginate:Paginate?
    var paginateCompeted:Paginate?
    var isLoadMore = false
    var isToday:Bool?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
        startRequestGetReservations()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    @objc func refreshData(){
        isLoadMore = false
        refreshControl.beginRefreshing()
        startRequestGetReservations()
        
    }

    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    
    
    
}


extension S_reservationsListVC: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
            return reservationss?.count ?? 2
        
    }
   
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
            let cell: BookingTVC = tableView.dequeueReusableCell(withIdentifier: "BookingTVC", for: indexPath) as! BookingTVC
            if reservationss?.count ?? 0 > 0 {
                cell.setupReservation(res:(self.reservationss?[indexPath.row])!)
                cell.viewcontroller_ALLReservatioons = self
            }
            return cell
       
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc :ReservationDetailsVC = mainStoryboard.instanceVC()
        vc.reservationId = self.reservationss?[indexPath.row].id
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


//for load more
extension S_reservationsListVC {
    
    func startRequestGetReservations(){
        
        self.emptyView.visibility = .invisible
        var params = [String:Any]()
        params["type"] = isToday ?? false  ? "today" : "all"
        API.SP_ALLRESERVATIONS.startRequest(showIndicator: true, params: params) { (api, statusResult) in
            self.refreshControl.endRefreshing()
            
            
            if statusResult.isSuccess {
                let value = statusResult.data  as! [String:Any]
                
                let ordersData = try! JSONSerialization.data(withJSONObject:value["items"]!, options: .prettyPrinted)
                self.reservationss?.removeAll()
                self.reservationss = try! JSONDecoder().decode([Reservation].self, from: ordersData)
                let paging_data = try! JSONSerialization.data(withJSONObject: value["paginate"]!, options: [])
                let paging = try! JSONDecoder().decode(Paginate.self, from: paging_data)
                self.paginate = paging
                
                self.tableView.reloadData()
                
                if self.reservationss?.count ?? 0 > 0  {
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
            if  (paginate?.currentPage ?? 1 < paginate?.lastPage ?? 1){
                loadMoreDataFromServer()
            }
        }
    }
    
    
    func loadMoreDataFromServer()
    { if !isLoadMore {
        isLoadMore.toggle()
        
        var params = [String:Any]()
        let page  = ((paginate?.currentPage ?? 1) + 1)
        params["page"] = "\(page)"
        params["type"] = isToday ?? false  ? "today" : "all"
        if NozhaUtility.isLogin() {
            API.SP_ALLRESERVATIONS.startRequest(showIndicator: false,params: params,completion: responseLoadMore)
        }
    }
    
    }
   
    
    
    func responseLoadMore(api :API,statusResult :StatusResult){
        if statusResult.isSuccess {
            isLoadMore.toggle()
            let value = statusResult.data as! [String:Any]
            
            let ordersData = try! JSONSerialization.data(withJSONObject:value["items"]!, options: .prettyPrinted)
            let orders = try! JSONDecoder().decode([Reservation].self, from: ordersData)
            
            let paging_data = try! JSONSerialization.data(withJSONObject: value["paginate"]!, options: [])
            let paging = try! JSONDecoder().decode(Paginate.self, from: paging_data)
            self.paginate = paging
            if !orders.isEmpty {
                self.reservationss! += orders
                
            }
            if (paginate?.currentPage ?? 1 == paginate?.lastPage ?? 1){
                isLoadMore = true
            }
            self.tableView.reloadData()
        }else{
            print(statusResult.message)
        }
    }
    
  
    
}

