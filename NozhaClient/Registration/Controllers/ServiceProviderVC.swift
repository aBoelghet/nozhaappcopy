//
//  ServiceProviderVC.swift
//  NozhaUser
//
//  Created by mac book air on 1/12/21.
//

import UIKit
import IBAnimatable
import  MOLH
import Fusuma
import Photos
import DropDown


class ServiceProviderVC:  UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, FusumaDelegate
{
    
    @IBOutlet weak var boyBtn: AnimatableButton!
    @IBOutlet weak var girlBtn: AnimatableButton!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var passwordTF: AnimatableTextField!
    @IBOutlet weak var phoneTF: AnimatableTextField!
    @IBOutlet weak var emailTF: AnimatableTextField!
    @IBOutlet weak var fullNameTF: AnimatableTextField!
    @IBOutlet weak var addPhotoBtn: AnimatableButton!
    @IBOutlet weak var identityImgV: AnimatableImageView!
    
    var isGirl = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader.isHidden = true
        if NozhaUtility.loadSetting()?.required_gender ?? false {
            boyBtn.visibility = .visible
            girlBtn.visibility = .visible
        }else {
            boyBtn.visibility = .invisible
            girlBtn.visibility = .invisible
        }
    }
    
    @IBAction func eyeAction(_ sender: UIButton) {
        if passwordTF.isSecureTextEntry {
            passwordTF.isSecureTextEntry = false
            sender.setImage(Constants.eye_enabled, for: .normal)
        }else {
            passwordTF.isSecureTextEntry = true
            sender.setImage(Constants.eye_disabled, for: .normal)
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
    
    @IBAction func NextAction(_ sender: UIButton) {
        
        switch RegisterValidationInput() {
        case .invalid(let error):
            self.showBunnerAlert(title: "", message: error)
            
        case .valid:
            startRegisterSP()
            break
        }
    }
    @IBAction func backAction(_ sender: UIButton) {
        self.pop()
    }
    
    @IBAction func deleteImgaAction(_ sender: Any) {
        self.addPhotoBtn.isHidden = false
        self.identityImgV.image = nil
        self.identityImgV.isHidden = true
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
    
}

extension ServiceProviderVC {
    
    func startRegisterSP(){
        
        loader.startAnimating()
        loader.isHidden = false
        
        var params = [String:String]()
        var paramsData = [String:Data]()
        params["name"] = fullNameTF.text ?? ""
        params["email"] = emailTF.text ?? ""
        var mobile = phoneTF.text
        mobile?.removeFirst()
        params["mobile"] = phoneTF.text ?? ""
        params["password"] = passwordTF.text
        params["gender"] = isGirl ? "female" : "male"
        
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
        
        let mainStoryboard = UIStoryboard(name: "Registration", bundle: nil)
        let vc :UserAddressVC = mainStoryboard.instanceVC()
        vc.supplier_params = params
        vc.supplier_Data = paramsData
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.loader.isHidden = true
            self.loader.stopAnimating()
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    
    func RegisterValidationInput() -> Validation{
        
        
        if fullNameTF.text!.isEmpty {
            
            return .invalid("You must enter first name".localized)
        }
        
        if fullNameTF.text!.count < 7 {
            
            return .invalid("You must enter valid name".localized)
        }
        
        if phoneTF.text?.isEmpty ?? true  ||  !phoneTF.text!.ValidateMobileNumber() {
            
            return .invalid("You must enter valid mobile number".localized)
        }
        if ( emailTF.text?.isEmpty ?? true ||  !emailTF.text!.isEmailValid )  {
            return .invalid("You must enter valid email".localized)
        }
        if passwordTF.text!.isEmpty {
            
            return .invalid("You must enter password".localized)
        }
        if passwordTF.text!.count < 6 {
            
            return .invalid("Password less than 6 characters".localized)
        }
        if passwordTF.text!.count < 6 {
            
            return .invalid("Password less than 6 characters".localized)
        }
        
        if identityImgV.image == nil {
            return .invalid("Identity image required".localized)
        }
        
        return .valid
    }
    
}



extension ServiceProviderVC
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
    
    
}

