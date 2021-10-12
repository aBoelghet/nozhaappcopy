//
//  addServiceVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/17/21.
//

import UIKit
import Photos
import DropDown
import IBAnimatable
import UITextView_Placeholder
import IQKeyboardManagerSwift
import MOLH
import ImageSlideshow
import Fusuma

class addServiceVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate ,FusumaDelegate{
    
    
    
    @IBOutlet weak var duraitionBtn: UIButton!
    @IBOutlet weak var typeBtn: UIButton!
    @IBOutlet weak var cityBtn: UIButton!
    @IBOutlet weak var en_descTV: IQTextView!
    @IBOutlet weak var en_nameTF: AnimatableTextField!
    @IBOutlet weak var totalDuration: AnimatableTextField!
    @IBOutlet weak var serivceTypeTF: AnimatableTextField!
    @IBOutlet weak var cityTF: AnimatableTextField!
    
    @IBOutlet weak var durationTF: AnimatableTextField!
    @IBOutlet weak var videoUrlTF: AnimatableTextField!
    @IBOutlet weak var descrebtionTV: IQTextView!
    @IBOutlet weak var priceTF: AnimatableTextField!
    @IBOutlet weak var nameTF: AnimatableTextField!
    @IBOutlet weak var collectionView: UICollectionView!
    var modelsPhotos : [UIImage] = [UIImage]()
    var slideshowTransitioningDelegate: ZoomAnimatedTransitioningDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Global.share.new_Service = NewService()
        descrebtionTV.placeholderTextView.placeholder = "Service descreption (Arabic)".localized
        en_descTV.placeholderTextView.placeholder = "Service descreption (English)".localized
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    
    
    @IBAction func serviceTypeAction(_ sender: UIButton) {
        let types = [ "Event (Unrequired supplier acceptance)".localized, "Trip (Required supplier acceptance)".localized]
        let typesDropDown = showDropDownMenu(button: sender, width: sender.bounds.width)
        typesDropDown.semanticContentAttribute =  .forceLeftToRight
        typesDropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            if MOLHLanguage.isRTLLanguage() {
                cell.optionLabel.textAlignment = .right
            }else {
                cell.optionLabel.textAlignment = .left
            }
        }
        
        typesDropDown.dataSource = types.map({$0})
        
        typesDropDown.selectionAction = { [weak self] (index, item) in
            
            Global.share.new_Service.type = index == 0 ?  "event" : "trip"
            self?.serivceTypeTF.text = types[index]
            self?.serivceTypeTF.resignFirstResponder()
            self?.priceTF.becomeFirstResponder()
            
        }
        typesDropDown.dismissMode = .onTap
        typesDropDown.direction = .bottom
        typesDropDown.show()
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
            
            citiesDropDown.dataSource = Constants.cities.map({$0.name}) as! [String]
            citiesDropDown.selectionAction = { [weak self] (index, item) in
                Global.share.new_Service.city_id =  Constants.cities[index].id ?? 0
                self?.cityTF.text = Constants.cities[index].name ?? ""
                self?.cityTF.resignFirstResponder()
                self?.durationTF.becomeFirstResponder()
                self?.view.endEditing(true)
                self?.selectDurationAction((self?.duraitionBtn)!)
            }
            citiesDropDown.dismissMode = .onTap
            citiesDropDown.direction = .bottom
            citiesDropDown.show()
        }
    }
    @IBAction func selectDurationAction(_ sender: UIButton) {
        if Constants.durations.count > 0  {
            let dropDown = showDropDownMenu(button: sender, width: sender.bounds.width)
            dropDown.semanticContentAttribute =  .forceLeftToRight
            dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
                if MOLHLanguage.isRTLLanguage() {
                    cell.optionLabel.textAlignment = .right
                }else {
                    cell.optionLabel.textAlignment = .left
                }
            }
            
            dropDown.dataSource = Constants.durations.map({$0.name}) as! [String]
            dropDown.selectionAction = { [weak self] (index, item) in
                Global.share.new_Service.duration_id =  Constants.durations[index].id ?? 0
                self?.durationTF.text = Constants.durations[index].name ?? ""
                self?.totalDuration.becomeFirstResponder()
            }
            dropDown.dismissMode = .onTap
            dropDown.direction = .bottom
            dropDown.show()
        }
    }
    
    
    @IBAction func nextAction(_ sender: Any) {
        switch Step1ValidatonInput()
        {
        case .invalid(let error):
            self.showBunnerAlert(title: "", message: error)
        case .valid:
            Global.share.new_Service.video_url = videoUrlTF.text
            self.routeToStep2 ()
            break
        }
    }
    
    func routeToStep2 (){
        
        let vc = UIStoryboard(name: "CreateService", bundle: nil).instantiateViewController(withIdentifier: "addServiceStep2VC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func addImageAction(_ sender: Any) {
        
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.cropHeightRatio = 1.0
        fusuma.allowMultipleSelection = true
        fusuma.availableModes = [.library, .camera]
        fusumaCameraRollTitle = "Album".localized
        fusumaCameraTitle = "Camera".localized
        fusuma.photoSelectionLimit = 4
        fusumaSavesImage = true
        present(fusuma, animated: true, completion: nil)
        
    }
    
    
}


extension addServiceVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 70, height: 80)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return modelsPhotos.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        
        guard let cell:imageCVC = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCVC", for:indexPath) as? imageCVC else {
            assert(false,"Invaild Cell")
            return UICollectionViewCell()
        }
        let model = modelsPhotos[indexPath.row]
        cell.img?.image = model
        cell.deleteBtn.tag  = indexPath.item;
        cell.viewController = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        let fullScreenController = FullScreenSlideshowViewController()
        fullScreenController.inputs = self.modelsPhotos.map { ImageSource(image: $0) }
        fullScreenController.initialPage = indexPath.row
        
        if let cell = collectionView.cellForItem(at: indexPath)as? imageCVC , let imageView = cell.img {
            slideshowTransitioningDelegate = ZoomAnimatedTransitioningDelegate(imageView: imageView, slideshowController: fullScreenController)
            fullScreenController.transitioningDelegate = slideshowTransitioningDelegate
        }
        fullScreenController.slideshow.currentPageChanged = { [weak self] page in
            if let cell = collectionView.cellForItem(at: IndexPath(row: page, section: 0))as? imageCVC , let imageView = cell.img {
                self?.slideshowTransitioningDelegate?.referenceImageView = imageView
            }
        }
        
        present(fullScreenController, animated: true, completion: nil)
        
    }
    
    
}



extension addServiceVC : UITextFieldDelegate, UITextViewDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTF {
            nameTF.resignFirstResponder()
            en_nameTF.becomeFirstResponder()
        }
        else if textField == en_nameTF {
            en_nameTF.resignFirstResponder()
            serivceTypeTF.becomeFirstResponder()
            self.view.endEditing(true)
            serviceTypeAction(typeBtn)
        }
        else if textField == serivceTypeTF {
            serivceTypeTF.resignFirstResponder()
            priceTF.becomeFirstResponder()
        }
        else if textField == priceTF {
            priceTF.resignFirstResponder()
            cityTF.becomeFirstResponder()
            self.view.endEditing(true)
            selectCityAction(cityBtn)
        }
        else if textField == cityTF {
            cityTF.resignFirstResponder()
            durationTF.becomeFirstResponder()
            self.view.endEditing(true)
            selectDurationAction(duraitionBtn)
        }
        else if textField == durationTF {
            durationTF.resignFirstResponder()
            self.view.endEditing(true)
            totalDuration.becomeFirstResponder()
            
        }
        else if textField == totalDuration {
            totalDuration.resignFirstResponder()
            descrebtionTV.becomeFirstResponder()
            
        }
        else if textField == videoUrlTF {
            videoUrlTF.resignFirstResponder()
            switch Step1ValidatonInput()
            {
            case .invalid(let error):
                self.showBunnerAlert(title: "", message: error)
            case .valid:
                Global.share.new_Service.video_url = videoUrlTF.text
                self.routeToStep2 ()
                break
            }
            
        }
        
        return true
    }
    
    
    
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
        
        self.modelsPhotos.append(image)
        Global.share.new_Service.images.append(image)
        self.collectionView.reloadData()
    }
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
        
    }
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode, metaData: [ImageMetadata]) {
        print("Number of selection images: \(images.count)")
        
        var count: Double = 0
        
        for image in images {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.modelsPhotos.append(image)
                Global.share.new_Service.images.append(image)
                
                self.collectionView.reloadData()
                print("w: \(image.size.width) - h: \(image.size.height)")
            }
            
            count += 1
        }
        self.collectionView.reloadData()
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
    }
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode, metaData: ImageMetadata) {
        print("Image mediatype: \(metaData.mediaType)")
        print("Source image size: \(metaData.pixelWidth)x\(metaData.pixelHeight)")
        print("Creation date: \(String(describing: metaData.creationDate))")
        print("Modification date: \(String(describing: metaData.modificationDate))")
        print("Video duration: \(metaData.duration)")
        print("Is favourite: \(metaData.isFavourite)")
        print("Is hidden: \(metaData.isHidden)")
        print("Location: \(String(describing: metaData.location))")
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
    
    func Step1ValidatonInput() -> Validation{
        
        if nameTF.text?.isEmpty ?? true  {
            return .invalid("You must enter valid service name in arabic".localized)
        }else {
            Global.share.new_Service.name = nameTF.text
        }
        if en_nameTF.text?.isEmpty ?? true  {
            return .invalid("You must enter valid service name in english".localized)
        }else {
            Global.share.new_Service.en_name = en_nameTF.text
        }
        if serivceTypeTF.text?.isEmpty ?? true  {
            return .invalid("You must enter valid service type".localized)
        }
        if priceTF.text!.isEmpty {
            return .invalid("You must enter valid price".localized)
        }else {
            Global.share.new_Service.price =  Double(priceTF.text ?? "0")
        }
        
        if cityTF.text!.isEmpty {
            return .invalid("You must enter valid city".localized)
        }
        if durationTF.text!.isEmpty {
            return .invalid("You must enter total duration".localized)
        }
        
        if totalDuration.text!.isEmpty {
            
            return .invalid("You must enter valid duration".localized)
        }else {
            Global.share.new_Service.total_duration = Double(totalDuration.text ?? "0.0")
        }
        if descrebtionTV.text!.isEmpty {
            
            return .invalid("You must enter service descreption in arabic".localized)
        }else {
            Global.share.new_Service.description_str = descrebtionTV.text
        }
        if en_descTV.text!.isEmpty {
            
            return .invalid("You must enter service descreption in english".localized)
        }else {
            Global.share.new_Service.en_description_str = en_descTV.text
        }
        if modelsPhotos.count == 0 {
            
            return .invalid("You must add service photos".localized)
        }
        
        if videoUrlTF.text?.count ?? 0 > 0 && !(videoUrlTF.text?.verifyUrl() ?? false) {
            return .invalid("Invalid video url".localized)
        }
        
        
        
        
        return .valid
    }
    
}




