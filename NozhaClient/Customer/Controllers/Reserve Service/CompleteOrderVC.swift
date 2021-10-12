//
//  CompleteOrderVC.swift
//  NozhaClient
//
//  Created by macbook on 19/02/2021.
//

import UIKit
import IBAnimatable
import goSellSDK
import class PassKit.PKPaymentToken

class CompleteOrderVC: UIViewController {
    
    
    @IBOutlet weak var serviceNameLbl: UILabel!
    @IBOutlet weak var taxView: AnimatableView!
    @IBOutlet weak var noPersonLbl: UILabel!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var reserTotalLbl: UILabel!
    @IBOutlet weak var taxLbl: UILabel!
    @IBOutlet weak var servicePriceLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var organiserLbl: UILabel!
    @IBOutlet weak var placeLbl: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var pricesView: AnimatableTableView!
    
    let sandBoxSecretKey = "sk_test_3FqMKU8HeNwzxPcAjDQSZRTW"
    var yourProductionSecretKey = "sk_live_6BREZGAWXgQcJpOyNIFqD8nl"
    let session  = Session()
    
    var service:Service?
    var reservation:Reservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pricesView.isHidden = false
        servicePriceLbl.text = self.service?.price?.description.Pricing.valueWithCurrency
        if NozhaUtility.loadSetting()?.tax ?? 0 > 0 {
            taxView.visibility = .visible
            let tax = NozhaUtility.loadSetting()?.tax ?? 0
        let taxedPrice = (tax/100) * calculateTotal()
            taxLbl.text = taxedPrice.description.Pricing.valueWithCurrency
        }else{
            taxView.visibility = .invisible
        }
       
        reserTotalLbl.text = calculateTotalWithTax().description.Pricing.valueWithCurrency
        totalLbl.text = calculateTotalWithTax().description.Pricing.valueWithCurrency
        durationLbl.text =  "\(self.service?.selectedDate ?? "") | \(self.service?.selectedWorkTime ?? "")"
        organiserLbl.text = self.service?.organisers ?? ""
        placeLbl.text = self.service?.cityId?.name ?? ""
        loader.isHidden = true
        noPersonLbl.text = "\("No. persons".localized): \(self.service?.noPersons.description ?? "")"
        serviceNameLbl.text = self.service?.name ?? ""
    }
    
    
    func calculateTotal () -> Double{
        let no_per = Double(self.service?.noPersons ?? 0)
        let service = self.service?.price ?? 0.0
        let total_ser = no_per * service
        return (total_ser)
    }
    func calculateTotalWithTax () -> Double{
        let no_per = Double(self.service?.noPersons ?? 0)
        let service = self.service?.price ?? 0.0
        let tax = NozhaUtility.loadSetting()?.tax ?? 0
        let taxedPrice = (tax/100) * calculateTotal()
        let total_ser = no_per * service
        return (total_ser + taxedPrice)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    @IBAction func reserveCopletrAction(_ sender: Any) {
        startReservation()
    }
    
    func startReservation(){
        
        loader.isHidden = false
        var params = [String:String]()
        params["service_id"] =  self.service?.id?.description
        params["service_time_id"] = self.service?.selectedTime.description ?? ""
        params["reservation_date"] = self.service?.selectedDate ?? ""
        params["address"] = self.service?.address ?? ""
        params["lat"] =  self.service?.lat?.description ?? ""
        params["lng"] =  self.service?.lng?.description ?? ""
        params["persons_count"] =  self.service?.noPersons.description ?? ""
        params["type"] =  self.service?.type ?? ""
        
        if service?.questions?.count  ?? 0 > 0 {
            for qa in self.service!.questions! {
                params["question_answer[\(qa.id ?? 0)]"] =  qa.answer
                
            }
        }
        
        loader.startAnimating()
        loader.isHidden = false
        
        API.CREATE_RESERVATION.startRequest(showIndicator: true, params: params) { (Api,response) in
         
            if response.isSuccess {
                let value = response.data as! [String:Any]
                let data_service = try! JSONSerialization.data(withJSONObject: value, options: [])
                let reservation = try! JSONDecoder().decode(Reservation.self, from: data_service)
                self.reservation = reservation
                
                if self.service?.type == "event"
                {
                self.initTapPayment()
                    
                }else {
                let mainStoryboard = UIStoryboard(name: "CMain", bundle: nil)
                let vc :SuccessOrderVC = mainStoryboard.instanceVC()
                vc.reservation = reservation
              
                    self.navigationController?.present(vc, animated: true) {
                   
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.loader.isHidden = true
                    self.loader.stopAnimating()
                   
                }
                }
              
                
                
            }else{
                self.loader.isHidden = true
                self.loader.stopAnimating()
                self.showBunnerAlert(title: "", message: response.message)
            }
        }
        
    }
    
}
//payment methods
extension CompleteOrderVC : SessionDataSource,SessionDelegate,_3DPaymentVerificationDelegate,SessionAppearance {
    
    private func startReqestConfirmPayment(tabid:String){
        
        
        var params  = [String:String]()
        params["charge_id"] = tabid
        
        API.CONFIRM_PAYMENT.startRequest(showIndicator:true, nestedParams: self.reservation?.id?.description ?? "",params:params) { (Api, response) in
            self.loader.isHidden = true
            self.loader.stopAnimating()
            if response.isSuccess {
                let value = response.data as! [String:Any]
                
                let data_reservation = try! JSONSerialization.data(withJSONObject: value, options: [])
                let reservation_obj = try! JSONDecoder().decode(Reservation.self, from: data_reservation)
                
                self.showOkAlert(title: "", message: response.message,completion: {
                    let mainStoryboard = UIStoryboard(name: "CMain", bundle: nil)
                    let vc :SuccessOrderVC = mainStoryboard.instanceVC()
                    vc.reservation = reservation_obj
                   self.navigationController?.present(vc, animated: true) 
                })
              
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.loader.isHidden = true
                    self.loader.stopAnimating()
                   
                }
                
                
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
