//
//  addServiceStep2VC.swift
//  NozhaClient
//
//  Created by mac book air on 1/17/21.
//

import UIKit
import IBAnimatable
import DropDown
import MOLH

class addServiceStep2VC: UIViewController {
    
    @IBOutlet weak var mapBtn: UIButton!
    @IBOutlet weak var datesBtn: UIButton!
    @IBOutlet weak var categoryBtn: UIButton!
    @IBOutlet weak var datesTF: AnimatableTextField!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var nextBtn: AnimatableButton!
    @IBOutlet weak var mapTF: AnimatableTextField!
    @IBOutlet weak var hasPermissionCheckbox: AnimatableCheckBox!
    @IBOutlet weak var organiserTF: AnimatableTextField!
    @IBOutlet weak var noPersonsTF: AnimatableTextField!
    @IBOutlet weak var categoryTF: AnimatableTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapTF.text = Global.share.new_Service.address
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loader.isHidden = true
        mapTF.text = Global.share.new_Service.address
        if Global.share.new_Service.type == "event" {
            nextBtn.setTitle("Save".localized, for: .normal)
        }
        datesTF.text = Global.share.new_Service.work_date?.first
        organiserTF.text = Global.share.new_Service.organiser
        categoryTF.text =  Global.share.new_Service.categoryName
        let noPersons =  Global.share.new_Service.people_number
        noPersonsTF.text = noPersons ?? 0 > 0 ? noPersons?.description :  ""
        hasPermissionCheckbox.checked = Global.share.new_Service.has_permission == 1
        
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        datesTF.text = Global.share.new_Service.work_date?.first
    }
    
    @IBAction func selectCategoryAction(_ sender: UIButton) {
        if Constants.categories.count > 0  {
            let dropDown = showDropDownMenu(button: sender, width: sender.bounds.width)
            dropDown.semanticContentAttribute =  .forceLeftToRight
            dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
                if MOLHLanguage.isRTLLanguage() {
                    cell.optionLabel.textAlignment = .right
                }else {
                    cell.optionLabel.textAlignment = .left
                }
            }
            
            dropDown.dataSource = Constants.categories.map({$0.name}) as! [String]
            dropDown.selectionAction = { [weak self] (index, item) in
                Global.share.new_Service.category_id =  Constants.categories[index].id ?? 0
                Global.share.new_Service.categoryName = Constants.categories[index].name ?? ""
                self?.categoryTF.text = Constants.categories[index].name ?? ""
                Global.share.new_Service.organiser =  self?.organiserTF.text
                Global.share.new_Service.people_number = Int(self?.noPersonsTF.text ?? "0")
                Global.share.new_Service.has_permission = self?.hasPermissionCheckbox.checked ?? false ? 1 : 0
                
                let mainStoryboard = UIStoryboard(name: "CreateService", bundle: nil)
                let vc :AddEditAddressVC = mainStoryboard.instanceVC()
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            dropDown.dismissMode = .onTap
            dropDown.direction = .bottom
            dropDown.show()
        }
    }
    @IBAction func routeToMapAction(_ sender: Any) {
        
        Global.share.new_Service.organiser =  organiserTF.text
        Global.share.new_Service.people_number = Int(noPersonsTF.text ?? "0")
        Global.share.new_Service.has_permission = hasPermissionCheckbox.checked ? 1 : 0
        
        let mainStoryboard = UIStoryboard(name: "CreateService", bundle: nil)
        let vc :AddEditAddressVC = mainStoryboard.instanceVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func routeToDatings(_ sender: Any) {
        
        Global.share.new_Service.organiser =  organiserTF.text
        Global.share.new_Service.people_number = Int(noPersonsTF.text ?? "0")
        Global.share.new_Service.has_permission = hasPermissionCheckbox.checked ? 1 : 0
        
        let mainStoryboard = UIStoryboard(name: "CreateService", bundle: nil)
        let vc :ScheduleServiceVC = mainStoryboard.instanceVC()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.navigationController?.present(vc, animated: true, completion: nil) 
    }
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    @IBAction func nextAction(_ sender: Any) {
        switch Step2ValidatonInput()
        {
        case .invalid(let error):
            self.showBunnerAlert(title: "", message: error)
        case .valid:
            if Global.share.new_Service.type == "event" {
                saveService ()
            }else{
                self.routeToStep3 ()
            }
            break
        }
    }
    
    func routeToStep3 (){
        
        
        let mainStoryboard = UIStoryboard(name: "CreateService", bundle: nil)
        let vc :addServcieStep3VC = mainStoryboard.instanceVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func permissionCheckAction(_ sender: Any) {
        if hasPermissionCheckbox.checked {
            Global.share.new_Service.has_permission = 1
        }else {
            Global.share.new_Service.has_permission = 0
        }
        
    }
    
}


extension addServiceStep2VC : UITextViewDelegate, UITextFieldDelegate {
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == datesTF {
            datesTF.resignFirstResponder()
            organiserTF.becomeFirstResponder()
        }
        else if textField == organiserTF {
            organiserTF.resignFirstResponder()
            noPersonsTF.becomeFirstResponder()
          
        }
        else if textField == noPersonsTF {
            noPersonsTF.resignFirstResponder()
            categoryTF.becomeFirstResponder()
            self.view.endEditing(true)
           selectCategoryAction(categoryBtn)
        }
        else if textField == categoryTF {
            categoryTF.resignFirstResponder()
            mapTF.becomeFirstResponder()
            self.view.endEditing(true)
            routeToMapAction(mapBtn!)
        }
        else if textField == mapTF {
            mapTF.resignFirstResponder()
            switch Step2ValidatonInput()
            {
            case .invalid(let error):
                self.showBunnerAlert(title: "", message: error)
            case .valid:
                if Global.share.new_Service.type == "event" {
                    saveService ()
                }else{
                    self.routeToStep3 ()
                }
                break
            }
          
        }
        
        
        return true
    }
    func Step2ValidatonInput() -> Validation{
        
        if organiserTF.text?.isEmpty ?? true  {
            return .invalid("You must enter valid organiser name".localized)
        }else {
            Global.share.new_Service.organiser = organiserTF.text
        }
        if noPersonsTF.text?.isEmpty ?? true  {
            return .invalid("You must enter valid number of persons".localized)
        }else {
            Global.share.new_Service.people_number = Int(noPersonsTF.text ?? "0")
        }
        
        if categoryTF.text!.isEmpty {
            return .invalid("You must enter valid category".localized)
        }
        
        if Global.share.new_Service.service_dates?.count == 0 {
            
            return .invalid("You must enter service dates".localized)
        }
        if Global.share.new_Service.lng == 0 ||  Global.share.new_Service.lat == 0 {
            
            return .invalid("You must enter service location".localized)
        }
        
        if !hasPermissionCheckbox.checked {
            return .invalid("You must to check that you have  permissions to create activity ".localized)
        }
        
        
        
        return .valid
    }
    
    
    func saveService (){
        var params = [String:String]()
        params["name_ar"] =  Global.share.new_Service.name ?? ""
        params["name_en"] =  Global.share.new_Service.en_name ?? ""
        params["type"] = Global.share.new_Service.type ?? ""
        params["price"] = Global.share.new_Service.price?.description ?? ""
        params["city_id"] = Global.share.new_Service.city_id?.description ?? "0"
        params["total_duration"] = Global.share.new_Service.total_duration?.description ?? "0"
        
        
        params["duration_id"] =  Global.share.new_Service.duration_id?.description ?? ""
        params["video_url"] = Global.share.new_Service.video_url ?? ""
        params["organisers"] = Global.share.new_Service.organiser?.description ?? ""
        params["people_number"] = Global.share.new_Service.people_number?.description ?? "0"
        params["category_id"] = Global.share.new_Service.category_id?.description ?? "0"
        params["description_ar"] = Global.share.new_Service.description_str ?? ""
        params["description_en"] = Global.share.new_Service.en_description_str ?? ""
        
        
        params["address"] =  Global.share.new_Service.address?.description ?? ""
        params["lat"] = Global.share.new_Service.lat?.description ?? "0"
        params["lng"] = Global.share.new_Service.lng?.description ?? "0"
        params["has_permission"] = Global.share.new_Service.has_permission?.description ?? "0"
        
        for (index,date_str) in Global.share.new_Service.work_date!.enumerated(){
            params["work_date[\(index)]"] = date_str
        }
        for (index,from_str) in Global.share.new_Service.from!.enumerated(){
            params["from[\(index)]"] = from_str
        }
        for (index,to_str) in Global.share.new_Service.to!.enumerated(){
            params["to[\(index)]"] = to_str
        }
        var paramsData = [String:Data]()
        for (index,image) in Global.share.new_Service.images.enumerated(){
            
            let imgData: NSData = NSData(data: (image).jpegData(compressionQuality: 1)!)
            let imageSize: Int = imgData.length
            print("size of image modified in MB: %f ", Double(imageSize) / 1024.0/1024.0)
            if imageSize <= 2 {
                paramsData["images[\(index)]"] = image.jpegData(compressionQuality: 1)
            }else {
                paramsData["images[\(index)]"] = image.jpegData(compressionQuality: 0.5)
            }
        }
        
        loader.startAnimating()
        loader.isHidden = false
        API.CREATE_SERVICE.startRequestWithFile(showIndicator: true,params:params ,data: paramsData) { (api, statusResult) in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.loader.isHidden = true
                self.loader.stopAnimating()
            }
            if statusResult.isSuccess {
                self.showOkAlert(title: "", message: statusResult.message,completion: {
                    self.routeToHomeSP()
                })
                
            }
            else
            {
                self.showBunnerAlert(title: "", message: statusResult.message)
            }
        }
    }
    
}


