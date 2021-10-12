//
//  CurrentReservationTVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/16/21.
//

import UIKit
import IBAnimatable
import SkeletonView

class CurrentReservationTVC: UITableViewCell {
    
    @IBOutlet weak var declineView: AnimatableView!
    @IBOutlet weak var acceptLbl: UILabel!
    @IBOutlet weak var acceptView: AnimatableView!
    
    @IBOutlet weak var no_prersonsLbl: UILabel!
    @IBOutlet weak var c_nameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var c_ImgV: AnimatableImageView!
    @IBOutlet var sk_views: [UIView]!
    @IBOutlet weak var skeltionView: UIView!
    
    var vc_AllReservationsVC: AllReservationsVC?
    
    var reservation:Reservation?{
        didSet{
            c_nameLbl.text = reservation?.customer?.name ?? ""
            c_ImgV.fetchingImage(url: reservation?.customer?.image ?? "")
            priceLbl.text = "\("Reservation price:".localized) \(reservation?.totalAmount?.description.Pricing.valueWithCurrency ?? "0.0")"
            no_prersonsLbl.text = "\("Persons count :".localized) \(reservation?.personsCount?.description.Pricing ?? "0.0")"
            checkStatus()
            skeltionView.isHidden = true
            for view in sk_views{
                view.hideSkeleton()
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let gradient = SkeletonGradient(baseColor: UIColor.clouds)
        let animationType = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
        for view in sk_views{
            view.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animationType)
        }
        
        skeltionView.isHidden = false
        
    }
    func checkStatus()
    {
        if reservation?.status == "pending" {
            acceptLbl.text = "Accept reservation".localized
            self.acceptView.visibility = .visible
            self.declineView.visibility = .visible
        }
        if reservation?.status == "accepted"
        {
            
            if reservation?.paid ?? false {
                acceptLbl.text = "Confirm attendance".localized
                self.acceptView.visibility = .visible
                self.declineView.visibility = .invisible
            }else {
                
                self.acceptView.visibility = .gone
                self.declineView.visibility = .gone
                
            }
           
            
        }
        
        if reservation?.status == "completed" {
            
            self.acceptView.visibility = .gone
            self.declineView.visibility = .gone
            
        }
        if reservation?.status == "rejected"  ||  reservation?.status == "canceled" {
            
            self.acceptView.visibility = .gone
            self.declineView.visibility = .gone
        }
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func acceptAction(_ sender: Any) {
        if reservation?.status == "accepted"  {
            confirmReservation()
        } else {
            acceptReservation()
        }
    }
    @IBAction func declineAction(_ sender: Any) {
        declineReservation()
    }
    
}


extension CurrentReservationTVC {
    
    
    func acceptReservation(){
        self.parentContainerViewController()?.showIndicator()
        API.SP_RESERVATIONS_POST.startRequest(nestedParams:"\(self.reservation?.id?.description ?? "")/accept",completion: response)
    }
    func declineReservation(){
        self.parentContainerViewController()?.showIndicator()
        API.SP_RESERVATIONS_POST.startRequest(nestedParams: "\(self.reservation?.id?.description ?? "")/cancel",completion: response)
    }
    func confirmReservation(){
        self.parentContainerViewController()?.showIndicator()
        API.SP_RESERVATIONS_POST.startRequest(nestedParams: "\(self.reservation?.id?.description ?? "")/complete",completion: response)
    }
    func response(api :API,statusResult :StatusResult){
        self.parentContainerViewController()?.hideIndicator()
        if statusResult.isSuccess {
            
            if !(statusResult.data is NSNull)
            {
                self.parentContainerViewController()?.showBunnerSuccessAlert(title: "", message: statusResult.message, completion: nil)
                self.vc_AllReservationsVC?.startReqestGetReservations()
            }
            
        }else{
            self.parentContainerViewController()?.showOkAlert(title: "", message: statusResult.message)
        }
    }
    
}
