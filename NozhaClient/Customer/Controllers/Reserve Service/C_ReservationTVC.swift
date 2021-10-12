//
//  C_ReservationTVC.swift
//  NozhaClient
//
//  Created by macbook on 19/02/2021.
//

import UIKit
import IBAnimatable
import goSellSDK
import class PassKit.PKPaymentToken
import SkeletonView

class C_ReservationTVC: UITableViewCell {
    
    @IBOutlet weak var mainSkelton: UIView!
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet var sk_views: [UIView]!
    @IBOutlet weak var payNowView: AnimatableView!
    @IBOutlet weak var ticketView: AnimatableView!
    @IBOutlet weak var rateView: AnimatableView!
    @IBOutlet weak var scanView: AnimatableView!
    @IBOutlet weak var totlaLbl: UILabel!
    @IBOutlet weak var servicePriceLbl: UILabel!
    @IBOutlet weak var serviceNameLbl: UILabel!
    @IBOutlet weak var organiserLbl: UILabel!
    @IBOutlet weak var serviceImgV: AnimatableImageView!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var statusView: AnimatableView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var noReserLbl: UILabel!
    
    
    let sandBoxSecretKey = "sk_test_3FqMKU8HeNwzxPcAjDQSZRTW"
    var yourProductionSecretKey = "sk_live_6BREZGAWXgQcJpOyNIFqD8nl"
    let session  = Session()
    
    var timer = Timer()
    var timeLeft:TimeInterval = 0
    var hoursLeft = 60
    var minutesLeft = 60
    var secondsLeft = 60
    var profileVC:CProfileVC?
    var reserListVC:C_ReservationsListVC?
    
    
    var reservation:Reservation?{
        didSet{
         fillData()
        }
        
    }
    
    func fillData(){
        serviceNameLbl.text = reservation?.service?.name ?? ""
        organiserLbl.text = reservation?.service?.organisers ?? ""
        serviceImgV.fetchingImage(url: reservation?.service?.image ?? "")
        dateLbl.text = reservation?.createdAt ?? ""
        servicePriceLbl.text = reservation?.service?.price?.description.Pricing.valueWithCurrency
        totlaLbl.text = reservation?.totalAmount?.description.Pricing.valueWithCurrency
        noReserLbl.text = "#\(reservation?.uuid?.description ?? "")"
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
        
        self.mainSkelton.isHidden = true
        for view in sk_views{
            view.hideSkeleton()
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
    
    func checkStatus(){
        if reservation?.status == "pending" {
            statusLbl.text = reservation?.status?.localized ?? ""
            statusView.backgroundColor = Constants.PendingColor
            statusLbl.textColor = .white
            
            payNowView.isHidden = true
            rateView.isHidden = true
            scanView.isHidden = true
        }
        if reservation?.status == "accepted" {
            
            if reservation?.paid ?? false {
                payNowView.isHidden = true
                scanView.isHidden = false
                statusView.backgroundColor = Constants.acceptedColor
                statusLbl.text = reservation?.status?.localized ?? ""
                statusLbl.textColor = .white
            }else {
                payNowView.isHidden = false
                scanView.isHidden = true
                statusView.backgroundColor = Constants.WaittingPaymentColor
                statusLbl.text = "Watting payment".localized
                statusLbl.textColor = .white
                
            }
            rateView.isHidden = true
           
        }
        
        if reservation?.status == "completed" {
            statusLbl.text = reservation?.status?.localized ?? ""
            statusLbl.textColor = .white
            statusView.backgroundColor = Constants.CompletedColor
            payNowView.isHidden = true
            
            if !(reservation?.rated ?? false) {
                rateView.isHidden = false
            }else {
                rateView.isHidden = true
            }
            
            scanView.isHidden = true
        }
        if reservation?.status == "rejected"  ||  reservation?.status == "canceled" {
            statusLbl.text = reservation?.status?.localized ?? ""
            statusLbl.textColor = Constants.red_main
            statusView.backgroundColor = Constants.CancelledColor
            payNowView.isHidden = true
            rateView.isHidden = true
            scanView.isHidden = true
        }
        self.updateConstraints()
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let gradient = SkeletonGradient(baseColor: UIColor.clouds)
        let animationType = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
        if mainSkelton != nil {
        for view in sk_views{
            view.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animationType)
        }
            mainSkelton.isHidden = false
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        timer.invalidate()
    }
    @IBAction func rateAction(_ sender: Any) {
        
        let mainStoryboard = UIStoryboard(name: "CMain", bundle: nil)
        let vc : RateVC = mainStoryboard.instanceVC()
        vc.reservation = self.reservation
        self.parentContainerViewController()?.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func scanAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "CMain", bundle: nil)
        let vc : CScanCodeVC = mainStoryboard.instanceVC()
        vc.reservation = self.reservation
        self.parentContainerViewController()?.navigationController?.present(vc, animated: true, completion: nil)
        
    }
    @IBAction func showTicketAction(_ sender: Any) {
        
        let mainStoryboard = UIStoryboard(name: "CMain", bundle: nil)
        let vc : C_ReservationDetailsVC = mainStoryboard.instanceVC()
        vc.reservation = self.reservation
        self.parentContainerViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func payAction(_ sender: Any) {
        initTapPayment()
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

//payment methods
extension C_ReservationTVC : SessionDataSource,SessionDelegate,_3DPaymentVerificationDelegate,SessionAppearance {
    
    private func startReqestConfirmPayment(tabid:String){
        
        
        var params  = [String:String]()
        params["charge_id"] = tabid
        
        API.CONFIRM_PAYMENT.startRequest(showIndicator:true, nestedParams: self.reservation?.id?.description ?? "",params:params) { (Api, response) in
            
            if response.isSuccess {
                let value = response.data as! [String:Any]
                
                let data_reservation = try! JSONSerialization.data(withJSONObject: value, options: [])
                let reservation_obj = try! JSONDecoder().decode(Reservation.self, from: data_reservation)
                self.reservation = reservation_obj
                self.fillData()
                if self.profileVC != nil {
                    let index =    self.profileVC?.newOrders?.firstIndex(where:  {$0.id == reservation_obj.id})
                    if index  != nil {
                    self.profileVC?.newOrders?[index!] = reservation_obj
                    }
                    self.profileVC?.tableView.reloadData()
                }
                if self.reserListVC != nil {
                    let index =    self.reserListVC?.newOrders?.firstIndex(where:  {$0.id == reservation_obj.id})
                    if index  != nil {
                    self.reserListVC?.newOrders?[index!] = reservation_obj
                    }
                    self.reserListVC?.tableView.reloadData()
                }
                self.updateConstraints()
                self.parentContainerViewController()?.showOkAlert(title: "", message: response.message,completion: {
                    
                })
                
            }else{
                self.parentContainerViewController()?.showBunnerAlert(title: "", message: response.message)
            }
        }
    }
    
    func sessionShouldShowStatusPopup(_ session: SessionProtocol) -> Bool
    {
        return false
    }
    
    var customer: Customer?{
        
        return newCustomer
    }
    
    var newCustomer: Customer {
        
        let user = NozhaUtility.loadUser()!
        let emailAddress = try! EmailAddress(emailAddressString: user.email ?? "")
        let userMobile = user.mobile?.trimmingCharacters(in: CharacterSet(charactersIn: "+966"))
        let phoneNumber = try! PhoneNumber(isdNumber: "966", phoneNumber: userMobile ?? "")
        
        
        return try! Customer(emailAddress:  emailAddress,
                             phoneNumber:   phoneNumber,
                             firstName:     user.name ?? "",
                             middleName:    nil,
                             lastName:      nil)
    }
    
    
    var currency: Currency? {
        
        return .with(isoCode: "SAR")
    }
    
    var amount: Decimal {
        return Decimal(self.reservation?.totalAmount ?? 0)
    }
    
    var require3DSecure: Bool{
        return true
    }
    
    var isSaveCardSwitchOnByDefault: Bool{
        return false
    }
    
    var mode: TransactionMode{
        return TransactionMode.purchase
    }
    
    func initTapPayment(){
        GoSellSDK.reset()
        let secretKey = SecretKey(sandbox: sandBoxSecretKey, production: yourProductionSecretKey)
        GoSellSDK.secretKey = secretKey
        GoSellSDK.mode = .production
        GoSellSDK.language = "en"//AppDelegate.shared.language
        
        session.dataSource = self
        session.delegate = self
        session.appearance = self
        startTapPayment()
    }
    
    func startTapPayment(){
        session.start()
    }
    var applePayMerchantID: String {
        return "merchant.com.ibtikarat.nozhaapp"
    }
    
    func sessionIsStarting(_ session: SessionProtocol) {
        self.parentContainerViewController()?.showIndicator()
    }
    
    func sessionHasStarted(_ session: SessionProtocol) {
        self.parentContainerViewController()?.hideIndicator()
    }
    
    
    func sessionHasFailedToStart(_ session: SessionProtocol) {
        
        self.parentContainerViewController()?.showBunnerAlert(title: "", message: "the payment session has failed")
        //        self.EndPaymentSession()
        self.parentContainerViewController()?.hideIndicator()
        
    }
    func paymentFailed(with charge: Charge?, error: TapSDKError?, on session: SessionProtocol) {
        self.parentContainerViewController()?.showBunnerAlert(title: "Payment Failed".localized, message: "")
        
    }
    
    func paymentSucceed(_ charge: Charge, on session: SessionProtocol) {
        self.startRequestAfter3Dpayment(byTapID: charge.identifier)
        //        self.EndPaymentSession()
    }
    
    func sessionCancelled(_ session: SessionProtocol) {
        
        self.parentContainerViewController()?.showBunnerAlert(title: "", message: "the payment is canceled".localized)
        //        self.EndPaymentSession()
        self.parentContainerViewController()?.hideIndicator()
        
    }
    
    
    func responseFromOurService(){
        
        initTapPayment()
        
    }
    
    //this delegate from 3D PaymentVerification will call affter enter code number
    func resultAfterVerification(tapResult: TapResult) {
        if tapResult.status {
            startRequestAfter3Dpayment(byTapID: tapResult.tapID)
        }else{
            self.parentContainerViewController()?.showBunnerAlert(title: "", message: tapResult.message)
        }
    }
    
    
    func startRequestAfter3Dpayment(byTapID id:String){
        
        startReqestConfirmPayment(tabid:id)
        
    }
    
}
