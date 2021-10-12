//
//  CHomeVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/19/21.
//

import UIKit
import ImageSlideshow
import SkeletonView
import IBAnimatable
import DropDown
import MOLH


class CHomeVC: UIViewController {
    
    @IBOutlet weak var cityBtn: UIButton!
    @IBOutlet weak var closeSearchBtn: UIButton!
    @IBOutlet weak var searchTF: AnimatableTextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var sliderSkelton: UIView!
    @IBOutlet weak var tableView: intrinsicTableView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var imageSlider: ImageSlideshow!
    
    var refreshControl :UIRefreshControl = UIRefreshControl()
    var returned =  true
    var home:C_Home?
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTF.isHidden = true
        scrollView.delegate = self
        self.pageControl.isHidden = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapSlider))
        imageSlider.addGestureRecognizer(gestureRecognizer)
        
        self.sliderSkelton.isHidden = false
        let gradient = SkeletonGradient(baseColor: UIColor.clouds)
        let animationType = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
        
        sliderSkelton.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animationType)
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: UIControl.Event.valueChanged)
        scrollView.refreshControl = refreshControl
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "pushReservations"), object: nil, queue: nil) { (notification) in
            let mainStoryboard = UIStoryboard(name: "CMain", bundle: nil)
            let vc :C_ReservationsListVC = mainStoryboard.instanceVC()
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "pushReservationDetails"), object: nil, queue: nil) { (notification) in
            
            let reservationId = notification.userInfo?["reservationId"] as? Int
            let mainStoryboard = UIStoryboard(name: "CMain", bundle: nil)
            let vc :C_ReservationDetailsVC = mainStoryboard.instanceVC()
            vc.reservationId = reservationId
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        
    }
    
    @IBAction func closeSearchAction(_ sender: Any) {
        closeSearchBtn.isHidden = true
        searchTF.text = ""
        searchTF.isHidden = true
        cityBtn.isHidden = false
        
    }
    @objc func refreshData(){
        refreshControl.beginRefreshing()
        startReqestGetHome()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        searchTF.isHidden = true
        closeSearchBtn.isHidden = true
        searchTF.text = ""
        cityBtn.setTitle( "\(Constants.cities.first(where: {$0.id == NozhaUtility.cityId()})?.name ?? "")  ", for: .normal)
        startReqestGetHome()
        
    }
    @IBAction func changeCityAction(_ sender: UIButton) {
        closeSearchBtn.isHidden = true
        searchTF.text = ""
        searchTF.isHidden = true
        
        let dropDown = DropDown()
        dropDown.anchorView = cityBtn
        dropDown.cellNib  = UINib(nibName: "CustomDropDownCell", bundle: nil)
        dropDown.textFont = Constants.appFont14Regular
        dropDown.width = 170
        dropDown.backgroundColor = UIColor.white
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.semanticContentAttribute =  .forceLeftToRight
        dropDown.customCellConfiguration  = { (index: Index, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? CustomDropdownCell else { return }
            cell.imageV.image = UIImage(named: "ic_checked_policy")
            if MOLHLanguage.isRTLLanguage() {
                cell.optionLabel.textAlignment = .right
            }else {
                cell.optionLabel.textAlignment = .left
            }
            if Constants.cities[index].id == NozhaUtility.cityId() {
            cell.imageV.isHidden = false
            }else {
                cell.imageV.isHidden = true
            }
        }
        dropDown.dataSource =  Constants.cities.map({($0.name ?? "")}) as [String]
        dropDown.selectionAction = { [weak self] (index, item) in
            self?.cityBtn.setTitle("\(Constants.cities[index].name ?? "")  ", for: .normal)
            NozhaUtility.setCityId(cityId:Constants.cities[index].id ?? 0)
            self?.startReqestGetHome()
            
        }
        dropDown.dismissMode = .onTap
        dropDown.direction = .bottom
        dropDown.show()
        
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
        imageSlider.contentScaleMode = .redraw
        imageSlider.delegate = self
        
        if self.home?.slider?.count ?? 0 > 1 {
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
        for adv in self.home?.slider ?? [] {
            networkSources.append(SDWebImageSource(urlString: adv.image ?? "" ,placeholder: UIImage())!)
        }
        imageSlider.setImageInputs(networkSources)
        
    }
    @objc func didTapSlider() {
        if  self.home?.slider?[imageSlider.currentPage].service_id != nil {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc :ServiceDetailsVC = mainStoryboard.instanceVC()
            vc.serviceId = self.home?.slider?[imageSlider.currentPage].service_id
            self.navigationController?.pushViewController(vc, animated: true)
        }else if self.home?.slider?[imageSlider.currentPage].url?.count  ?? 0 > 0  {
            let link = self.home?.slider?[imageSlider.currentPage].url ?? ""
            guard let url = URL(string:link )  else { return }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }else {
                
                guard let url = URL(string:"https://\(link)" )  else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        }else if self.home?.slider?[imageSlider.currentPage].category_id != nil  {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc :ServicesVC = mainStoryboard.instanceVC()
            vc.catId = self.home?.slider?[imageSlider.currentPage].category_id
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }
    
    
    @IBAction func SearchAction(_ sender: Any) {
        searchTF.isHidden = false
        closeSearchBtn.isHidden = false
        cityBtn.isHidden = true
    }
    
    
    
    
}

extension CHomeVC: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 ||  indexPath.row == 2 {
            let cell: ServiceTVC = tableView.dequeueReusableCell(withIdentifier: "ServiceTVC", for: indexPath) as! ServiceTVC
            
            if indexPath.row == 0 {
                cell.browseBtn.tag = 1
                cell.nameLbl.text = "Near of you activities".localized
                if (self.home?.nearServices != nil)  {
                    cell.services = self.home?.nearServices
                }
            }else{
                cell.browseBtn.tag = 2
                cell.nameLbl.text = "Most ordered activities".localized
                if (self.home?.mostOrdered != nil)  {
                    cell.services = self.home?.mostOrdered
                }
            }
            
            return cell
        }else {
            let cell: CategoryTVC = tableView.dequeueReusableCell(withIdentifier: "CategoryTVC", for: indexPath) as! CategoryTVC
            if (self.home?.categories != nil)  {
                cell.cats = self.home?.categories
            }
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0  || indexPath.row == 2 {
            if indexPath.row == 0 && self.home?.nearServices?.count == 0 {
                return 60
            }else if indexPath.row == 0 && self.home?.nearServices?.count ?? 0 >  0 {
                return 335
            }
            else if indexPath.row == 2 && self.home?.mostOrdered?.count == 0 {
                return 60
            }else {
                return 335
            }
        } else{
            return 85
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
    }
    
}


extension CHomeVC {
    func startReqestGetHome()
    {
        
        var params = [String:String]()
        params["city_id"] = NozhaUtility.cityId().description
       
        
        API.C_HOME.startRequest(params: params, completion: response)
    }
    func response(api :API,statusResult :StatusResult){
        self.hideIndicator()
        refreshControl.endRefreshing()
        if statusResult.isSuccess {
            
            if !(statusResult.data is NSNull)
            {
                let value = statusResult.data as! [String:Any]
                let data = try! JSONSerialization.data(withJSONObject: value, options: [])
                let data_home = try! JSONDecoder().decode(C_Home.self, from: data)
                self.home = data_home
                initSliderData()
                self.tableView.reloadData()
                sliderSkelton.isHidden = true
                
                
            }else{
                self.showOkAlert(title: "", message: statusResult.message)
            }
        }
        
    }
}
//image slider
extension CHomeVC: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        
        if #available(iOS 14.0, *) {
            var i = 0
            for _ in self.home?.slider ?? [] {
                
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

extension CHomeVC: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print( string.cString(using: String.Encoding.utf8)!)
        print( string)
        if string == "\n" {
            returned = false
            self.view.endEditing(true)
            if textField.text?.count ?? 0 > 0 {
            let mainStoryboard = UIStoryboard(name: "CMain", bundle: nil)
            let vc :SearchServiceVC = mainStoryboard.instanceVC()
            vc.searchKeyword = textField.text
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
            }
        }
        
        return true
    }
    
}

