//
//  ContactUsVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/18/21.
//

import UIKit
import UITextView_Placeholder
import IQKeyboardManagerSwift
import  IBAnimatable
import DropDown
import MOLH

class ContactUsVC: UIViewController {
    
    @IBOutlet weak var phoneTF: AnimatableTextField!
    @IBOutlet weak var fullNameTF: AnimatableTextField!
    @IBOutlet var loader: UIActivityIndicatorView!
    @IBOutlet weak var msgTV: IQTextView!
    @IBOutlet weak var emailTF: AnimatableTextField!
    @IBOutlet weak var cityTF: AnimatableTextField!
    @IBOutlet weak var boyBtn: AnimatableButton!
    @IBOutlet weak var GirlBtn: AnimatableButton!
    
    var selected_city_id = 0
    var isGirl = true
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        loader.isHidden = true
        if NozhaUtility.loadSetting()?.required_gender ?? false {
            boyBtn.visibility = .visible
            GirlBtn.visibility = .visible
        }else {
            boyBtn.visibility = .invisible
            GirlBtn.visibility = .invisible
        }
        if NozhaUtility.isLogin() {
            let user = NozhaUtility.loadUser()!
            fullNameTF.text = user.name
            phoneTF.text =  user.mobile
            emailTF.text = user.email
            selected_city_id = user.city?.id ?? 0
            if user.gender == "male" {
                isGirl = false
                boyBtn.backgroundColor = Constants.black_main_color
                boyBtn.setTitleColor(.white, for: .normal)
                GirlBtn.backgroundColor = .clear
                GirlBtn.setTitleColor(Constants.black_main_color, for: .normal)
            }else {
                isGirl = true
                GirlBtn.backgroundColor = Constants.black_main_color
                GirlBtn.setTitleColor(.white, for: .normal)
                boyBtn.backgroundColor = .clear
                boyBtn.setTitleColor(Constants.black_main_color, for: .normal)
            }
            
        }
        msgTV.placeholderTextView.placeholder = "Write message details".localized
    }
    @IBAction func boyAction(_ sender: UIButton) {
        isGirl = false
        sender.backgroundColor = Constants.black_main_color
        sender.setTitleColor(.white, for: .normal)
        GirlBtn.backgroundColor = .clear
        GirlBtn.setTitleColor(Constants.black_main_color, for: .normal)
        
    }
    @IBAction func girlAction(_ sender: UIButton) {
        isGirl = true
        sender.backgroundColor = Constants.black_main_color
        sender.setTitleColor(.white, for: .normal)
        boyBtn.backgroundColor = .clear
        boyBtn.setTitleColor(Constants.black_main_color, for: .normal)
    }
    
    @IBAction func chooseCityAction(_ sender: UIButton) {
        
        
        if Constants.cities.count > 0  {
            let citiesDropDown = showDropDownMenu(button: sender, width: sender.bounds.width)
            citiesDropDown.semanticContentAttribute =  .forceLeftToRight
            citiesDropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
                if MOLHLanguage.isRTLLanguage() {
                    cell.optionLabel.textAlignment = .right
                }else {
                    cell.optionLabel.textAlignment = .left
                }
            }
            
            citiesDropDown.dataSource = Constants.cities.map({($0.name ?? "")}) as [String]
            
            citiesDropDown.selectionAction = { [weak self] (index, item) in
                let city = Constants.cities[index]
                self?.selected_city_id =  city.id ?? 0
                self?.cityTF.text = city.name ?? ""
                
            }
            citiesDropDown.dismissMode = .onTap
            citiesDropDown.direction = .bottom
            citiesDropDown.show()
        }
    }
    
    @IBAction func sendAction(_ sender: Any) {
        switch validationInput() {
        case .invalid(let error):
            self.showBunnerAlert(title: "", message: error)
            
        case .valid:
            startSendReqeust()
            break
        }
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
}

extension ContactUsVC {
    func startSendReqeust()
    {
        var params = [String:String]()
        params["name"] = fullNameTF.text!
        params["mobile"] = phoneTF.text!
        params["content"] = msgTV.text!
        params["email"] = emailTF.text!
        params["city_id"] = selected_city_id.description
        params["gender"] = isGirl ? "female" : "male"
        
        
        loader.startAnimating()
        loader.isHidden = false
        API.CONTACT_US.startRequest(showIndicator: true,  params: params) { (Api, statusResult) in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.loader.isHidden = true
                self.loader.stopAnimating()
            }
            if statusResult.isSuccess {
                self.showOkAlert(title: "", message: statusResult.message) {
                    if self.navigationController != nil {
                        self.pop()
                    }else{
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }else{
                self.showBunnerAlert(title: "", message: statusResult.message)
            }
        }
        
    }
    
    
    func validationInput() -> Validation{
        
        if fullNameTF.text!.isEmpty {
            return .invalid("You must enter full name".localized)
        }
        
        if phoneTF.text!.isEmpty  || !phoneTF.text!.ValidateMobileNumber()  {
            return .invalid("You must enter valid mobile number".localized)
        }
        
        if ( emailTF.text?.isEmpty ?? true ||  !emailTF.text!.isEmailValid )  {
            return .invalid("You must enter valid email".localized)
        }
        
        
        if msgTV.text!.isEmpty {
            return .invalid("You must enter message".localized)
        }
        
        return .valid
    }
}


extension ContactUsVC :UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        return textView.text.count + (text.count - range.length) <= 100
    }
}
