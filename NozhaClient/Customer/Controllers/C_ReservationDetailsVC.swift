//
//  C_ReservationDetailsVC.swift
//  NozhaClient
//
//  Created by macbook on 21/02/2021.
//


import UIKit
import SkeletonView
import IBAnimatable
import goSellSDK
import class PassKit.PKPaymentToken
import  GoogleMaps

import CoreLocation

class C_ReservationDetailsVC: UIViewController {
    
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var reserTimeValLbl: UILabel!
    @IBOutlet weak var reservTimeLbl: UILabel!
    
    @IBOutlet weak var statusLb: UILabel!
    @IBOutlet weak var statusView: AnimatableView!
    @IBOutlet weak var total2Lbl: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var scanView: AnimatableView!
    @IBOutlet weak var payView: AnimatableView!
    
    @IBOutlet weak var rateView: AnimatableView!
    @IBOutlet weak var payBtn: UIButton!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var taxView: AnimatableView!
    @IBOutlet weak var rateBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet var mainSkelton: UIView!
    @IBOutlet var skeltonableViews: [UIView]!
    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var tableView: intrinsicTableView!
    @IBOutlet weak var taxLbl: UILabel!
    @IBOutlet weak var noPeopleLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var serviceNameLbl: UILabel!
    @IBOutlet weak var organiserLbl: UILabel!
    @IBOutlet weak var organiserImgV: AnimatableImageView!
    
    
    var reservation:Reservation?
    var reservationId:Int?
    
    
    
    let sandBoxSecretKey = "sk_test_3FqMKU8HeNwzxPcAjDQSZRTW"
    var yourProductionSecretKey = "sk_live_6BREZGAWXgQcJpOyNIFqD8nl"
    let session  = Session()
    
    
    var geocoder = CLGeocoder()
    let annotiation = GMSMarker()
    var manager = CLLocationManager()
    var serviceLocation:CLLocation? {
        didSet{
            self.setCurrentPostion(location: serviceLocation!)
        }
    }
    
    
    var timer = Timer()
    var timeLeft:TimeInterval = 0
    var hoursLeft = 0
    var minutesLeft = 0
    var secondsLeft = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if reservation != nil {
            reservationId = reservation?.id
        }
        self.addressLbl.text = "Go to location now".localized
        self.mainSkelton.isHidden = false
        let gradient = SkeletonGradient(baseColor: UIColor.clouds)
        let animationType = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
        for skelton_view  in skeltonableViews {
            skelton_view.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animationType)
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if reservation != nil {
            reservationId = reservation?.id
        }
        startReqestGetReservation()
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    @IBAction func goToGoogleMapAction(_ sender: Any) {
        
        
        let stringURL = "comgooglemaps://"
        // Checking Nil
        if !(self.reservation?.lat == nil) || !(self.reservation?.lng == nil) {
            if UIApplication.shared.canOpenURL(URL(string: stringURL)!) {
                // If have Google Map App Installed
                if let url = URL(string: "comgooglemaps://?saddr=&daddr=\(self.reservation?.lat ?? 0.0),\(self.reservation?.lng ?? 0.0)&directionsmode=driving") {
                    print (url)
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            } else {
                // If have no Google Map App (Run Browser Instead)
                if let destinationURL = URL(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\( self.reservation?.lat ?? 0.0),\(self.reservation?.lng ?? 0.0)&directionsmode=driving") {
                    UIApplication.shared.open(destinationURL, options: [:], completionHandler: nil)
                }
            }
        } else {
            self.showBunnerAlert(title: "", message: "There's no direction available for this location".localized)
            
        }
    }
    
    @IBAction func rateACtion(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "CMain", bundle: nil)
        let vc : RateVC = mainStoryboard.instanceVC()
        vc.reservation = self.reservation
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func scanAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "CMain", bundle: nil)
        let vc : CScanCodeVC = mainStoryboard.instanceVC()
        vc.reservation = self.reservation
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func payAction(_ sender: Any) {
        initTapPayment()
    }
    
    func setCurrentPostion(location :CLLocation){
        let cordicator = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
        mapView.moveCamera(GMSCameraUpdate.setCamera(GMSCameraPosition(latitude: cordicator.latitude, longitude: cordicator.longitude, zoom: 15
        )))
        
        
    }
}

extension C_ReservationDetailsVC {
    
    func FillData (){
        self.timerLbl.visibility = .invisible
        titleLbl.text = "\("Reservation details".localized) - #\(reservation?.uuid?.description ?? "")"
        reservTimeLbl.text =  reservation?.service?.type == "trip" ? "Trip time".localized :  "Event time".localized
        reserTimeValLbl.text = "\( self.reservation?.service_time?.workDate ?? "") | \( self.reservation?.service_time?.from ?? "")-\( self.reservation?.service_time?.to ?? "") "
        cityLbl.text = self.reservation?.cityId?.name ?? ""
        print ("city \(self.reservation?.service?.cityId?.name ?? "")")
        totalLbl.text = self.reservation?.totalAmount?.description.Pricing.valueWithCurrency
        total2Lbl.text = self.reservation?.totalAmount?.description.Pricing.valueWithCurrency
        
        if self.reservation?.tax ?? 0 > 0 {
            taxLbl.text = self.reservation?.tax?.description.Pricing.valueWithCurrency
        }else {
            taxView.isHidden =  true
        }
        noPeopleLbl.text = self.reservation?.personsCount?.description.Pricing
        priceLbl.text = self.reservation?.service?.price?.description.Pricing.valueWithCurrency
        dateLbl.text = self.reservation?.createdAt
        serviceNameLbl.text = self.reservation?.service?.name ?? ""
        organiserLbl.text = self.reservation?.service?.organisers?.description ?? ""
        organiserImgV.fetchingImage(url: self.reservation?.service?.image ?? "")
        if reservation?.service?.type == "event"  || self.reservation?.reservationQuestions?.count == 0{
            questionView.visibility = .gone
        }
        if !(reservation?.rated ?? false) && reservation?.status == "completed" {
            self.rateBtn.visibility = .visible
        }else {
            self.rateBtn.visibility = .invisible
        }
        checkStatus()
        
        self.serviceLocation =  CLLocation(latitude: CLLocationDegrees(self.reservation?.lat ?? 0), longitude: CLLocationDegrees(self.reservation?.lng ?? 0))
        
        let created = self.reservation?.accepted_at?.convertToDate(formatText: "yyyy-MM-dd HH:mm")
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
            statusLb.text = reservation?.status?.localized ?? ""
            statusView.backgroundColor = Constants.PendingColor
            statusLb.textColor = .white
            
            payView.isHidden = true
            rateView.isHidden = true
            scanView.isHidden = true
        }
        if reservation?.status == "accepted" {
            
            if reservation?.paid ?? false {
                payView.isHidden = true
                scanView.isHidden = false
                statusView.backgroundColor = Constants.acceptedColor
                statusLb.text = reservation?.status?.localized ?? ""
                statusLb.textColor = .white
            }else {
                payView.isHidden = false
                scanView.isHidden = true
                statusView.backgroundColor = Constants.WaittingPaymentColor
                statusLb.text = "Watting payment".localized
                statusLb.textColor = .white
                
            }
            rateView.isHidden = true
            
        }
        
        if reservation?.status == "completed" {
            statusLb.text = reservation?.status?.localized ?? ""
            statusLb.textColor = .white
            statusView.backgroundColor = Constants.CompletedColor
            payView.isHidden = true
            
            if !(reservation?.rated ?? false) {
                rateView.isHidden = false
            }else {
                rateView.isHidden = true
            }
            
            scanView.isHidden = true
        }
        if reservation?.status == "rejected"  ||  reservation?.status == "canceled" {
            statusLb.text = reservation?.status?.localized ?? ""
            statusLb.textColor = Constants.red_main
            statusView.backgroundColor = Constants.CancelledColor
            payView.isHidden = true
            rateView.isHidden = true
            scanView.isHidden = true
        }
        
    }
    func startReqestGetReservation()
    {
        API.RESERVATION_DETAILS.startRequest(showIndicator: false,nestedParams:(self.reservationId?.description)!) { (api, response) in
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
    

    
}
extension C_ReservationDetailsVC :UITableViewDataSource, UITableViewDelegate{
    
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


//payment methods
extension C_ReservationDetailsVC : SessionDataSource,SessionDelegate,_3DPaymentVerificationDelegate,SessionAppearance {
    
    private func startReqestConfirmPayment(tabid:String){
        
        
        var params  = [String:String]()
        params["charge_id"] = tabid
        
        API.CONFIRM_PAYMENT.startRequest(showIndicator:true, nestedParams: self.reservation?.id?.description ?? "",params:params) { (Api, response) in
            
            if response.isSuccess {
                let value = response.data as! [String:Any]
                
                let data_reservation = try! JSONSerialization.data(withJSONObject: value, options: [])
                let reservation_obj = try! JSONDecoder().decode(Reservation.self, from: data_reservation)
                self.reservation = reservation_obj
                self.FillData ()
                self.showOkAlert(title: "", message: response.message,completion: {
                })
                
            }else{
                self.showBunnerAlert(title: "", message: response.message)
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
        self.showIndicator()
    }
    
    func sessionHasStarted(_ session: SessionProtocol) {
        self.hideIndicator()
    }
    
    
    func sessionHasFailedToStart(_ session: SessionProtocol) {
        
        self.showBunnerAlert(title: "", message: "the payment session has failed")
        //        self.EndPaymentSession()
        self.hideIndicator()
        
    }
    func paymentFailed(with charge: Charge?, error: TapSDKError?, on session: SessionProtocol) {
        self.showBunnerAlert(title: "Payment Failed".localized, message: "")
        
    }
    
    func paymentSucceed(_ charge: Charge, on session: SessionProtocol) {
        self.startRequestAfter3Dpayment(byTapID: charge.identifier)
        //        self.EndPaymentSession()
    }
    
    func sessionCancelled(_ session: SessionProtocol) {
        
        self.showBunnerAlert(title: "", message: "the payment is canceled".localized)
        //        self.EndPaymentSession()
        self.hideIndicator()
        
    }
    
    
    func responseFromOurService(){
        
        initTapPayment()
        
    }
    
    //this delegate from 3D PaymentVerification will call affter enter code number
    func resultAfterVerification(tapResult: TapResult) {
        if tapResult.status {
            startRequestAfter3Dpayment(byTapID: tapResult.tapID)
        }else{
            self.showBunnerAlert(title: "", message: tapResult.message)
        }
    }
    
    
    func startRequestAfter3Dpayment(byTapID id:String){
        
        startReqestConfirmPayment(tabid:id)
        
    }
    
}


// MARK: - GMSMapViewDelegate
extension C_ReservationDetailsVC: GMSMapViewDelegate
{
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let latitude = mapView.camera.target.latitude
        let longitude = mapView.camera.target.longitude
        
        annotiation.title = "current_location".localized
        annotiation.icon = UIImage(named: "ic_pin")
        
        annotiation.map = mapView
        
        
        UIView.animate(withDuration: 1, animations: {
            self.annotiation.position = CLLocationCoordinate2D(latitude: self.serviceLocation?.coordinate.latitude ?? 0, longitude: self.serviceLocation?.coordinate.longitude ?? 0)
        }, completion:  { success in
            if success {
                // handle a successfully ended animation
            } else {
                // handle a canceled animation, i.e move to destination immediately
                self.annotiation.position = mapView.camera.target
            }
        })
        
    }
    
    
    
}



