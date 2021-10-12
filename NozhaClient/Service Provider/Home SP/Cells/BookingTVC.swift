//
//  BookingTVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/13/21.
//

import UIKit
import IBAnimatable
import SkeletonView

class BookingTVC: UITableViewCell {
    
    
    
    @IBOutlet weak var taxView: AnimatableView!
    @IBOutlet weak var acceptView: AnimatableView!
    @IBOutlet weak var declineView: AnimatableView!
    @IBOutlet weak var statusView: AnimatableView!
    @IBOutlet weak var skeltonView: UIView!
    @IBOutlet weak var acceptBtn: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var taxLbl: UILabel!
    @IBOutlet weak var noAttendanceLbl: UILabel!
    @IBOutlet weak var servicePriceLbl: UILabel!
    @IBOutlet weak var serviceNameLbl: UILabel!
    @IBOutlet weak var supplierLbl: UILabel!
    @IBOutlet weak var serviceImgV: AnimatableImageView!

    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var noBookLbl: UILabel!
    @IBOutlet weak var headerStackView: UIStackView!
    
    
    var reservation:Reservation?
    var viewcontroller:HomeVC?
    var viewcontroller_ALLReservatioons:S_reservationsListVC?

    
    var timer = Timer()
    var timeLeft:TimeInterval = 0
    var hoursLeft = 60
    var minutesLeft = 60
    var secondsLeft = 60
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let gradient = SkeletonGradient(baseColor: UIColor.clouds)
        let animationType = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
        skeltonView.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animationType)
        skeltonView.isHidden = false
        
    }
    
    func setupReservation(res:Reservation){
        self.reservation = res
        totalLbl.text = res.totalAmount?.description.Pricing.valueWithCurrency
        noAttendanceLbl.text = res.personsCount?.description ?? ""
        serviceImgV.fetchingImage(url: res.service?.image ?? "")
        serviceNameLbl.text = res.service?.name ?? ""
        supplierLbl.text = res.service?.organisers ?? ""
        servicePriceLbl.text = res.service?.price?.description.Pricing.valueWithCurrency
       
        if reservation?.tax ?? 0 > 0 {
            taxView.isHidden = false
            taxLbl.text = res.tax?.description.Pricing.valueWithCurrency
        }else{
            taxView.isHidden = true
        }
        dateLbl.text = res.createdAt?.description
        noBookLbl.text = res.uuid?.description
        
     
        checkStatus()
        
        let created = self.reservation?.accepted_at?.convertToDate(formatText: "yyyy-MM-dd HH:mm:ss")
        print("Created \(created ?? Date())")
        
        let ended = created?.addingTimeInterval(10800)
        print("ended \(ended ?? Date())")
        
        let serverTime = self.reservation?.server_time?.convertToDate(formatText: "yyyy-MM-dd HH:mm:ss")
        
        let diffComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: serverTime ?? Date(), to: ended ?? Date())
        
        self.hoursLeft = diffComponents.hour ?? 0
        self.minutesLeft = diffComponents.minute ?? 0
        self.secondsLeft = diffComponents.second ?? 0
        self.timerLbl.visibility = .invisible
        if ( self.hoursLeft > 0 || self.minutesLeft   > 0 || self.secondsLeft > 0 ) && reservation?.status == "accepted" &&
            !(reservation?.paid ?? false)   {
            
            startTimer(for: ended ?? Date())
        }else {
            timer.invalidate()
        }
        skeltonView.isHidden = true
    }
    
    func startTimer(for tripDate: Date)
    {
        
        let serverTime = self.reservation?.server_time?.convertToDate(formatText: "yyyy-MM-dd HH:mm:ss") ?? Date()
        let diffComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: serverTime , to: tripDate )
        if let hours = diffComponents.hour
        {
            hoursLeft = hours
        }
        if let minutes = diffComponents.minute
        {
            minutesLeft = minutes
        }
        if let seconds = diffComponents.second
        {
            secondsLeft = seconds
        }
        if tripDate > serverTime
        {
            
            timer = Timer.scheduledTimer(timeInterval: 1.00, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
        }
        else
        {    self.timerLbl.visibility = .invisible
            timerLbl.text = "00:00:00"
        }
        
    }
    
    @objc func onTimerFires()
    {
        secondsLeft -= 1
        
        if (hoursLeft > 0 || minutesLeft  > 0 || secondsLeft  > 0 ) &&
            reservation?.status == "accepted" &&
            !(reservation?.paid ?? false)   {
       
        timerLbl.text = String(format: "%02d:%02d:%02d", hoursLeft, minutesLeft, secondsLeft)
        self.timerLbl.visibility = .visible
        }else {
            self.timerLbl.visibility = .invisible
        }
        if secondsLeft <= 0 {
            if minutesLeft != 0
            {
                secondsLeft = 59
                minutesLeft -= 1
            }
        }
        
        if minutesLeft <= 0 {
            if hoursLeft != 0
            {
                minutesLeft = 59
                hoursLeft -= 1
            }
        }
        
        if(hoursLeft == 0 && minutesLeft == 0 && secondsLeft == 0)
        {
            timer.invalidate()
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        timer.invalidate()
    }
  
    
    func checkStatus(){
        if reservation?.status == "pending" {
            acceptBtn.text = "Accept reservation".localized
            statusLbl.text = reservation?.status?.localized ?? ""
            statusView.backgroundColor = Constants.PendingColor
            statusLbl.textColor = .white
           
            acceptView.visibility = .visible
            declineView.visibility = .visible
        }
        if reservation?.status == "accepted" {
            
            if reservation?.paid ?? false {
                acceptBtn.text = "Confirm attendance".localized
                statusView.backgroundColor = Constants.acceptedColor
                statusLbl.text = reservation?.status?.localized ?? ""
                statusLbl.textColor = .white
                acceptView.visibility = .visible
                declineView.visibility = .invisible
            }else {
                
                statusView.backgroundColor = Constants.WaittingPaymentColor
                statusLbl.text = "Watting payment".localized
                statusLbl.textColor = .white
                acceptView.visibility = .gone
                declineView.visibility = .gone
                
            }
           
        }
        
        if reservation?.status == "completed" {
            statusLbl.text = reservation?.status?.localized ?? ""
            statusLbl.textColor = .white
            statusView.backgroundColor = Constants.CompletedColor
            acceptView.visibility = .gone
            declineView.visibility = .gone
      
        }
        if reservation?.status == "rejected"  ||  reservation?.status == "canceled" {
            statusLbl.text = reservation?.status?.localized ?? ""
            statusLbl.textColor = Constants.red_main
            statusLbl.textColor = Constants.red_main
            statusView.backgroundColor = Constants.CancelledColor
            acceptView.visibility = .gone
            declineView.visibility = .gone
        }
        
    }
    
    
    @IBAction func declineAction(_ sender: Any) {
        declineReservation()
    }
    @IBAction func acceptReservationAction(_ sender: Any) {
        if reservation?.status == "accepted" {
            confirmReservation()
        } else {
            acceptReservation()
        }
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
extension BookingTVC {
    
    func confirmReservation(){
        self.parentContainerViewController()?.showIndicator()
        API.SP_RESERVATIONS_POST.startRequest(nestedParams: "\(self.reservation?.id?.description ?? "")/complete",completion: response)
    }
    func acceptReservation(){
        self.parentContainerViewController()?.showIndicator()
        API.SP_RESERVATIONS_POST.startRequest(showIndicator:true,nestedParams:"\(self.reservation?.id?.description ?? "")/accept",completion: response)
    }
    func declineReservation(){
        API.SP_RESERVATIONS_POST.startRequest(showIndicator:true,nestedParams: "\(self.reservation?.id?.description ?? "")/cancel",completion: response)
    }
   
    func response(api :API,statusResult :StatusResult){
        self.parentContainerViewController()?.hideIndicator()
        if statusResult.isSuccess {
            
            if !(statusResult.data is NSNull)
            {
                self.parentContainerViewController()?.showBunnerSuccessAlert(title: "", message: statusResult.message, completion: nil)
                if viewcontroller != nil {
                self.viewcontroller?.startReqestGetHome()
                }
                if viewcontroller_ALLReservatioons != nil {
                self.viewcontroller_ALLReservatioons?.startRequestGetReservations()
                }
                
              
                }
                
            }else{
                self.parentContainerViewController()?.showOkAlert(title: "", message: statusResult.message)
            }
        }
   
}
