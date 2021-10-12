//
//  UpdateProfileVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/18/21.
//

import UIKit
import IBAnimatable
import  MOLH
import Fusuma
import Photos
import DropDown

class UpdateProfileVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, FusumaDelegate {
    @IBOutlet weak var changeIDNoView: UIStackView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var girlBtn: AnimatableButton!
    @IBOutlet weak var boyBtn: AnimatableButton!
    @IBOutlet weak var fullNameTF: AnimatableTextField!
    @IBOutlet weak var phoneTF: AnimatableTextField!
    @IBOutlet weak var emailTF: AnimatableTextField!
    @IBOutlet weak var cityTF: AnimatableTextField!
    @IBOutlet weak var identityView: UIView!
    @IBOutlet weak var addPhotoBtn: AnimatableButton!
    @IBOutlet weak var identityImgV: AnimatableImageView!
    
   
   
    var selected_city_id = 0
    var isGirl = true
    override func viewDidLoad() {
        super.viewDidLoad()
        if NozhaUtility.loadSetting()?.required_gender  ?? false{
            boyBtn.visibility = .visible
            girlBtn.visibility = .visible
        }else {
            boyBtn.visibility = .invisible
            girlBtn.visibility = .invisible
        }
        loader.isHidden = true
        
        let user = NozhaUtility.loadUser()!
        fullNameTF.text = user.name
        phoneTF.text =  user.mobile
        emailTF.text = user.email
        cityTF.text = user.city?.name
        selected_city_id = user.city?.id ?? 0
        
        if user.gender == "male" {
            isGirl = false
            boyBtn.backgroundColor = Constants.black_main_color
            boyBtn.setTitleColor(.white, for: .normal)
            girlBtn.backgroundColor = .clear
            girlBtn.setTitleColor(Constants.black_main_color, for: .normal)
        }else {
            isGirl = true
            girlBtn.backgroundColor = Constants.black_main_color
            girlBtn.setTitleColor(.white, for: .normal)
            boyBtn.backgroundColor = .clear
            boyBtn.setTitleColor(Constants.black_main_color, for: .normal)
        }
        
        if NozhaUtility.isCustomer()  {
            identityView.isHidden = true
            changeIDNoView.isHidden = true
        }else {
            if user.identityPhoto?.count ?? 0 > 0  {
                self.identityImgV.isHidden = false
                self.identityImgV.fetchingImage(url: user.identityPhoto ?? "")
                self.addPhotoBtn.isHidden  = true
            }else {
                self.identityImgV.isHidden = true
                self.addPhotoBtn.isHidden  = false
            }
        }
        
    }
    @IBAction func boyAction(_ sender: UIButton) {
        isGirl = false
        sender.backgroundColor = Constants.black_main_color
        sender.setTitleColor(.white, for: .normal)
        girlBtn.backgroundColor = .clear
        girlBtn.setTitleColor(Constants.black_main_color, for: .normal)
    }
    @IBAction func girlAction(_ sender: UIButton) {
        isGirl = true
        sender.backgroundColor = Constants.black_main_color
        sender.setTitleColor(.white, for: .normal)
        boyBtn.backgroundColor = .clear
        boyBtn.setTitleColor(Constants.black_main_color, for: .normal)
    }
    @IBAction func deleteImgaAction(_ sender: Any) {
        self.addPhotoBtn.isHidden = false
        self.identityImgV.image = UIImage()
        self.identityImgV.isHidden = true
    }
    @IBAction func contactUsAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        let vc :ContactUsVC = mainStoryboard.instanceVC()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    @IBAction func changeIdentityImageAction(_ sender: Any) {
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.cropHeightRatio = 1.0
        fusuma.allowMultipleSelection = false
        fusuma.availableModes = [.library, .camera]
        fusumaCameraRollTitle = "Album".localized
        fusumaCameraTitle = "Camera".localized
        fusuma.photoSelectionLimit = 4
        fusumaSavesImage = true
        present(fusuma, animated: true, completion: nil)
    }
    
    @IBAction func selectCityAction(_ sender: UIButton) {
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
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    

    @IBAction func saveAction(_ sender: Any) {
        switch validationInput()
        {
        case .invalid(let error):
            self.showBunnerAlert(title: "", message: error)
        case .valid:
            self.startRequest()
            break
        }
    }
   
    
    func validationInput() -> Validation{
        
        if phoneTF.text?.isEmpty ?? true  ||  !phoneTF.text!.ValidateMobileNumber() {
            
            return .invalid("You must enter valid mobile number".localized)
        }
        if ( emailTF.text?.isEmpty ?? true ||  !emailTF.text!.isEmailValid )  {
            return .invalid("You must enter valid email".localized)
        }
        if fullNameTF.text!.isEmpty {
            
            return .invalid("You must enter full name".localized)
        }
        if fullNameTF.text!.count < 7 {
            
            return .invalid("You must enter valid name".localized)
        }
        return .valid
    }
    
    func startRequest(){
        
        var params = [String:String]()
        var paramsData = [String:Data]()
        params["name"] = fullNameTF.text ?? ""
        params["email"] = emailTF.text ?? ""
        params["mobile"] = phoneTF.text ?? ""
        params["city_id"] = selected_city_id.description
        params["gender"] = isGirl ? "female" : "male"
        
        if !NozhaUtility.isCustomer()  {
            params["identity_number"] = NozhaUtility.loadUser()?.identityNumber?.description
        
        if identityImgV.image != nil {
        let imgData: NSData = NSData(data: (( identityImgV.image)?.jpegData(compressionQuality: 1)!)!)
        let imageSize: Int = imgData.length
        print("size of image modified in MB: %f ", Double(imageSize) / 1024.0/1024.0)
        if imageSize <= 2 {
            paramsData["identity_photo"] =  identityImgV.image?.jpegData(compressionQuality: 1)
        }else {
            paramsData["identity_photo"] =  identityImgV.image?.jpegData(compressionQuality: 0.5)
        }
       
        }
        }
        
        
        loader.startAnimating()
        loader.isHidden = false
        API.UPDATE_USER.startRequestWithFile(showIndicator: true,params:params ,data: paramsData)
        { (Api,response) in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.loader.isHidden = true
                self.loader.stopAnimating()
            }
            if response.isSuccess {
                let value = response.data as! [String :Any]
                let userData = try! JSONSerialization.data(withJSONObject: value, options: [])
                let user = try! JSONDecoder().decode(User.self, from: userData)

                NozhaUtility.saveUser(user :user)
                NozhaUtility.setCityId(cityId:user.city?.id ?? 0)
                NozhaUtility.setNotificationNo(notifcation_number:user.unreadNotifications ?? 0)
                UIApplication.shared.applicationIconBadgeNumber = user.unreadNotifications ?? 0
                NozhaUtility.setIsSubscribe(subscribe: true)
               self.subscribeToNotificationsTopic()
                self.pop()
                
            }else{
                self.showBunnerAlert(title: "", message: response.message)
            }
        }
    }
    
}

extension UpdateProfileVC
{
   
    
   
    
    // MARK: FusumaDelegate Protocol
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        switch source {
        case .camera:
            print("Image captured from Camera")
        case .library:
            print("Image selected from Camera Roll")
        default:
            print("Image selected")
        }
        self.addPhotoBtn.isHidden = true
        self.identityImgV.image = image
        self.identityImgV.isHidden = false
     
    }

    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
   
    }

    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode, metaData: [ImageMetadata]) {
       
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
    
    }
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode, metaData: ImageMetadata) {
      
    }
    
    func fusumaCameraRollUnauthorized() {
        print("Camera roll unauthorized")

        let alert = UIAlertController(title: "Access Requested".localized,
                                      message: "Saving image needs to access your photo album".localized,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Settings", style: .default) { (action) -> Void in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        })

        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel) { (action) -> Void in
        })

        guard let vc = UIApplication.shared.delegate?.window??.rootViewController, let presented = vc.presentedViewController else {
            return
        }

        presented.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    func startUpdateImageApi(img:UIImage){
        
        var paramsData = [String:Data]()
      
        let imgData: NSData = NSData(data: (img).jpegData(compressionQuality: 1)!)
        let imageSize: Int = imgData.length
        print("size of image modified in MB: %f ", Double(imageSize) / 1024.0/1024.0)
        if imageSize <= 2 {
            paramsData["image"] = img.jpegData(compressionQuality: 1)
        }else {
            paramsData["image"] = img.jpegData(compressionQuality: 0.5)
        }
       
      
        API.UPDATE_IMAGE.startRequestWithFile(showIndicator: true,data: paramsData) { (api, statusResult) in
           
            if statusResult.isSuccess {
              
            }
            else
            {
                self.showBunnerAlert(title: "", message: statusResult.message)
            }
        }
    }
    
 
}

