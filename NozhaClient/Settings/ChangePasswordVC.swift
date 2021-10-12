//
//  ChangePasswordVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/18/21.
//

import UIKit
import IBAnimatable
class ChangePasswordVC: UIViewController {

    
    
    @IBOutlet var loader: UIActivityIndicatorView!
    @IBOutlet var confirmPwdTF: AnimatableTextField!
    @IBOutlet var newPwdTF: AnimatableTextField!
    @IBOutlet var currentPwdTF: AnimatableTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader.isHidden = true
        
        
    }
    
 
    @IBAction func showHidePasswordAction(_ sender: UIButton) {
        if sender.tag ==  1 {
            if newPwdTF.isSecureTextEntry {
                newPwdTF.isSecureTextEntry = false
                sender.setImage(Constants.eye_enabled, for: .normal)
            }else {
                newPwdTF.isSecureTextEntry = true
                sender.setImage(Constants.eye_disabled, for: .normal)
            }
        }else if sender.tag ==  2 {
            if confirmPwdTF.isSecureTextEntry {
                confirmPwdTF.isSecureTextEntry = false
                sender.setImage(Constants.eye_enabled, for: .normal)
            }else {
                confirmPwdTF.isSecureTextEntry = true
                sender.setImage(Constants.eye_disabled, for: .normal)
            }
        }
        else {
            if currentPwdTF.isSecureTextEntry {
                currentPwdTF.isSecureTextEntry = false
                sender.setImage(Constants.eye_enabled, for: .normal)
            }else {
                currentPwdTF.isSecureTextEntry = true
                sender.setImage(Constants.eye_disabled, for: .normal)
            }
        }
    }
    @IBAction func sendAction(_ sender: Any)
    {
        switch validationInput()
        {
        case .invalid(let error):
            self.showBunnerAlert(title: "", message: error)
            
        case .valid:
            startRequest()
            break
        }
    }
    
    func validationInput() -> Validation{
        
        if currentPwdTF.text!.isEmpty {
            
            return .invalid("You must enter password".localized)
        }
        if currentPwdTF.text!.count < 6 {
            
            return .invalid("Password less than 6 characters".localized)
        }
        if newPwdTF.text!.isEmpty {
            
            return .invalid("You must enter password".localized)
        }
        if newPwdTF.text!.count < 6 {
            
            return .invalid("Password less than 6 characters".localized)
        }
        
        if confirmPwdTF.text!.isEmpty {
            
            return .invalid("You must enter password".localized)
        }
        if confirmPwdTF.text!.count < 6 {
            
            return .invalid("Password less than 6 characters".localized)
        }
        
        
        if confirmPwdTF.text! != newPwdTF.text!  {
            
            return .invalid("Passwords mismatch".localized)
        }
        return .valid
    }
    
    func startRequest(){
        
        var params = [String:String]()
        params["old_password"] = currentPwdTF.text ?? ""
        params["password"] = newPwdTF.text ?? ""
        params["password_confirmation"] = confirmPwdTF.text
        
        loader.startAnimating()
        loader.isHidden = false
        API.CHANGE_PASSWORD.startRequest(showIndicator: true, params: params) { (Api,response) in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.loader.isHidden = true
                self.loader.stopAnimating()
            }
            if response.isSuccess {
                self.showBunnerSuccessAlert(title: "", message: response.message)
                self.pop()
            }
            else
            {
                self.showBunnerAlert(title: "", message: response.message)
            }
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    


}
