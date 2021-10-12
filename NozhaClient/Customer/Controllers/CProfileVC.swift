//
//  CProfileVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/19/21.
//

import UIKit
import Segmentio
import IBAnimatable
import Fusuma

class CProfileVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, FusumaDelegate {
   
    
    @IBOutlet weak var NOTIFICATIONSCOUNTLBL: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var showmoreBtn: UIButton!
    @IBOutlet weak var tableView: intrinsicTableView!
    @IBOutlet weak var segmentio: Segmentio!
    @IBOutlet weak var userImageView: AnimatableImageView!
    @IBOutlet weak var scrollview: AnimatableScrollView!
    @IBOutlet weak var bgImgV: AnimatableImageView!
    
    var imagePicker: UIImagePickerController!
    
    var isCurrent:Bool = true
    var completedOrders :[Reservation]?
    var newOrders :[Reservation]?
    var refreshControl :UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.addTarget(self, action: #selector(refreshData), for: UIControl.Event.valueChanged)
        scrollview.refreshControl = refreshControl
        initSegmento()
        
        self.NOTIFICATIONSCOUNTLBL.isHidden = true
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "updateNotificationNumber"), object: nil, queue: nil) { (notification) in
            if (notification.userInfo as? [String: Any]) != nil
            {
                if self.isCurrent {
                    self.startRequestGetNewOrders()
                }
              
                if NozhaUtility.getNotificationNo()  == 0 {
                    self.NOTIFICATIONSCOUNTLBL.isHidden = true
                }else{
                    self.NOTIFICATIONSCOUNTLBL.isHidden = false
                    self.NOTIFICATIONSCOUNTLBL.text = "\(NozhaUtility.getNotificationNo() )"
                    return
                }
                
            }
            
        }
    }
    
    @objc func refreshData(){
        
        refreshControl.beginRefreshing()
        if NozhaUtility.isLogin() {
            if isCurrent {
                self.startRequestGetNewOrders()
            }else {
                self.startRequestGetCompletedOrders()
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if NozhaUtility.isLogin()
        {
            showmoreBtn.isHidden = false
            userNameLbl.text = NozhaUtility.loadUser()?.name
            self.tableView.reloadData()
            if NozhaUtility.loadUser()?.gender == "male" {
                userImageView.fetchingProfileImage(url: NozhaUtility.loadUser()?.image ?? "")
                bgImgV.image = UIImage(named:"male_bg")
            }else {
                userImageView.fetchingProfileImageFemale(url: NozhaUtility.loadUser()?.image ?? "")
                bgImgV.image = UIImage(named:"female_bg")
                
            }
            if NozhaUtility.loadUser()?.unreadNotifications ?? 0 > 0 {
                
                self.NOTIFICATIONSCOUNTLBL.isHidden = false
                self.NOTIFICATIONSCOUNTLBL.text = "\( NozhaUtility.loadUser()?.unreadNotifications ?? 0)"
            }
        }else {
            userImageView.image = UIImage(named: "img_profile")
            self.NOTIFICATIONSCOUNTLBL.isHidden = true
            userNameLbl.text = ""
            showmoreBtn.isHidden = true
            self.newOrders?.removeAll()
            self.completedOrders?.removeAll()
            self.tableView.reloadData()
        }
        if NozhaUtility.isLogin() {
            if isCurrent {
                self.startRequestGetNewOrders()
            }else {
                self.startRequestGetCompletedOrders()
            }
        }
    }
    
    func initSegmento(){
        
        let segmentState = SegmentioStates(
            defaultState: SegmentioState(
                backgroundColor: .clear,
                titleFont: Constants.appFont14Regular,
                titleTextColor: Constants.gray_main_color
            ),
            selectedState: SegmentioState(
                backgroundColor: .clear,
                titleFont:Constants.appFont14Regular,
                titleTextColor: Constants.black_main_color
            ),
            highlightedState: SegmentioState(
                backgroundColor: .clear,
                titleFont:Constants.appFont14Regular,
                titleTextColor: Constants.black_main_color
            )
        )
        
        
        let segmentioIndicatorOptions = SegmentioIndicatorOptions(type: .bottom, ratio: 1, height: 2, color: Constants.black_main_color)
        
        let horizontalSeparatorOptions  = SegmentioHorizontalSeparatorOptions(type: .none, height: 0, color: .clear)
        let verticalSeparatorOptions = SegmentioVerticalSeparatorOptions(ratio: 0, color: .clear)
        
        let options = SegmentioOptions(
            backgroundColor:.white,
            segmentPosition: SegmentioPosition.fixed(maxVisibleItems: 5),
            scrollEnabled: false,
            indicatorOptions: segmentioIndicatorOptions,
            horizontalSeparatorOptions: horizontalSeparatorOptions,
            verticalSeparatorOptions: verticalSeparatorOptions,
            labelTextAlignment: .center,
            segmentStates: segmentState
        )
        
        
        let item1 = SegmentioItem(
            title: "Current Reservations".localized, image: nil
        )
        
        let item2 = SegmentioItem(
            title: "Previous Reservations".localized, image: nil
        )
        
        
        segmentio.setup(
            content: [item1 ,item2],
            style: SegmentioStyle.onlyLabel,
            options: options
        )
        
        
        segmentio.selectedSegmentioIndex = 0
        segmentio.layer.borderColor = UIColor.white.cgColor
        
        
        
        segmentio.valueDidChange = { [weak self] _, segmentIndex in
            
            self!.isCurrent = segmentIndex == 0
            if  self!.isCurrent {
                
                if NozhaUtility.isLogin() {
                    self?.startRequestGetNewOrders()
                }
            }else{
                if NozhaUtility.isLogin() {
                    self?.startRequestGetCompletedOrders()
                }
            }
            self?.tableView.reloadData()
            
        }
        
        
    }
    @IBAction func showAllReservationsAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "CMain", bundle: nil)
        let vc : C_ReservationsListVC = mainStoryboard.instanceVC()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    @IBAction func changePicAction(_ sender: Any) {
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
    @IBAction func routeNotificationsAction(_ sender: Any) {
        if NozhaUtility.isLogin() {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc :NotificationsVC = mainStoryboard.instanceVC()
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
        }else {
            self.signIn()
        }
    }
    @IBAction func routeSettingAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "CMain", bundle: nil)
        let vc : CSettingsVC = mainStoryboard.instanceVC()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    @IBAction func loginAction(_ sender: Any) {
        self.signIn()
    }
    
}
extension CProfileVC: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if NozhaUtility.isLogin() {
        if isCurrent  {
            if newOrders?.count ?? 0 > 0 || newOrders == nil {
            return newOrders?.count ?? 10
            }else
            {
                return 1
            }
        }else {
            if completedOrders?.count ?? 0 > 0  || completedOrders == nil {
            return completedOrders?.count ?? 10
            }else{
                return 1
            }
        }
        }else {
            return 1
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if NozhaUtility.isLogin() {
        if isCurrent {
            if newOrders?.count ?? 0 > 0 || newOrders == nil {
            let cell: C_ReservationTVC = tableView.dequeueReusableCell(withIdentifier: "C_ReservationTVC", for: indexPath) as! C_ReservationTVC
            if newOrders?.count ?? 0 > 0 {
                cell.reservation = self.newOrders?[indexPath.row]
                cell.profileVC = self
            }
            return cell
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "emptyReservationTVC") as! emptyReservationTVC
                cell.setCell()
                return cell
            }
        }else {
            if self.completedOrders?.count ?? 0 > 0  || completedOrders == nil {
            let cell: C_ReservationTVC = tableView.dequeueReusableCell(withIdentifier: "C_ReservationTVC", for: indexPath) as! C_ReservationTVC
            if completedOrders?.count ?? 0 > 0 {
                cell.reservation = self.completedOrders?[indexPath.row]
                cell.profileVC = self
            }
            return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "emptyReservationTVC") as! emptyReservationTVC
                cell.setCell()
                return cell
            }
        }
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyReservationTVC") as! emptyReservationTVC
            cell.setCell()
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
    }
}



extension CProfileVC {
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
        self.userImageView.image = image
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
    
    
    func startRequestGetNewOrders(){
        
      
        self.showmoreBtn.isHidden = true
        var params = [String:Any]()
        params["filter"] = "current"
        API.C_RESERVATIONS.startRequest(showIndicator: true, params: params) { (api, statusResult) in
            self.refreshControl.endRefreshing()
            if statusResult.isSuccess {
                let value = statusResult.data  as! [String:Any]
                
                let ordersData = try! JSONSerialization.data(withJSONObject:value["items"]!, options: .prettyPrinted)
                self.newOrders = try! JSONDecoder().decode([Reservation].self, from: ordersData)
                
                self.tableView.reloadData()
                
                if self.newOrders?.count ?? 0 > 0  {
                    self.showmoreBtn.isHidden = false
                }else{
                    self.showmoreBtn.isHidden = true
                }
                
            }else{
                self.showOkAlert(title: "", message: statusResult.message)
            }
        }
    }
    
    func startRequestGetCompletedOrders(){
        if completedOrders?.count ?? 0 == 0 && completedOrders != nil {
            self.showmoreBtn.isHidden = true
        }else {
            self.showmoreBtn.isHidden = false
        }
        var params = [String:Any]()
        params["filter"] = "previous"
        API.C_RESERVATIONS.startRequest(showIndicator: true, params: params) { (api, statusResult) in
            self.refreshControl.endRefreshing()
            if statusResult.isSuccess {
                let value = statusResult.data  as! [String:Any]
                
                let ordersData = try! JSONSerialization.data(withJSONObject:value["items"]!, options: .prettyPrinted)
                self.completedOrders = try! JSONDecoder().decode([Reservation].self, from: ordersData)
                
                self.tableView.reloadData()
                
                if self.completedOrders?.count ?? 0 > 0  {
                    self.showmoreBtn.isHidden = false
                }else{
                    self.showmoreBtn.isHidden = true
                }
            }else{
                self.showOkAlert(title: "", message: statusResult.message)
            }
        }
    }
    
    
    
    
    
    
}


extension CProfileVC {
    
    
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
