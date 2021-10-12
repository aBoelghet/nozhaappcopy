//
//  CSettingsVC.swift
//  NozhaClient
//
//  Created by macbook on 20/02/2021.
//

import UIKit
import MOLH
import IBAnimatable
class CSettingsVC: UIViewController {

    @IBOutlet weak var updateCityView: AnimatableView!
    @IBOutlet weak var loginLbl: UILabel!
    @IBOutlet weak var languageLbl: UILabel!
    @IBOutlet weak var flagImgV: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if NozhaUtility.isLogin() {
            updateCityView.visibility = .invisible
            loginLbl.text = "Logout".localized
          
        }else {
            
            loginLbl.text = "Login".localized
            updateCityView.visibility = .visible
        }
        
        if !MOLHLanguage.isRTLLanguage()  {
            flagImgV.image = UIImage(named: "ic_eng_lang")
            languageLbl.text = "English"
            
        }
    }
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    @IBAction func aboutUsAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        let vc :AboutVC = mainStoryboard.instanceVC()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    @IBAction func usagePolicyAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        let vc :UsagePolicyVC = mainStoryboard.instanceVC()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    @IBAction func contactUsAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        let vc :ContactUsVC = mainStoryboard.instanceVC()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    @IBAction func editPasswordAction(_ sender: Any) {
        if !NozhaUtility.isLogin() {
            self.signIn()
            
            return
        }
        let mainStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        let vc :ChangePasswordVC = mainStoryboard.instanceVC()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    @IBAction func changeLanguageAction(_ sender: Any) {
        
        self.showCustomAlert(title: "Language".localized, message: "To changing language you need to restart application, do you want to restart?".localized, okTitle: "Yes".localized, cancelTitle: "No".localized){ (result) in
            if result {
                
                var languageSets = AppDelegate.shared.language
                if languageSets == "ar"
                {
                    languageSets = "en"
                }else {
                    languageSets = "ar"
                }
                MOLH.setLanguageTo(languageSets)

                if NozhaUtility.isLogin() {
                    var params = [String:String]()
                    params["language"] = languageSets
                    API.UPDATE_LANGUAGE.startRequest(showIndicator: true, params: params) { (Api,response) in

                        if response.isSuccess {

                            let value = response.data as! [String :Any]
                            let userData = try! JSONSerialization.data(withJSONObject: value, options: [])
                            let user = try! JSONDecoder().decode(User.self, from: userData)
                            NozhaUtility.saveUser(user: user)
                            NozhaUtility.setCityId(cityId:user.city?.id ?? 0)
                            NozhaUtility.setNotificationNo(notifcation_number:user.unreadNotifications ?? 0)
                            UIApplication.shared.applicationIconBadgeNumber = user.unreadNotifications ?? 0
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            exit(0)
                            }

                        }else{
                            self.showBunnerAlert(title: "", message: response.message)
                        }
                    }
                }else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    exit(0)
                    }
                }
                
            }
                             
        }
      
       
        }

        
//        var languageSets = AppDelegate.shared.language
//        if languageSets == "ar"
//        {
//            languageSets = "en"
//        }else {
//            languageSets = "ar"
//        }
//        MOLH.setLanguageTo(languageSets)
//        print("language \(languageSets)")
//        MOLH.reset(transition: .transitionCrossDissolve)
//        let rootviewcontroller: UIWindow
//        if #available(iOS 13.0, *) {
//            let scene = UIApplication.shared.connectedScenes.first
//            let sd : SceneDelegate = ((scene?.delegate as? SceneDelegate)!)
//            rootviewcontroller = sd.window!
//        }else{
//            rootviewcontroller = ((UIApplication.shared.delegate?.window)!)!
//        }
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "LaunchScreenVC")
//        rootviewcontroller.rootViewController = vc
//
//        let mainwindow = rootviewcontroller
//        mainwindow.backgroundColor = .white
//        let transition: UIView.AnimationOptions = .transitionCrossDissolve
//        UIView.transition(with: mainwindow, duration: 0.55001, options: transition, animations: { () -> Void in
//
//        }) { (finished) -> Void in
//           if #available(iOS 13.0, *) {
//                let scene = UIApplication.shared.connectedScenes.first
//                let sd : SceneDelegate = ((scene?.delegate as? SceneDelegate)!)
//                sd.initAppInterface()
//            }else{
//                (UIApplication.shared.delegate as! AppDelegate).initAppInterface()
//            }
//        }
//
////        AppDelegate.shared.reset()
//        if NozhaUtility.isLogin() {
//            var params = [String:String]()
//            params["language"] = languageSets
//            API.UPDATE_LANGUAGE.startRequest(showIndicator: true, params: params) { (Api,response) in
//
//                if response.isSuccess {
//
//                    let value = response.data as! [String :Any]
//                    let userData = try! JSONSerialization.data(withJSONObject: value, options: [])
//                    let user = try! JSONDecoder().decode(User.self, from: userData)
//                    NozhaUtility.saveUser(user: user)
//                    NozhaUtility.setNotificationNo(notifcation_number:user.unreadNotifications ?? 0)
//                    UIApplication.shared.applicationIconBadgeNumber = user.unreadNotifications ?? 0
//
//                }else{
//                    self.showBunnerAlert(title: "", message: response.message)
//                }
//            }
//        }
    
    @IBAction func changeCity(_ sender: Any) {
        self.routeToUserCities()
    }
    
    @IBAction func updateProfileAction(_ sender: Any) {
        if !NozhaUtility.isLogin() {
            self.signIn()
            
            return
        }
        let mainStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        let vc :UpdateProfileVC = mainStoryboard.instanceVC()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
  
    @IBAction func LoginLogoutAction(_ sender: Any) {
        
        if NozhaUtility.isLogin() {
            self.singOut()
        }else {
            self.signIn()
        }
        
       
    }
    
}
