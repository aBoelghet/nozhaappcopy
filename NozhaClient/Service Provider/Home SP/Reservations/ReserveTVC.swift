//
//  ReserveTVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/15/21.
//

import UIKit
import IBAnimatable
import SkeletonView

class ReserveTVC: UITableViewCell {
    
    @IBOutlet weak var scancodeView: AnimatableView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var noReservationsLbl: UILabel!
    @IBOutlet weak var noPeopleLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet var sk_views: [UIView]!
    @IBOutlet weak var skeltionView: UIView!
    @IBOutlet weak var currentLbl: UILabel!
    @IBOutlet weak var prevLbl: UILabel!
    @IBOutlet weak var resServiceNameLbl: UILabel!
    @IBOutlet weak var resOwnerLbl: UILabel!
    @IBOutlet weak var resImgv: AnimatableImageView!
    
    
    
    var reservation:Reservation?{
        didSet{
            resServiceNameLbl.text = reservation?.name ?? ""
            resOwnerLbl.text =  reservation?.organisers ?? ""
            resImgv.fetchingImage(url: reservation?.image ?? "")
            currentLbl.text = "\("Current".localized) (\(reservation?.current_reservations?.description.Pricing ?? "0"))"
            prevLbl.text =  "\("Previous".localized) (\(reservation?.previous_reservations?.description.Pricing ?? "0"))"
            skeltionView.isHidden = true
            for view in sk_views{
                view.hideSkeleton()
            }
            
        }
    }
    var res:ReservationInfo?{
        didSet{
            priceLbl.text = res?.price?.description.Pricing.valueWithCurrency ?? ""
            dateLbl.text = "\(res?.service_time?.workDate ?? "")|\(res?.service_time?.from ?? "")-\(res?.service_time?.to ?? "")"
            noReservationsLbl.text = res?.totalReservation?.description.Pricing
            noPeopleLbl.text = res?.totalPersons?.description.Pricing
            totalLbl.text = res?.totalAmounts?.description.Pricing.valueWithCurrency
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    @IBAction func allReservationsAction(_ sender: Any) {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AllReservationsVC") as! AllReservationsVC
        vc.reservationInfo =  self.res
        self.parentContainerViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func scanCodeAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : ScanQrVC = mainStoryboard.instanceVC()
        self.parentContainerViewController()?.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    @IBAction func currentReservationsAction(_ sender: Any) {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CurrentReservationsVC") as! CurrentReservationsVC
        vc.serviceId =  self.reservation?.id
        self.parentContainerViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func prevReservationsAction(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PreviousReservationsVC") as! PreviousReservationsVC
        vc.serviceId =  self.reservation?.id
        self.parentContainerViewController()?.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
