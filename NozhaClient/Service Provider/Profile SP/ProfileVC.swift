//
//  ProfileVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/13/21.
//

import UIKit
import IBAnimatable
import  MOLH
import Fusuma
import DropDown

class ProfileVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, FusumaDelegate   {
    @IBOutlet weak var rateLbl: UILabel!
    
    @IBOutlet weak var reservationNoLbl: UILabel!
    @IBOutlet weak var servicesNoLbl: UILabel!
    @IBOutlet weak var loginLbl: UILabel!
    @IBOutlet weak var languageLbl: UILabel!
    @IBOutlet weak var flagImgV: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userImgV: AnimatableImageView!
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        reservationNoLbl.text = "\("Reservations".localized) : \(NozhaUtility.loadUser()?.reservationsCount?.description.Pricing ?? "")"
        servicesNoLbl.text = "\("Services".localized) : \(NozhaUtility.loadUser()?.servicesCount?.description.Pricing ?? "")"
        rateLbl.text = "\("Rating".localized) : \(NozhaUtility.loadUser()?.avgRate?.description.Pricing ?? "")(\(NozhaUtility.loadUser()?.countRate?.description.Pricing ?? ""))"
        if NozhaUtility.isLogin() {
            userNameLbl.text = NozhaUtility.loadUser()?.name
            loginLbl.text = "Logout".localized
            userImgV.fetchingProfileImageSupplier(url: NozhaUtility.loadUser()?.image ?? "supplier_avatar")
       
        }else {
            userNameLbl.text = ""
            loginLbl.text = "Login".localized
            
        }
        
        if !MOLHLanguage.isRTLLanguage()  {
            flagImgV.image = UIImage(named: "ic_eng_lang")
            languageLbl.text = "English"
            
        }
        
   
    }
    @IBAction func showReviewsAction(_ sender: Any) {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc :ReviewsList = mainStoryboard.instanceVC()
        self.navigationController?.pushViewController(vc, animated: true)
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
//        var languageSets = AppDelegate.shared.language
//        if languageSets == "ar"
//        {
//            languageSets = "en"
//        }else {
//            languageSets = "ar"
//        }
//        MOLH.setLanguageTo(languageSets)
//
//                if #available(iOS 13.0, *) {
//                        let delegate = UIApplication.shared.delegate as? AppDelegate
//                        delegate!.swichRoot()
//                } else {
//                       // Fallback on earlier versions
//                       MOLH.reset()
//                }
//
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
//
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
    @IBAction func changePhotoAction(_ sender: Any) {
        if NozhaUtility.isLogin() {
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
        }else {
            self.signIn()
        }
    }

    @IBAction func showServicesListAction(_ sender: Any) {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc :ServicesVC = mainStoryboard.instanceVC()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    @IBAction func showReservationsAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc :ReservationsListVC = mainStoryboard.instanceVC()
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

extension ProfileVC {
    
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
        self.userImgV.image = image
        self.startUpdateImageApi(img:image)
     
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
