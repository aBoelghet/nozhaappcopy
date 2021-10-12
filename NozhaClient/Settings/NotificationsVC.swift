//
//  NotificationsVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/16/21.
//

import UIKit

class NotificationsVC: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var emptyView : UIView!
    
    
    var notfications :[Notification]?
    var refreshControl :UIRefreshControl = UIRefreshControl()
    var isLoadMore = false
    var paginate:Paginate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
        tableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if NozhaUtility.isLogin() {
            startRequestGetUserNotfications()
        }
    }
    
    @objc func refreshData(){
        
        isLoadMore = false
        
        
        if NozhaUtility.isLogin() {
            refreshControl.beginRefreshing()
            startRequestGetUserNotfications()
        }
        
    }
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    
    func startRequestGetUserNotfications(){
        API.ALL_NOTIFICATIONS.startRequest(showIndicator: true) { (api, statusResult) in
            self.refreshControl.endRefreshing()
            
            
            if statusResult.isSuccess {
                let value = statusResult.data  as! [String:Any]
                
                let notficationData = try! JSONSerialization.data(withJSONObject:value["items"]!, options: .prettyPrinted)
                self.notfications?.removeAll()
                self.notfications = try! JSONDecoder().decode([Notification].self, from: notficationData)
                
                let badge = value["unread_notifications"] as! Int
                
                NozhaUtility.setNotificationNo(notifcation_number:badge)
                UIApplication.shared.applicationIconBadgeNumber = badge
                let BadgeInfo = ["badge": badge ] as [String : Any]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateNotificationNumber"), object: self, userInfo: BadgeInfo)
                
                
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    if self.notfications?.isEmpty ?? false {
                        self.emptyView.isHidden = false
                    }else{
                        self.emptyView.isHidden = true
                    }
                    self.tableView.reloadData()
                }
            }else{
                self.showOkAlert(title: "", message: statusResult.message)
            }
        }
    }
    
    
    
    
}

extension NotificationsVC: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notfications?.count ?? 10
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: NotificationTVC = tableView.dequeueReusableCell(withIdentifier: "NotificationTVC", for: indexPath) as! NotificationTVC
        if notfications != nil {
            cell.notification = self.notfications?[indexPath.row]
            cell.deleteBtn.tag  = indexPath.row;
            cell.viewController = self
        }
        return cell
        
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
        
    }
    
    
}



extension NotificationsVC {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if (offsetY + 180)  > contentHeight - scrollView.frame.size.height {
            loadMoreDataFromServer()
        }
    }
    
    
    func loadMoreDataFromServer(){
        if !isLoadMore {
            isLoadMore.toggle()
            var params = [String:Any]()
            let page  = ((paginate?.currentPage ?? 1) + 1)
            params["page"] = "\(page)"
            if NozhaUtility.isLogin() {
                API.ALL_NOTIFICATIONS.startRequest(showIndicator: false,params: params,completion: responseLoadMore)
            }
        }
    }
    
    
    func responseLoadMore(api :API,statusResult :StatusResult){
        if statusResult.isSuccess {
            
            isLoadMore.toggle()
            
            let value = statusResult.data as! [String:Any]
            let notficationData = try! JSONSerialization.data(withJSONObject:value["items"]!, options: .prettyPrinted)
            let notfications = try! JSONDecoder().decode([Notification].self, from: notficationData)
            if !notfications.isEmpty {
                self.notfications! += notfications
                
            }
            let badge = value["unread_notifications"] as! Int
            NozhaUtility.setNotificationNo(notifcation_number:badge)
            UIApplication.shared.applicationIconBadgeNumber = badge
            let BadgeInfo = ["badge": badge ] as [String : Any]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateNotificationNumber"), object: self, userInfo: BadgeInfo)
            
            
            let paging_data = try! JSONSerialization.data(withJSONObject: value["paginate"]!, options: [])
            let paging = try! JSONDecoder().decode(Paginate.self, from: paging_data)
            self.paginate = paging
            if (paginate?.currentPage ?? 1 == paginate?.lastPage ?? 1){
                isLoadMore = true
            }
            
            self.tableView.reloadData()
        }else{
            print(statusResult.message)
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let notification = notfications?[indexPath.row]
        
        if NozhaUtility.isLogin() {
            if !(notification?.seen ?? false) {
                
                API.SET_NOTIFICATION.startRequest(nestedParams:notification?.id ?? ""){(api, statusResult) in
                    let value = statusResult.data as! [String:Any]
                    let badge =  value["unread_notifications"] as! Int
                    NozhaUtility.setNotificationNo(notifcation_number: badge)
                    UIApplication.shared.applicationIconBadgeNumber = badge
                    let BadgeInfo = ["badge": badge ] as [String : Any]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateNotificationNumber"), object: self, userInfo: BadgeInfo)
                    tableView.reloadData()
                }
            }
            
            let type = self.notfications?[indexPath.row].type ?? ""
            if type.contains("RateReservation") {
                gotoReviews()
            }else if type.contains("Reservation") {
                goToReservation(reservationId : notification?.others?.id ?? 0  )
            }
            if type.contains("Service") {
                goToServiceDetails(serviceId : notification?.others?.id ?? 0  )
            }
            
            
            
        }
        
    }
    
    
    func goToReservation(reservationId: Int){
        if reservationId != 0 {
            if NozhaUtility.isCustomer() {
                let mainStoryboard = UIStoryboard(name: "CMain", bundle: nil)
                let vc :C_ReservationDetailsVC = mainStoryboard.instanceVC()
                vc.reservationId = reservationId
                self.navigationController?.pushViewController(vc, animated: true)
            }else {
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc :ReservationDetailsVC = mainStoryboard.instanceVC()
                vc.reservationId = reservationId
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    func gotoReviews(){
        if !NozhaUtility.isCustomer() && NozhaUtility.isLogin() {
            
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc :ReviewsList = mainStoryboard.instanceVC()
                self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func goToServiceDetails(serviceId: Int){
        if serviceId != 0 {
            
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc :ServiceDetailsVC = mainStoryboard.instanceVC()
            vc.serviceId = serviceId
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    
}



