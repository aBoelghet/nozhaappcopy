//
//  ViewControllerExtention.swift
//  tamween
//
//  Created by Heba lubbad on 7/13/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import Foundation
import Foundation
import UIKit
import PopupDialog
import SVProgressHUD
import SystemConfiguration
import SwiftMessages
import AudioToolbox
import DropDown
import CoreData
import Firebase
import FirebaseInstanceID
import FirebaseMessaging

import MOLH



extension UIViewController  {
    
    enum Validation{
        case valid
        case invalid(String)
    }
  
    func showOkAlertLagacy(title :String, message :String,completion:@escaping (Bool) -> Void){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "Ok".localized, style: UIAlertAction.Style.default) { (UIAlertAction) in
            
            completion(true)
        }
        
        
        alert.addAction(okAction)
        //canPerformAction;
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
    func showBunnerAlert(title:String,message:String, completion:(() -> Void)? = nil)
    {
        let Errorview = MessageView.viewFromNib(layout: .cardView)
        Errorview.configureTheme(.error)
        Errorview.button?.isHidden = true
        Errorview.titleLabel?.isHidden = true
        Errorview.titleLabel?.font = Constants.appFont11Regular
        Errorview.bodyLabel?.font =  Constants.appFont11Regular
        Errorview.configureContent(title: title, body: message, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: nil, buttonTapHandler: nil)
        SwiftMessages.show(view: Errorview)
        AudioServicesPlaySystemSound(1521)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            SwiftMessages.hideAll()
        }
        
    }
    
    func showBunnerSuccessAlert(title:String,message:String, completion:(() -> Void)? = nil)
    {
        
        let Errorview = MessageView.viewFromNib(layout: .cardView)
        Errorview.configureTheme(.success)
        Errorview.button?.isHidden = true
        Errorview.titleLabel?.isHidden = true
        Errorview.titleLabel?.font =   Constants.appFont11Regular
        Errorview.bodyLabel?.font =  Constants.appFont11Regular
        Errorview.configureContent(title: title, body: message, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: nil, buttonTapHandler: nil)
        SwiftMessages.show(view: Errorview)
        
        AudioServicesPlaySystemSound(1521)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            SwiftMessages.hideAll()
        }
        
    }
    
    func showOkAlert(title:String,message:String , completion:(() -> Void)? = nil) {
        
        // Create the dialog
        
        let popup = PopupDialog(title: title,
                                message: message,
                                buttonAlignment: .horizontal,
                                transitionStyle: .zoomIn,
                                tapGestureDismissal: false,
                                panGestureDismissal: false,
                                hideStatusBar: false) {
        }
        let dialogAppearance = PopupDialogDefaultView.appearance()
        dialogAppearance.titleFont            = Constants.appFont14Regular
        dialogAppearance.messageFont          = Constants.appFont14Regular
        let okButton = DefaultButton(title:  "Ok".localized) {
            completion?()
            popup.dismiss()
        }
        okButton.titleFont = Constants.appFont14Regular
        popup.addButton(okButton)
        self.present(popup, animated: true, completion: nil)
    }
    
    func showCustomAlert(title:String,message:String,okTitle:String,cancelTitle:String,color :UIColor = UIColor.red ,completion:@escaping (Bool) -> Void) {
        
        // Create the dialog
        let popup = PopupDialog(title: title,
                                message: message,
                                buttonAlignment: .horizontal,
                                transitionStyle: .zoomIn,
                                tapGestureDismissal: false,
                                panGestureDismissal: false,
                                hideStatusBar: false) {
                                    
        }
        let dialogAppearance = PopupDialogDefaultView.appearance()
        dialogAppearance.titleFont            = Constants.appFont14Regular
        dialogAppearance.messageFont          = Constants.appFont14Regular
        
        
        let cancelButton = CancelButton(title: cancelTitle) {
            completion(false)
            popup.dismiss()
        }
        
        cancelButton.titleColor = UIColor.red
        cancelButton.titleFont = Constants.appFont14Regular
        
        let okButton = DefaultButton(title: okTitle) {
            completion(true)
        }
        okButton.titleFont = Constants.appFont14Regular
        
        
        popup.addButtons([okButton,cancelButton])
        
        
        self.present(popup, animated: true, completion: nil)
    }
    
    func showOkAlertWithComp(title:String,message:String,okTitle:String = "ok".localized ,completion:@escaping (Bool) -> Void) {
        
        // Create the dialog
        let popup = PopupDialog(title: title,
                                message: message,
                                buttonAlignment: .horizontal,
                                transitionStyle: .zoomIn,
                                tapGestureDismissal: false,
                                panGestureDismissal: false,
                                hideStatusBar: false) {
        }
        
        let okButton = DefaultButton(title: okTitle) {
            completion(true)
        }
        
        popup.addButton(okButton)
        self.present(popup, animated: true, completion: nil)
    }
    //simple alert
    func showRetryInterntConnection(completion:@escaping (Bool)->Void) {
        showOkAlertWithComp(title: "Connection Error".localized, message: "Please  check your internet connection".localized ,okTitle: "Retry".localized, completion: completion)
    }
    
    func showAlertNoInternt() {
        showOkAlert(title: "", message: "Please  check your internet connection")
    }
    
    func isInterntConnected(completion:@escaping (Bool)->Void){
        guard isConnectedToNetwork() else {
            let mainStoryboard = UIStoryboard(name: "Profile", bundle: nil)
            let vc :NoInternetVC = mainStoryboard.instanceVC()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.present(vc, animated: true, completion: nil)
                return
            }
            
            return
        }
    }
    
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    func showIndicator() {
        //        SVProgressHUD.setShadowColor(UIColor.CustomColor.primaryColor)
        //        SVProgressHUD.setShadowRadius(5)
        //        SVProgressHUD.setShadowOffset(CGSize(width: 5, height: 5))
        //        SVProgressHUD.setShadowOpacity(0.2)
        
        SVProgressHUD.show()
    }
    
    
    
    func hideIndicator() {
        SVProgressHUD.dismiss()
    }
    
    
    
    @IBAction func pop()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dismiss()
    {
        self.dismiss(animated: true)
    }
    
    
    
    
    @IBAction func singOut(){
        self.showCustomAlert(title: "Logout".localized, message:"Do you want signout?".localized, okTitle: "No".localized , cancelTitle:"Logout".localized){ result in
            
           
            NozhaUtility.logOut()
            self.signIn()
           
        }
    }
    
    
    
    @IBAction func singOutWithPermently(message :String){
        self.showOkAlertWithComp(title: "", message: message, okTitle: "Logout".localized) { (bool) in
            self.singOut()
        }
        
    }
    
    
    
    
    
    @IBAction func signIn(){
        if !NozhaUtility.isLogin(){
            let mainStoryboard = UIStoryboard(name: "Registration", bundle: nil)
            let vc :RegistrationVC = mainStoryboard.instanceVC()
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func instanceView<T: UIView>() -> T {
        
        guard let view = Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)?.first as? T else {
            fatalError("Could not locate View with with identifier \(String(describing: T.self)) in Your Project.")
        }
        return view
    }
    
    
    
    
    
    
    
    func routeToUserCities() {
        let mainStoryboard = UIStoryboard(name: "Registration", bundle: nil)
        let rootVC :UserAddressVC = mainStoryboard.instanceVC()
        let navigationController = UINavigationController(rootViewController: rootVC)
        navigationController.navigationBar.isHidden = true
        UIApplication.shared.windows.first?.rootViewController = navigationController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
    func routeToHomeSP() {
      
        let rootviewcontroller: UIWindow
        
        let scene = UIApplication.shared.connectedScenes.first
        let sd : SceneDelegate = ((scene?.delegate as? SceneDelegate)!)
        rootviewcontroller = sd.window!
        sd.initAppInterface()
        
        let mainStoryBord = UIStoryboard(name: "Main", bundle: nil)
        let mainController =  mainStoryBord.instantiateViewController(withIdentifier: "TabViewController")
        let frontNavigationController =  mainStoryBord.instantiateViewController(withIdentifier: "MainNav") as? UINavigationController
        rootviewcontroller.rootViewController = mainController
       
        if let window = sd.window {
            window.rootViewController = frontNavigationController
            window.makeKeyAndVisible()
        }

        
    }
    
    func routeToHomeCustomer() {
      
        let rootviewcontroller: UIWindow
        
        let scene = UIApplication.shared.connectedScenes.first
        let sd : SceneDelegate = ((scene?.delegate as? SceneDelegate)!)
        rootviewcontroller = sd.window!
        sd.initAppInterface()
        
        let mainStoryBord = UIStoryboard(name: "CMain", bundle: nil)
        let mainController =  mainStoryBord.instantiateViewController(withIdentifier: "CTabVC")
        let frontNavigationController =  mainStoryBord.instantiateViewController(withIdentifier: "MainNav") as? UINavigationController
        rootviewcontroller.rootViewController = mainController
       
        if let window = sd.window {
            window.rootViewController = frontNavigationController
            window.makeKeyAndVisible()
        }

        
    }
    
 
    
    
    func showDropDownMenu(button : UIButton  , width : CGFloat) -> DropDown{
        let dropDown = DropDown()
        dropDown.anchorView = button // UIView or UIBarButtonItem
        dropDown.textFont = Constants.appFont14Regular
        
        dropDown.width = width > button.frame.width ? width : button.frame.width
        dropDown.backgroundColor = UIColor.white
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        
        return dropDown
    }
    
    

    
    func checkMaxLength(textField: UITextField!, maxLength: Int) {
        if (textField.text!.count > maxLength) {
            textField.deleteBackward()
        }
    }
    
    func subscribeToNotificationsTopic() {
        
        DispatchQueue.global().async {
            var subscribed = false
            while !subscribed {
                let semaphore = DispatchSemaphore(value: 0)
                
                Messaging.messaging().token { token, error in
                  if let error = error {
                    print("Error fetching FCM registration token: \(error)")
                  } else if let token = token {
                    print("FCM registration token: \(token)")
                  
                    NozhaUtility.saveFcmToken(fcmToken: token )
                    NozhaUtility.setIsSubscribe(subscribe: true)
                    Messaging.messaging().subscribe(toTopic: API.GENERAL_FIREBASE_SUBSCRIBE_Topic)
                    Messaging.messaging().subscribe(toTopic: NozhaUtility.isCustomer() ? API.GENERAL_FIREBASE_SUBSCRIBE_Topic_CUSTOMERS : API.GENERAL_FIREBASE_SUBSCRIBE_Topic_SUPPLIER )
                    
                    if NozhaUtility.isLogin()
                    {
                        Messaging.messaging().subscribe(toTopic: API.USER_FIREBASE_SUBSCRIBE_Topic)
                    }
                    AppDelegate.shared.registerNotification()
                    
                    subscribed = true
                    semaphore.signal()
                  }
                }
    
                let dispatchTime = DispatchTime.now() + DispatchTimeInterval.seconds(3)
                _ = semaphore.wait(timeout: dispatchTime)
            }
        }
        
    }
    
    func UnsubscribeToNotificationsTopic()
    {
        if NozhaUtility.isLogin()
        {
            Messaging.messaging().unsubscribe(fromTopic: API.USER_FIREBASE_SUBSCRIBE_Topic){ error in
                if error == nil {
                    
                    
                    InstanceID.instanceID().deleteID { (error) in
                        if error != nil{
                            print("FIREBASE: \(error.debugDescription)");
                            print("FIREBASE: \(error?.localizedDescription ?? "")");
                            
                        } else {
                    
                            NozhaUtility.setIsSubscribe(subscribe: false)
                        }
                    }
                    
                }
            }
        }
        Messaging.messaging().unsubscribe(fromTopic: NozhaUtility.isCustomer() ? API.GENERAL_FIREBASE_SUBSCRIBE_Topic_CUSTOMERS : API.GENERAL_FIREBASE_SUBSCRIBE_Topic_SUPPLIER){ error in
            if error == nil {
                
                InstanceID.instanceID().deleteID { (error) in
                    if error != nil{
                        print("FIREBASE: ", error.debugDescription);
                    } else {
                        print("FIREBASE: \(error.debugDescription)");
                        print("FIREBASE: \(error?.localizedDescription ?? "")");
                        NozhaUtility.setIsSubscribe(subscribe: false)
                    }
                }
            }
        }
    }
    
  
    
    
}
