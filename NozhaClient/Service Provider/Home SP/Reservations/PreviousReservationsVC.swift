//
//  PreviousReservationsVC.swift
//  NozhaClient
//
//  Created by mac book air on 2/8/21.
//

import UIKit

class PreviousReservationsVC: UIViewController {
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var reservations:[ReservationInfo]?
    var serviceId:Int?
    var paginate:Paginate?
    var isLoadMore = false
    var refreshControl :UIRefreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.addTarget(self, action: #selector(refreshData), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
        startReqestGetReservations()
    }
    
    
    @objc func refreshData(){
        isLoadMore = false
        refreshControl.beginRefreshing()
        startReqestGetReservations()
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
}


extension PreviousReservationsVC: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.reservations?.count ?? 5
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ReserveTVC = tableView.dequeueReusableCell(withIdentifier: "ReserveTVC", for: indexPath) as! ReserveTVC
        if self.reservations?.count ?? 0 > 0 {
            self.reservations?[indexPath.row].status = "previous"
            cell.res = self.reservations?[indexPath.row]
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 330
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
    }
    
}

extension PreviousReservationsVC {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if (offsetY + 180)  > contentHeight - scrollView.frame.size.height {
            loadMoreDataFromServer()
        }
    }
    
    func startReqestGetReservations()
    {
        
        API.SP_PREVIOUS_RESERVATIONS.startRequest(nestedParams: self.serviceId?.description ?? "", completion: response)
    }
    
    func response(api :API,statusResult :StatusResult){
        self.hideIndicator()
        
        if statusResult.isSuccess {
            
            
            let value = statusResult.data as! [String:Any]
            let data_reservations = try! JSONSerialization.data(withJSONObject: value["items"]!, options: [])
            let reservations = try! JSONDecoder().decode([ReservationInfo].self, from: data_reservations)
            self.reservations?.removeAll()
            self.reservations = reservations
            
            let paging_data = try! JSONSerialization.data(withJSONObject: value["paginate"]!, options: [])
            let paging = try! JSONDecoder().decode(Paginate.self, from: paging_data)
            self.paginate = paging
            
            
            if self.reservations?.count ?? 0 > 0 {
                self.emptyView.isHidden = true
                self.tableView.reloadData()
            }else {
                self.emptyView.isHidden = false
            }
            
            
        }else{
            self.showOkAlert(title: "", message: statusResult.message)
        }
    }
    func loadMoreDataFromServer(){
        if !isLoadMore {
            isLoadMore.toggle()
            var params = [String:Any]()
            let page  = ((paginate?.currentPage ?? 1) + 1)
            params["page"] = "\(page)"
            API.SP_PREVIOUS_RESERVATIONS.startRequest(nestedParams: self.serviceId?.description ?? "", params:params, completion: responseLoadMore)
        }
    }
    func responseLoadMore(api :API,response :StatusResult){
        
        if response.isSuccess {
            isLoadMore.toggle()
            
            let value = response.data as! [String:Any]
            let data_reservations = try! JSONSerialization.data(withJSONObject: value["items"]!, options: [])
            let reservations = try! JSONDecoder().decode([ReservationInfo].self, from: data_reservations)
        
            if !reservations.isEmpty {
                self.reservations! += reservations
            }
            let paging_data = try! JSONSerialization.data(withJSONObject: value["paginate"]!, options: [])
            let paging = try! JSONDecoder().decode(Paginate.self, from: paging_data)
            self.paginate = paging
            if (paginate?.currentPage ?? 1 == paginate?.lastPage ?? 1){
                isLoadMore = true
            }
            
            
            self.tableView.reloadData()
        }else{
            print(response.message)
        }
    }
}




