//
//  NotificationTVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/16/21.
//

import UIKit
import IBAnimatable
import SkeletonView

class NotificationTVC: UITableViewCell {

    
    @IBOutlet var mainSkelton: UIView!
    @IBOutlet var skeltonableViews: [UIView]!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var iconImgV: AnimatableImageView!
    @IBOutlet weak var msgLbl: UILabel!
    @IBOutlet weak var createdLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet var isReadImgV: UIImageView!
    var viewController: NotificationsVC!
    var notification:Notification?{
        didSet{
            titleLbl.text = notification?.title ?? ""
            createdLbl.text = notification?.createdAt ?? ""
            msgLbl.text =  notification?.message ?? ""
            let type = self.notification?.type ?? ""
            if type.contains("Reservation") {
                self.iconImgV.image = UIImage(named: "ic_notif_order")
            }else  {
                self.iconImgV.image = UIImage(named: "ic_general_notif")
            }
            if notification?.seen ?? false {
                isReadImgV.isHidden = true
            }else {
                isReadImgV.isHidden = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                
                self.mainSkelton.isHidden = true
                for skelton_view  in self.skeltonableViews {
                    skelton_view.hideSkeleton()
                }
            }
 
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.mainSkelton.isHidden = false
        let gradient = SkeletonGradient(baseColor: UIColor.clouds)
        let animationType = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
        for skelton_view  in skeltonableViews {
            
            skelton_view.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animationType)
        }
    }
    @IBAction func deleteAction(_ sender: UIButton) {
        
        
        self.parentContainerViewController()?.showCustomAlert(title: "Attention".localized, message: "Are you sure want to delete this notification ?".localized, okTitle: "Yes".localized, cancelTitle: "No".localized){ (result) in
            if result {
                
                API.DELETE_NOTIFICATION.startRequest(showIndicator: true,nestedParams:self.notification?.id?.description ?? "") { (api, statusResult) in
            
            if statusResult.isSuccess {
                self.viewController.notfications?.remove(at: sender.tag)
                self.viewController.tableView.deleteRows(at: [IndexPath(row: sender.tag, section: 0)], with:.fade)
             
                let value = statusResult.data as! [String:Any]
                let badge =  value["unread_notifications"] as! Int
                NozhaUtility.setNotificationNo(notifcation_number: badge)
                UIApplication.shared.applicationIconBadgeNumber = badge
                let BadgeInfo = ["badge": badge ] as [String : Any]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateNotificationNumber"), object: self, userInfo: BadgeInfo)
              
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    if self.viewController.notfications?.isEmpty ?? false {
                        self.viewController.emptyView.isHidden = false
                    }else{
                        self.viewController.emptyView.isHidden = true
                    }
                    self.viewController.tableView.reloadData()
                }
            }else{
                self.parentContainerViewController()?.showOkAlert(title: "", message: statusResult.message)
            }
        }
    }
}
    }
    
 
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
