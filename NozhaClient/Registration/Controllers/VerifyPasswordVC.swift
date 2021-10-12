//
//  VerifyPasswordVC.swift
//  NozhaUser
//
//  Created by mac book air on 1/12/21.
//

import UIKit
import IBAnimatable
import KWVerificationCodeView

class VerifyPasswordVC: UIViewController {
    @IBOutlet weak var code: KWVerificationCodeView!
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var password2TF: AnimatableTextField!
    @IBOutlet weak var passwordTF: AnimatableTextField!
    
    var email  = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        code.keyboardType = .numberPad
        
        loader.isHidden = true
    }
    
    
    @IBAction func eyeAction(_ sender: UIButton) {
        
        if sender.tag ==  1 {
            if passwordTF.isSecureTextEntry {
                passwordTF.isSecureTextEntry = false
                sender.setImage(Constants.eye_enabled, for: .normal)
            }else {
                passwordTF.isSecureTextEntry = true
                sender.setImage(Constants.eye_disabled, for: .normal)
            }
        }else {
            if password2TF.isSecureTextEntry {
                password2TF.isSecureTextEntry = false
                sender.setImage(Constants.eye_enabled, for: .normal)
            }else {
                password2TF.isSecureTextEntry = true
                sender.setImage(Constants.eye_disabled, for: .normal)
            }
        }
        
    }
    
    @IBAction func clearCodeAction(_ sender: Any) {
        code.clear()
    }
    @IBAction func resetPasswordAction(_ sender: Any) {
        
        switch validationInput() {
        case .invalid(let error):
            self.showBunnerAlert(title: "", message: error)
            
        case .valid:
            startRequest()
            break
        }
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    
}

extension VerifyPasswordVC {
    
    func validationInput() -> Validation{
        
        if ( code.getVerificationCode().isEmpty ||  code.getVerificationCode().count < 4 )  {
            return .invalid("You must enter valid code".localized)
        }
        if passwordTF.text!.isEmpty {
            
            return .invalid("You must enter password".localized)
        }
        if passwordTF.text!.count < 6 {
            
            return .invalid("Password less than 6 characters".localized)
        }
        if password2TF.text!.isEmpty {
            
            return .invalid("You must enter password".localized)
        }
        if password2TF.text!.count < 6 {
            
            return .invalid("Password less than 6 characters".localized)
        }
        if password2TF.text! != passwordTF.text!  {
            
            return .invalid("Passwords mismatch".localized)
        }
        return .valid
        
    }
    
    func startRequest(){
        
        self.loader.isHidden = false
        self.loader.startAnimating()
        var params = [String:String]()
        params["email"] = email
        params["code"] = code.getVerificationCode().description
        params["password"] = passwordTF.text
        params["password_confirmation"] = password2TF.text
        
        self.loader.isHidden = false
        self.loader.startAnimating()
        API.RESET_PASSWORD.startRequest(showIndicator: true, params: params) { (Api,response) in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                
                let value = response.data as! [String :Any]
                let userData = try! JSONSerialization.data(withJSONObject: value, options: [])
                let user = try! JSONDecoder().decode(User.self, from: userData)
                
                NozhaUtility.saveUser(user :user)
                NozhaUtility.setCityId(cityId:user.city?.id ?? 0)
                NozhaUtility.setNotificationNo(notifcation_number:user.unreadNotifications ?? 0)
                UIApplication.shared.applicationIconBadgeNumber = user.unreadNotifications ?? 0
                
                NozhaUtility.setIsSubscribe(subscribe: true)
                self.subscribeToNotificationsTopic()
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.loader.isHidden = true
                    self.loader.stopAnimating()
                    if NozhaUtility.isCustomer() {
                        self.routeToHomeCustomer()
                    }else {
                    self.routeToHomeSP()
                    }
                }
            }
            
            if response.isSuccess {
                self.showBunnerSuccessAlert(title: "", message: response.message)
                self.signIn()
                
            }else{
                self.showBunnerAlert(title: "", message: response.message)
            }
        }
    }
    
}
