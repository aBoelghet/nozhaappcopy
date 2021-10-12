//
//  ServiceCVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/28/21.
//

import UIKit
import IBAnimatable
import SkeletonView

class ServiceCVC: UICollectionViewCell {
    
   
    @IBOutlet weak var statusView: AnimatableView!
    @IBOutlet weak var statusStackView: UIStackView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var rateView: UIStackView!
    @IBOutlet var sk_views: [UIView]!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var favBtn: AnimatableCheckBox!
    @IBOutlet weak var skeltonView: UIView!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var rateLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var imgServiceImgV: AnimatableImageView!
    
    var service: Service? {
        didSet {
            
            imgServiceImgV.fetchingImage(url: service?.image ?? "")
            categoryLbl.text = service?.categoryId?.name ?? ""
            if rateLbl != nil {
                rateLbl.text = service?.rates?.description.Pricing
            }
            if NozhaUtility.isCustomer() || !NozhaUtility.isLogin(){
                self.favBtn.isHidden = false
                favBtn.checked = self.service?.favorited ?? false
               
                if editBtn != nil {
                    self.editBtn.isHidden = true
                }
                if rateView != nil {
                    self.rateView.isHidden = false
                }
                if statusStackView != nil {
                    self.statusStackView.isHidden = true
                }
              
            }else {
                self.favBtn.isHidden = true
                if editBtn != nil {
                    self.editBtn.isHidden = false
                }
                if rateView != nil {
                    self.rateView.isHidden = true
                }
                if statusStackView != nil {
                    self.statusStackView.isHidden = false
                    if self.service?.approved ?? 0 == 1 {
                        
                        if self.service?.active ?? false {
                            self.statusLbl.text = "Enabled".localized
                            statusView.backgroundColor = Constants.acceptedColor
                            statusLbl.textColor = .white
                        }else {
                            self.statusLbl.text = "Disabled".localized
                            statusLbl.textColor = Constants.red_main
                            statusView.backgroundColor = Constants.CancelledColor
                        }
                    }else {
                        self.statusLbl.text = "pending".localized
                        statusView.backgroundColor = Constants.PendingColor
                        statusLbl.textColor = .white
                        
                    }
                   
                }
            }
            priceLbl.text = service?.price?.description.Pricing.valueWithCurrency
            nameLbl.text = service?.name ?? ""
            if skeltonView != nil {
            skeltonView.isHidden = true
            for view in sk_views{
                view.hideSkeleton()
            }
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        let gradient = SkeletonGradient(baseColor: UIColor.clouds)
        let animationType = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
        if skeltonView != nil {
        for view in sk_views{
            view.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animationType)
        }
        skeltonView.isHidden = false
        }
    }
    
    @IBAction func editActionHome(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc :EditServiceVC = mainStoryboard.instanceVC()
    
        vc.service = self.service
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.parentContainerViewController()?.navigationController?.present(vc, animated: true, completion: nil)
    }
    @IBAction func editAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc :EditServiceVC = mainStoryboard.instanceVC()
        let parent =  self.parentContainerViewController() as! ServicesVC
        vc.delegate = parent
        vc.service = self.service
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.parentContainerViewController()?.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func FavAction(_ sender: UIButton) {
        addOrRemoveFavClicked()
    }
    
    func addOrRemoveFavClicked(){
        if !NozhaUtility.isLogin() {
            self.parentContainerViewController()?.signIn()
            
            return
        }else {
            
            API.ADD_REMOVE_FAVOURITE.startRequest(nestedParams:service?.id?.description ?? "") { (Api, response) in
                
                if response.isSuccess {
                    if !(response.data is NSNull){
                        let value = response.data as! [String:Any]
                        let data_products = try! JSONSerialization.data(withJSONObject: value, options: [])
                        let service_obj = try! JSONDecoder().decode(Service.self, from:data_products)
                        let FavInfo = ["is_favorite": service_obj.favorited ?? false , "service_id": service_obj.id ?? 0 ] as [String : Any]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateServiceFavouraite"), object: self, userInfo: FavInfo)
                        if self.parentContainerViewController()?.isKind(of: CFavouriteVC.self) ?? false {
                            let vc =  self.parentContainerViewController() as? CFavouriteVC
                            let index =    vc?.favoraites?.firstIndex(where: {$0.id == service_obj.id})
                            vc?.favoraites?.remove(at: index!)
                            vc?.updateView()
                        }else{
                            self.service = service_obj
                        }
                        
                        
                    }
                    
                }else{
                    self.parentContainerViewController()?.showOkAlert(title: "", message: response.message)
                    
                }
                
            }
            
        }
    }
    
    
}
