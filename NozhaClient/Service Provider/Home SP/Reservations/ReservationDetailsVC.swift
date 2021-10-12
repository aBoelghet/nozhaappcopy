//
//  ReservationDetailsVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/16/21.
//

import UIKit
import SkeletonView
import IBAnimatable

class ReservationDetailsVC: UIViewController {
    @IBOutlet weak var customerMobile: UILabel!
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var customerNameLbl: UILabel!
    @IBOutlet weak var customerImg: AnimatableImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var reserTimeValLbl: UILabel!
    @IBOutlet weak var reservTimeLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var statusView: AnimatableView!
    @IBOutlet var mainSkelton: UIView!
    @IBOutlet var skeltonableViews: [UIView]!
    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var confirmBtn: AnimatableButton!
    @IBOutlet weak var tableView: intrinsicTableView!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var taxLbl: UILabel!
    @IBOutlet weak var noPeopleLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var serviceNameLbl: UILabel!
    @IBOutlet weak var organiserLbl: UILabel!
    @IBOutlet weak var taxView: AnimatableView!
    
    
    var reservation:Reservation?
    var reservationId:Int?
    
    var timer = Timer()
    var timeLeft:TimeInterval = 0
    var hoursLeft = 60
    var minutesLeft = 60
    var secondsLeft = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if reservation != nil {
            reservationId = reservation?.id
        }
        
        self.mainSkelton.isHidden = false
        let gradient = SkeletonGradient(baseColor: UIColor.clouds)
        let animationType = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
        for skelton_view  in skeltonableViews {
            skelton_view.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animationType)
        }
        startReqestGetReservation()
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    
    @IBAction func confirmAttendanceAction(_ sender: Any) {
        confirmReservation()
    }
    
}

extension ReservationDetailsVC {
    
    func FillData (){
        
        titleLbl.text = "\("Reservation details".localized) - #\(reservation?.uuid?.description ?? "")"
        self.customerImg.fetchingImage(url: self.reservation?.customer?.image ?? "")
        self.customerMobile.text = self.reservation?.customer?.mobile ?? ""
        self.customerNameLbl.text = self.reservation?.customer?.name ?? ""
        reservTimeLbl.text =  reservation?.service?.type == "trip" ? "Trip time".localized :  "Event time".localized
        reserTimeValLbl.text = "\( self.reservation?.service_time?.workDate ?? "") | \( self.reservation?.service_time?.from ?? "")-\( self.reservation?.service_time?.to ?? "") "
        totalLbl.text = self.reservation?.totalAmount?.description.Pricing.valueWithCurrency
        taxLbl.text = self.reservation?.tax?.description.Pricing.valueWithCurrency
        noPeopleLbl.text = self.reservation?.personsCount?.description
        priceLbl.text = self.reservation?.service?.price?.description.Pricing.valueWithCurrency
        dateLbl.text = self.reservation?.createdAt
        serviceNameLbl.text = self.reservation?.service?.name ?? ""
        organiserLbl.text = self.reservation?.service?.organisers?.description ?? ""
        checkStatus()
        if reservation?.service?.type == "event" || self.reservation?.reservationQuestions?.count == 0{
            questionView.visibility = .gone
        }
       
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
        self.tableView.reloadData()
    }
    
    func checkStatus(){
        if reservation?.status == "pending" {
            statusLbl.text = reservation?.status?.localized ?? ""
            statusLbl.textColor = .white
            statusView.backgroundColor = Constants.PendingColor
            self.confirmBtn.visibility = .invisible
        }
        if reservation?.status == "accepted" {
           
            if reservation?.paid ?? false {
                statusView.backgroundColor = Constants.acceptedColor
                statusLbl.text = reservation?.status?.localized
                statusLbl.textColor = .white
                self.confirmBtn.visibility = .visible
            }else {
                
                statusView.backgroundColor = Constants.WaittingPaymentColor
                statusLbl.text = "Watting payment".localized
                statusLbl.textColor = .white
                self.confirmBtn.visibility = .invisible
                
            }
           
        }
        
        if reservation?.status == "completed" {
            statusLbl.text = reservation?.status?.localized ?? ""
            statusLbl.textColor = .white
            statusView.backgroundColor = Constants.CompletedColor
            self.confirmBtn.visibility = .invisible
      
        }
        if reservation?.status == "rejected"  ||  reservation?.status == "canceled" {
            statusLbl.text = reservation?.status?.localized ?? ""
            statusLbl.textColor = Constants.red_main
            statusView.backgroundColor = Constants.CancelledColor
            self.confirmBtn.visibility = .invisible
        }
        
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
    
    func startReqestGetReservation()
    {
        API.SP_RESERVATION.startRequest(showIndicator: false,nestedParams:(self.reservationId?.description)!) { (api, response) in
            if response.isSuccess {
                let value = response.data as! [String:Any]
                
                let data_reservation = try! JSONSerialization.data(withJSONObject: value, options: [])
                let reservation_obj = try! JSONDecoder().decode(Reservation.self, from: data_reservation)
                self.reservation = reservation_obj
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
                self.showOkAlert(title: "", message: response.message)
            }
        }
    }
    
    func confirmReservation(){
        API.SP_RESERVATIONS_POST.startRequest(showIndicator:true ,nestedParams: "\(self.reservation?.id?.description ?? "")/complete",completion: response)
    }
    func response(api :API,statusResult :StatusResult){
        
        if statusResult.isSuccess {
            
            if !(statusResult.data is NSNull)
            {
                self.showBunnerSuccessAlert(title: "", message: statusResult.message, completion: nil)
            }
            
        }else{
            self.showOkAlert(title: "", message: statusResult.message)
        }
    }
    
    
}
extension ReservationDetailsVC :UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return reservation?.reservationQuestions?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"ResQuestionTVC") as! ResQuestionTVC
        
        if reservation?.reservationQuestions?.count ?? 0 > 0 {
            cell.question = reservation?.reservationQuestions?[indexPath.row]
        }
        return cell
        
        
    }
    
    
}

