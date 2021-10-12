//
//  ForgetPasswordVC.swift
//  NozhaUser
//
//  Created by mac book air on 1/12/21.
//

import UIKit
import IBAnimatable

class ForgetPasswordVC: UIViewController {
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var emailTF: AnimatableTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        loader.isHidden = true
    }
    
    @IBAction func nextAction(_ sender: Any) {
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

extension ForgetPasswordVC {
    func validationInput() -> Validation{
        
        
        if ( emailTF.text?.isEmpty ?? true ||  !emailTF.text!.isEmailValid )  {
            return .invalid("You must enter valid email".localized)
        }
        
        return .valid
    }
    
    func startRequest(){
        
        var params = [String:String]()
        params["email"] = emailTF.text ?? ""
        
        self.loader.isHidden = false
        self.loader.startAnimating()
        
        API.FORGET.startRequest(showIndicator: true, params: params) { (Api,response) in
            
            if response.isSuccess {
                self.showBunnerSuccessAlert(title: "", message: response.message)
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.loader.isHidden = true
                    self.loader.stopAnimating()
                    self.routeToVerfiy ()
                }
                
                
            }else{
                self.showBunnerAlert(title: "", message: response.message)
            }
        }
    }
    
    func routeToVerfiy (){
        let mainStoryboard = UIStoryboard(name: "Registration", bundle: nil)
        let vc :VerifyPasswordVC = mainStoryboard.instanceVC()
        vc.email  = self.emailTF.text ?? ""
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
}
