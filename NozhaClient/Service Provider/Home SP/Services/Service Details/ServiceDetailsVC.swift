//
//  ServiceDetailsVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/15/21.
//

import UIKit
import ImageSlideshow
import Segmentio
import IBAnimatable
import SkeletonView
import  GoogleMaps
import Cosmos
import Branch

class ServiceDetailsVC: UIViewController, editServiceDelegate {
    
   
    
    @IBOutlet weak var reserveBtn: AnimatableButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var favBtn: AnimatableCheckBox!
    @IBOutlet var mainSkelton: UIView!
    @IBOutlet var skeltonableViews: [UIView]!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var segmentioView: Segmentio!
    @IBOutlet weak var tableView: intrinsicTableView!
    @IBOutlet weak var imageSlider: ImageSlideshow!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var noPersonsLbl: UILabel!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var organiserLbl: UILabel!
    @IBOutlet weak var organiserImgV: AnimatableImageView!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    
    var isDetails = true
    var service_obj : Service?
    var serviceId: Int?
    let pageNo = 1
    var paginate:Paginate?
    var isLoadMore = false
    var refreshControl :UIRefreshControl = UIRefreshControl()
    var rating:Ratings?
    var rates:[Rate]?
    override func viewDidLoad() {
        super.viewDidLoad()
        if service_obj != nil {
            self.serviceId = service_obj?.id
        }
        scrollView.delegate = self
        self.pageControl.isHidden = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapSlider))
        imageSlider.addGestureRecognizer(gestureRecognizer)
        
        self.mainSkelton.isHidden = false
        let gradient = SkeletonGradient(baseColor: UIColor.clouds)
        let animationType = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
        for skelton_view  in skeltonableViews {
            skelton_view.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animationType)
        }
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        startReqestGetService()
        startReqestGetServiceRates()
    }
    
    @objc func refreshData(){
        isLoadMore = false
        refreshControl.beginRefreshing()
        startReqestGetService()
        startReqestGetServiceRates()
        
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    
    
    func initSlider(){
        
        
        if #available(iOS 14.0, *) {
            pageControl.preferredIndicatorImage  = Constants.slider_unselected
            pageControl.setIndicatorImage(Constants.slider_selected,
                                          forPage: 0)
            pageControl.currentPageIndicatorTintColor = Constants.tab_select
            pageControl.pageIndicatorTintColor =  Constants.tab_unselect
            
            
        }
        imageSlider.slideshowInterval = 5.0
        imageSlider.contentScaleMode = .scaleAspectFill
        imageSlider.delegate = self
        
        if self.service_obj?.images?.count ?? 0 > 1 {
            imageSlider.pageIndicatorPosition =  .init(horizontal: .center, vertical: .customBottom(padding: 40))
            if #available(iOS 14.0, *) {
                imageSlider.pageIndicator = self.pageControl
                self.pageControl.isHidden = false
            } else {
                self.pageControl.isHidden = true
                
                let pageControl = LinePageControl()
                pageControl.currentPageIndicatorTintColor =  Constants.tab_select
                pageControl.pageIndicatorTintColor = UIColor.lightGray
                imageSlider.pageIndicator = pageControl
            }
        }
        
    }
    
    
    func initSliderData(){
        initSlider()
        
        var networkSources  = [SDWebImageSource]()
        for adv in self.service_obj?.images ?? [] {
            networkSources.append(SDWebImageSource(urlString: adv.image ?? "" ,placeholder: UIImage())!)
        }
        imageSlider.setImageInputs(networkSources)
        
    }
    @objc func didTapSlider() {
        imageSlider.presentFullScreenController(from: self)
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
            title: "Service details".localized, image: nil
        )
        
        let item2 = SegmentioItem(
            title: "Reviews".localized, image: nil
        )
        
        
        segmentioView.setup(
            content: [item1 ,item2],
            style: SegmentioStyle.onlyLabel,
            options: options
        )
        
        
        segmentioView.selectedSegmentioIndex = 0
        segmentioView.layer.borderColor = UIColor.white.cgColor
        
        
        
        segmentioView.valueDidChange = { [weak self] _, segmentIndex in
            
            self!.isDetails = segmentIndex == 0
            self?.tableView.reloadData()
            
        }
        
        
    }
    
    @IBAction func reserveServiceAction(_ sender: Any) {
        if !NozhaUtility.isLogin() {
            self.signIn()
            return
        }else {
            if !(self.service_obj?.complete_reservations ?? false)  {
                if self.service_obj?.available_people ?? 0 != 0  {
            let mainStoryboard = UIStoryboard(name: "CMain", bundle: nil)
            let vc :reserveServiceVC = mainStoryboard.instanceVC()
            vc.service = self.service_obj
            self.navigationController?.pushViewController(vc, animated: true)
                }else {
                    self.showBunnerAlert(title: "Attention".localized, message: "No any available reservations".localized)
                }
            }else {
                self.showBunnerAlert(title: "Attention".localized, message: "Sory the reservations are completed".localized)
            }
            
        }
            
    }
    @IBAction func editServiceAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc :EditServiceVC = mainStoryboard.instanceVC()
        vc.delegate = self
        vc.service = self.service_obj
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    func dialogDissmised(service:Service){
        self.service_obj = service
        self.FillData()
    }
    
    @IBAction func FavouriteAction(_ sender: Any) {
        addOrRemoveFavClicked()
    }
    
    func addOrRemoveFavClicked(){
        if !NozhaUtility.isLogin() {
            self.signIn()
            
            return
        }else {
            
            API.ADD_REMOVE_FAVOURITE.startRequest(nestedParams:service_obj?.id?.description ?? "") { (Api, response) in
                
                if response.isSuccess {
                    if !(response.data is NSNull){
                        let value = response.data as! [String:Any]
                        let data_products = try! JSONSerialization.data(withJSONObject: value, options: [])
                        let service = try! JSONDecoder().decode(Service.self, from:data_products)
                        let FavInfo = ["is_favorite": service.favorited ?? false , "service_id": service.id ?? 0 ] as [String : Any]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateServiceFavouraite"), object: self, userInfo: FavInfo)
                        self.service_obj?.favorited = service.favorited
                        
                    }
                    
                }else{
                    self.showOkAlert(title: "", message: response.message)
                    
                }
                
            }
            
        }
    }
    @IBAction func shareAction(_ sender: Any) {
        
        let branchUniversalObject: BranchUniversalObject = BranchUniversalObject(canonicalIdentifier: "\(service_obj?.id ?? 0)")
        branchUniversalObject.title = "\(self.service_obj?.name ?? "") "
        branchUniversalObject.contentDescription = "\(self.service_obj?.descriptionField ?? "")"
        branchUniversalObject.imageUrl = "\(self.service_obj?.image ?? "")"
        branchUniversalObject.contentMetadata.contentSchema = .commerceService
        branchUniversalObject.contentMetadata.customMetadata["id"] = self.service_obj?.id?.description ?? "0"
        branchUniversalObject.contentMetadata.customMetadata["supplier"] =   NozhaUtility.isCustomer() ? self.service_obj?.supplier?.id?.description ?? "0" : NozhaUtility.loadUser()?.id?.description ?? "0"
        branchUniversalObject.userCompletedAction(BranchStandardEvent.viewItem.rawValue)
        let linkProperties: BranchLinkProperties = BranchLinkProperties()
        linkProperties.feature = "sharing"
       
        linkProperties.addControlParam("$ios_url", withValue: "https://apps.apple.com/us/app/nozha-نزهة/id1553305973")
        linkProperties.addControlParam("$android_url", withValue: "https://play.google.com/store/apps/details?id=com.ibtikarat.nozhaapp")
        
        
        
        branchUniversalObject.getShortUrl(with: linkProperties) { (url, error) in
            if error == nil {
                let shareText = "\(self.service_obj?.name ?? "") \n \(url ?? "")"
                
                let activityController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
                
                activityController.completionWithItemsHandler = { (nil, completed, _, error) in
                    if completed {
                        print("completed")
                    } else {
                        print("cancled")
                    }
                }
                self.present(activityController, animated: true) {
                    print("presented")
                }
                print("got my Branch link to share: %@", url ?? "no url")
            }
        }
        

    }
    
}


extension ServiceDetailsVC :UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isDetails {
            return 1
        }
        if self.rates?.count ?? 0 > 0 {
        return (self.rates?.count ?? 0)+1
        }else {
            return 1
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isDetails {
            
            //for details
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceDescreptionTVC") as! ServiceDescreptionTVC
            cell.descriptionService = service_obj?.descriptionField ?? ""
            cell.serviceLocation =  CLLocation(latitude: CLLocationDegrees(service_obj?.lat ?? 0), longitude: CLLocationDegrees(service_obj?.lng ?? 0))
            cell.videoUrl = self.service_obj?.videoUrl ?? ""
            return cell
            
            
        }else{
            if self.rates?.count ?? 0 > 0 {
            if indexPath.row == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceReviewTVC") as! ServiceReviewTVC
                cell.rate.text = service_obj?.rates?.description.Pricing
                cell.total.text = service_obj?.ratesCount?.description.Pricing
                if self.rating != nil {
                    cell.setUpRatings(rateings:self.rating!)
                }
                return cell
            }else{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceRateTVC") as! ServiceRateTVC
                if self.rates?.count ?? 0 > 0 {
                    cell.setUpRate(rate:(self.rates?[indexPath.row-1])!)
                }
                return cell
            }
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "emptyRateTVC") as! emptyRateTVC
                return cell
            }
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    
}
extension ServiceDetailsVC {
    
    func FillData (){
        self.initSegmento()
        
        if NozhaUtility.isCustomer()  || !NozhaUtility.isLogin(){
            self.favBtn.isHidden = false
            self.editBtn.isHidden = true
            self.favBtn.checked = self.service_obj?.favorited ?? false
            self.reserveBtn.isHidden = false
        }else {
            self.editBtn.isHidden = false
            self.favBtn.isHidden = true
            self.reserveBtn.isHidden = true
        }
        favBtn.checked = self.service_obj?.favorited ?? false
        nameLbl.text = self.service_obj?.name
        categoryLbl.text = self.service_obj?.categoryId?.name
        organiserImgV.fetchingImage(url: "")
        organiserLbl.text = "\("Servie organiser: ".localized) \(self.service_obj?.organisers ?? "")"
        cityLbl.text = self.service_obj?.cityId?.name
        noPersonsLbl.text = self.service_obj?.peopleNumber?.description.Pricing
        priceLbl.text = self.service_obj?.price?.description.Pricing.valueWithCurrency
        durationLbl.text = "\(self.service_obj?.totalDuration?.description.Pricing ?? "0") \(self.service_obj?.durationId?.name ?? "")"
        initSliderData()
        
    }
    
    func startReqestGetService()
    {
        
        if NozhaUtility.isCustomer()  || !NozhaUtility.isLogin(){
            API.C_SERVICE.startRequest(nestedParams:(self.serviceId?.description)!,completion: response)
        }else {
            API.SP_SERVICE.startRequest(nestedParams:(self.serviceId?.description)!,completion: response)
        }
    }
    
    func response(api :API,statusResult :StatusResult){
        self.refreshControl.endRefreshing()
        if statusResult.isSuccess {
            let value = statusResult.data as! [String:Any]
            
            let data_service = try! JSONSerialization.data(withJSONObject: value, options: [])
            let service = try! JSONDecoder().decode(Service.self, from: data_service)
            self.service_obj = service
            self.tableView.reloadData()
            
            self.FillData ()
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.mainSkelton.isHidden = true
                for skelton_view  in self.skeltonableViews {
                    skelton_view.hideSkeleton()
                }
                
            }
        }
        else
        {
            self.showOkAlert(title: "", message: statusResult.message)
        }
    }
    
    
    func startReqestGetServiceRates()
    {
        
        if NozhaUtility.isCustomer() || !NozhaUtility.isLogin(){
            API.C_SERVICE.startRequest(nestedParams:("\(self.serviceId?.description ?? "0")/rates?main=\(pageNo)"),completion: responseRates)
        }else {
            API.SP_SERVICE.startRequest(nestedParams:("\(self.serviceId?.description ?? "0")/rates?main=\(pageNo)"),completion: responseRates)
        }
    }
    
    
    func responseRates(api :API,statusResult :StatusResult){
        self.refreshControl.endRefreshing()
        if statusResult.isSuccess {
            let value = statusResult.data as! [String:Any]
            
            let data_rate = try! JSONSerialization.data(withJSONObject: value, options: [])
            let rating = try! JSONDecoder().decode(Ratings.self, from: data_rate)
            self.rating = rating
            self.rates = rating.items
            self.tableView.reloadData()
            
            self.FillData ()
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.mainSkelton.isHidden = true
                for skelton_view  in self.skeltonableViews {
                    skelton_view.hideSkeleton()
                }
            }
        }
        else
        {
            self.showOkAlert(title: "", message: statusResult.message)
        }
    }
}


//image slider
extension ServiceDetailsVC: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        
        if #available(iOS 14.0, *) {
            var i = 0
            for _ in self.service_obj?.images ?? [] {
                
                if i  == page {
                    self.pageControl.setIndicatorImage(Constants.slider_selected,
                                                       forPage: i)
                    
                }else {
                    self.pageControl.setIndicatorImage(Constants.slider_unselected,
                                                       forPage: i)
                }
                i += 1
            }
            
        }
        
    }
}



