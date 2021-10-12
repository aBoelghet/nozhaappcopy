//
//  UserTabVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/19/21.
//

import UIKit

class CTabVC: UIViewController {

    var selectedIndex: Int = 0
    var previousIndex: Int = 0
    
    var viewControllers = [UIViewController]()
    
    @IBOutlet var nameLbl: [UILabel]!
    @IBOutlet var iconImgV: [UIImageView]!
    @IBOutlet var buttons:[UIButton]!
    @IBOutlet var tabView:UIView!
    var footerHeight: CGFloat = 50
    
    static let HomeVC = UIStoryboard(name: "CMain", bundle: nil).instantiateViewController(withIdentifier: "CHomeVC")
    static let FavouriteVC = UIStoryboard(name: "CMain", bundle: nil).instantiateViewController(withIdentifier: "CFavouriteVC")
    static let ProfileVC = UIStoryboard(name: "CMain", bundle: nil).instantiateViewController(withIdentifier: "CProfileVC")
   
 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers.append(CTabVC.HomeVC)
        viewControllers.append(CTabVC.FavouriteVC)
        viewControllers.append(CTabVC.ProfileVC)
       
        
        buttons[selectedIndex].isSelected = true
        tabChanged(sender: buttons[selectedIndex])
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "handelNotification"), object: nil, queue: nil) { (notification) in
            if (notification.userInfo as? [String: Any]) != nil
            {
                
                let order_id = notification.userInfo?["id"] as? Int
                let notification_id = notification.userInfo?["notification_id"] as? String
                let uuid = notification.userInfo?["uuid"] as? String
                let type = notification.userInfo?["type"] as? String
                
                if self.presentedViewController != nil {
                    self.presentedViewController?.dismiss(animated: false){
                        self.handelNotification(id:order_id ?? 0, notification_id:notification_id ?? "" , uuid:uuid ?? "",type:type ?? "")
                        
                    }
                    
                }else{
                    self.handelNotification(id:order_id ?? 0, notification_id:notification_id ?? "", uuid:uuid ?? "",type:type ?? "" )
                    
                }
            }
            
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "ServiceDetailsNotification"), object: nil, queue: nil) { (notification) in
            if (notification.userInfo as? [String: Any]) != nil
            {
                print("user info \(notification.userInfo ?? [:])")
                let id_dic = notification.userInfo?["id"] as? [String: Any]
                let supplier_dic = notification.userInfo?["supplier"]  as? [String: Any]
                let service_id = id_dic?["id"] as? Int
                let supplier_id = supplier_dic?["supplier"] as? Int
                print("Service id  22 \(service_id ?? 0)")
                print("supplier id  22 \(supplier_id ?? 0)")
                self.goToServices(serviceId: service_id ?? 0)
            }}
      
    }
    
    func handelNotification(id:Int,notification_id:String,uuid:String,type:String){
        
        if NozhaUtility.isLogin() {
            
            API.SET_NOTIFICATION.startRequest(nestedParams:notification_id){(api, statusResult) in
                let value = statusResult.data as! [String:Any]
                let badge =  value["unread_notifications"] as! Int
                NozhaUtility.setNotificationNo(notifcation_number:badge )
                UIApplication.shared.applicationIconBadgeNumber = badge
                let BadgeInfo = ["badge": badge ] as [String : Any]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateNotificationNumber"), object: self, userInfo: BadgeInfo)
            }
            if type.contains("Service") {
                goToServices(serviceId: id)
            }
            if type.contains("Reservation") {
            goToOrder(orderId :id )
            }
        }
    }
  
    func goToOrder(orderId: Int){
        
        if  NozhaUtility.isCustomer() {
           
                let mainStoryboard = UIStoryboard(name: "CMain", bundle: nil)
                let vc :C_ReservationDetailsVC = mainStoryboard.instanceVC()
                vc.reservationId = orderId
                
                self.navigationController?.pushViewController(vc, animated: true)
        
}
    }
    func goToServices(serviceId: Int){
        
        if serviceId != 0 {
           
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc :ServiceDetailsVC = mainStoryboard.instanceVC()
                vc.serviceId = serviceId
                self.navigationController?.pushViewController(vc, animated: true)
        
}
        
    }

    @IBAction func tabChanged(sender:UIButton) {
        previousIndex = selectedIndex
        selectedIndex = sender.tag
        
        for icon in iconImgV {
            if icon.tag == sender.tag {
                icon.tintColor = Constants.tab_select
            }else {
                icon.tintColor = Constants.tab_unselect
            }
        }
        for name in nameLbl {
            if name.tag == sender.tag {
                name.textColor = Constants.tab_select
            }else {
                name.textColor  = Constants.tab_unselect
            }
        }
        
        buttons[previousIndex].isSelected = false
        let previousVC = viewControllers[previousIndex]
        
        previousVC.willMove(toParent: nil)
        previousVC.view.removeFromSuperview()
        previousVC.removeFromParent()
        
        sender.isSelected = true
        
        let vc = viewControllers[selectedIndex]
        vc.view.frame = UIApplication.shared.windows[0].frame
        vc.didMove(toParent: self)
        self.addChild(vc)
        self.view.addSubview(vc.view)
        
        self.view.bringSubviewToFront(tabView)
    }
}

