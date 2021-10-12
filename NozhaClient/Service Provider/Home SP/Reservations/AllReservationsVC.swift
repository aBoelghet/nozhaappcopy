//
//  AllReservationsVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/16/21.
//

import UIKit
import IBAnimatable


class AllReservationsVC: UIViewController {
    
   
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTF: AnimatableTextField!
    var reservations:[Reservation]?
    var reservationInfo:ReservationInfo?
 
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
    
    @IBAction func searchAction(_ sender: Any) {
        startReqestGetReservations()
    }
    
    @IBAction func scanCodeAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : ScanQrVC = mainStoryboard.instanceVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    
}

extension AllReservationsVC: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return reservations?.count ?? 4
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CurrentReservationTVC = tableView.dequeueReusableCell(withIdentifier: "CurrentReservationTVC", for: indexPath) as! CurrentReservationTVC
        cell.vc_AllReservationsVC = self
        if reservations?.count ?? 0 > 0 {
            cell.reservation = self.reservations?[indexPath.row]
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if self.reservations?.count ?? 0 > 0 {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc :ReservationDetailsVC = mainStoryboard.instanceVC()
        if self.reservations?.count ?? 0 > 0 {
            vc.reservation = self.reservations?[indexPath.row]
        }
        self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
}


extension AllReservationsVC {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if (offsetY + 180)  > contentHeight - scrollView.frame.size.height {
            loadMoreDataFromServer()
        }
    }
    func startReqestGetReservations()
    {
        var params = [String:String]()
        params["service_id"] = reservationInfo?.serviceId?.description
        params["search"] = self.searchTF.text ?? ""
        params["status"] = self.reservationInfo?.status
        params["service_time_id"] = self.reservationInfo?.service_time?.id?.description
        
        
        API.GROUP_RESERVATIONS.startRequest(params: params,completion: response)
    }
    
    func response(api :API,statusResult :StatusResult){
        self.hideIndicator()
        refreshControl.endRefreshing()
        if statusResult.isSuccess {
            
            if !(statusResult.data is NSNull)
            {
                let value = statusResult.data as! [String:Any]
                if !(value["items"] is NSNull) {
                    let data_reservations = try! JSONSerialization.data(withJSONObject: value["items"]!, options: [])
                    let reservations = try! JSONDecoder().decode([Reservation].self, from: data_reservations)
                    self.reservations?.removeAll()
                    self.reservations = reservations
                
                    if self.reservations?.count ?? 0 > 0 {
                        self.emptyView.isHidden = true
                        self.tableView.reloadData()
                    }else {
                        self.emptyView.isHidden = false
                    }
                    
                    let paging_data = try! JSONSerialization.data(withJSONObject: value["paginate"]!, options: [])
                    let paging = try! JSONDecoder().decode(Paginate.self, from: paging_data)
                    self.paginate = paging
                    
                }
                
            }else{
                self.showOkAlert(title: "", message: statusResult.message)
            }
        }
        
    }
    func loadMoreDataFromServer(){
        if !isLoadMore {
            isLoadMore.toggle()
            var params = [String:Any]()
            params["service_id"] = reservationInfo?.serviceId?.description
            params["search"] = self.searchTF.text ?? ""
            params["status"] = self.reservationInfo?.status
            params["service_time_id"] = self.reservationInfo?.service_time?.id?.description
            
            let page  = ((paginate?.currentPage ?? 1) + 1)
            params["page"] = "\(page)"
            API.GROUP_RESERVATIONS.startRequest(params: params,completion: responseLoadMore)
        }
    }
    func responseLoadMore(api :API,response :StatusResult){
        
        if response.isSuccess {
            isLoadMore.toggle()
            let value = response.data as! [String:Any]
            let data_reservations = try! JSONSerialization.data(withJSONObject: value["items"]!, options: [])
            let reservations = try! JSONDecoder().decode([Reservation].self, from: data_reservations)
        
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

extension AllReservationsVC: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       
        if string == "\n" {
            startReqestGetReservations()
            }
        
        
        return true
    }
    
}
