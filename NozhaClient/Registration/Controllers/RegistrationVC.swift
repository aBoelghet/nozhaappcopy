//
//  RegistrationVC.swift
//  NozhaUser
//
//  Created by mac book air on 1/12/21.
//

import UIKit
import Segmentio
import IBAnimatable
import Branch

class RegistrationVC: UIViewController {
    
    
    @IBOutlet var buttons:[UIButton]!
    
    @IBOutlet weak var registerView: UIView!
    @IBOutlet weak var loginView: UIView!
    
    
    @IBOutlet weak var LLoader: UIActivityIndicatorView!
    @IBOutlet weak var RLoader: UIActivityIndicatorView!
    @IBOutlet weak var LboyBtn: AnimatableButton!
    @IBOutlet weak var LGirlBtn: AnimatableButton!
    @IBOutlet weak var LPhoneTF: AnimatableTextField!
    @IBOutlet weak var LPasswordTF: AnimatableTextField!
    
    @IBOutlet weak var RNameTF: AnimatableTextField!
    @IBOutlet weak var RPhoneTF: AnimatableTextField!
    @IBOutlet weak var RPasswordTF: AnimatableTextField!
    @IBOutlet weak var REmailTF: AnimatableTextField!
    
    @IBOutlet weak var aggreeBtn: AnimatableCheckBox!
    
    
    var isGirl = true
    var checkedPolicy = false
    var type = "email"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RPhoneTF.delegate = self
        LLoader.isHidden = true
        RLoader.isHidden = true
        if NozhaUtility.loadSetting()?.required_gender ?? false {
            LboyBtn.visibility = .visible
            LGirlBtn.visibility = .visible
        }else {
            LboyBtn.visibility = .invisible
            LGirlBtn.visibility = .invisible
        }
        
    }
    @IBAction func boyAction(_ sender: UIButton) {
        isGirl = false
        sender.backgroundColor = Constants.black_main_color
        sender.setTitleColor(.white, for: .normal)
        LGirlBtn.backgroundColor = .clear
        LGirlBtn.setTitleColor(Constants.black_main_color, for: .normal)
        
    }
    @IBAction func girlAction(_ sender: UIButton) {
        isGirl = true
        sender.backgroundColor = Constants.black_main_color
        sender.setTitleColor(.white, for: .normal)
        LboyBtn.backgroundColor = .clear
        LboyBtn.setTitleColor(Constants.black_main_color, for: .normal)
    }
    @IBAction func loginAction(_ sender: UIButton) {
        switch LoginValidationInput() {
        case .invalid(let error):
            self.showBunnerAlert(title: "", message: error)
            
        case .valid:
            startLogin()
            break
        }
        
    }
    @IBAction func registerAction(_ sender: UIButton) {
        
        switch RegisterValidationInput()
        {
        case .invalid(let error):
            self.showBunnerAlert(title: "", message: error)
        case .valid:
            self.startRegister()
            break
        }
        
    }
    @IBAction func REyePasswordAction(_ sender: UIButton) {
        if RPasswordTF.isSecureTextEntry {
            RPasswordTF.isSecureTextEntry = false
            sender.setImage(Constants.eye_enabled, for: .normal)
        }else {
            RPasswordTF.isSecureTextEntry = true
            sender.setImage(Constants.eye_disabled, for: .normal)
        }
    }
    
    @IBAction func eyePasswordAction(_ sender: UIButton) {
        if LPasswordTF.isSecureTextEntry {
            LPasswordTF.isSecureTextEntry = false
            sender.setImage(Constants.eye_enabled, for: .normal)
        }else {
            LPasswordTF.isSecureTextEntry = true
            sender.setImage(Constants.eye_disabled, for: .normal)
        }
        
    }
    @IBAction func agreeBtnAction(_ sender: UIButton) {
        if aggreeBtn.checked {
            checkedPolicy = true
        }else {
            checkedPolicy = false
        }
    }
    
    @IBAction func forgetPasswordAction(_ sender: UIButton) {
        let mainStoryboard = UIStoryboard(name: "Registration", bundle: nil)
        let vc :ForgetPasswordVC = mainStoryboard.instanceVC()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    @IBAction func policyAction(_ sender: UIButton) {
        let mainStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        let vc :UsagePolicyVC = mainStoryboard.instanceVC()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    @IBAction func joinAsSPAction(_ sender: UIButton) {
        let mainStoryboard = UIStoryboard(name: "Registration", bundle: nil)
        let vc :ServiceProviderVC = mainStoryboard.instanceVC()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    @IBAction func tabChanged(sender:UIButton) {
        
        for btn in buttons {
            if btn.tag == sender.tag {
                btn.backgroundColor = Constants.black_main_color
                btn.setTitleColor(.white, for: .normal)
            }else {
                btn.backgroundColor = .white
                
                btn.setTitleColor(Constants.gray_main_color, for: .normal)
            }
        }
        self.registerView.isHidden = true
        self.loginView.isHidden = true
        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            options: [.transitionCrossDissolve],
            animations: {
                if sender.tag == 0 {
                    
                    self.loginView.isHidden = false
                }else {
                    self.registerView.isHidden = false
                }
                
            })
        
    }
    
    @IBAction func skipAction(_ sender: Any) {
        if ((self.navigationController?.topViewController?.isKind(of: ProfileVC.self)) != nil) {
            self.routeToHomeCustomer()
            
        }else {
            self.pop()
        }
        
    }
    
}

extension RegistrationVC {
    
    func RegisterValidationInput() -> Validation{
        
        
        if RNameTF.text!.isEmpty {
            
            return .invalid("You must enter first name".localized)
        }
        
        if RNameTF.text!.count < 7 {
            
            return .invalid("You must enter valid name".localized)
        }
        
        if RPhoneTF.text?.isEmpty ?? true  ||  !RPhoneTF.text!.ValidateMobileNumber() {
            
            return .invalid("You must enter valid mobile number".localized)
        }
        if ( REmailTF.text?.isEmpty ?? true ||  !REmailTF.text!.isEmailValid )  {
            return .invalid("You must enter valid email".localized)
        }
        if RPasswordTF.text!.isEmpty {
            
            return .invalid("You must enter password".localized)
        }
        if RPasswordTF.text!.count < 6 {
            
            return .invalid("Password less than 6 characters".localized)
        }
        if !aggreeBtn.checked {
            return .invalid("Agree usage policy".localized)
        }
        return .valid
    }
    
    func LoginValidationInput() -> Validation{
        
        if LPhoneTF.text?.isEmpty ?? true  {
            
            return .invalid("You must enter valid mobile number/ email".localized)
        }
        let num = Int(LPhoneTF.text ?? "")
        if num != nil {
            if !(LPhoneTF.text?.ValidateMobileNumber() ?? false) {
                return .invalid("You must enter valid mobile number".localized)
            }
        }else {
            if !LPhoneTF.text!.isEmailValid {
                return .invalid("You must enter valid email".localized)
            }
        }
        
        if LPasswordTF.text!.isEmpty {
            
            return .invalid("You must enter password".localized)
        }
        if LPasswordTF.text!.count < 6 {
            
            return .invalid("Password less than 6 characters".localized)
        }
        
        return .valid
    }
    
    
    func startLogin(){
        
        
        var params = [String:String]()
        params["password"] = LPasswordTF.text ?? ""
        let num = Int(LPhoneTF.text ?? "")
        if num != nil {
            type = "mobile"
            let mobile = LPhoneTF.text
            params["username"] = "\(mobile ?? "")"
            
        }else {
            params["username"] = LPhoneTF.text ?? ""
            type = "email"
        }
        params["type"] =  type
        
        LLoader.startAnimating()
        LLoader.isHidden = false
        
        API.LOGIN.startRequest(showIndicator: true, params: params) { (Api,response) in
            
            if response.isSuccess {
                
                let value = response.data as! [String :Any]
                let userData = try! JSONSerialization.data(withJSONObject: value, options: [])
                let user = try! JSONDecoder().decode(User.self, from: userData)
                
                NozhaUtility.saveUser(user :user)
                NozhaUtility.setCityId(cityId:user.city?.id ?? 0)
                Branch.getInstance().setIdentity("\(user.id?.description ?? "")")
                NozhaUtility.setNotificationNo(notifcation_number:user.unreadNotifications ?? 0)
                UIApplication.shared.applicationIconBadgeNumber = user.unreadNotifications ?? 0
                NozhaUtility.setIsSubscribe(subscribe: true)
                self.subscribeToNotificationsTopic()
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.LLoader.isHidden = true
                    self.LLoader.stopAnimating()
                    if user.type == "supplier" {
                        self.routeToHomeSP()
                    }else {
                        self.routeToHomeCustomer()
                    }
                }
                
                
                
            }else{
                self.LLoader.isHidden = true
                self.LLoader.stopAnimating()
                self.showBunnerAlert(title: "", message: response.message)
            }
        }
        
    }
    
    func startRegister(){
        
        var params = [String:String]()
        params["name"] = RNameTF.text ?? ""
        params["email"] = REmailTF.text ?? ""
        var mobile = RPhoneTF.text
        mobile?.removeFirst()
        params["mobile"] = RPhoneTF.text ?? ""
        params["gender"] = isGirl ? "female" : "male"
        params["password"] = RPasswordTF.text ?? ""
        
        RLoader.startAnimating()
        RLoader.isHidden = false
        
        let mainStoryboard = UIStoryboard(name: "Registration", bundle: nil)
        let vc :UserAddressVC = mainStoryboard.instanceVC()
        vc.customer_params = params
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.RLoader.isHidden = true
            self.RLoader.stopAnimating()
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
        
        
    }
    
}

extension RegistrationVC : UITextFieldDelegate {
 
   
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        switch textField {
            
        case RPhoneTF:
            checkMaxLength(textField: RPhoneTF, maxLength: 9)
       
            
        default:
            return true
        }
        
        return true
    }
}
