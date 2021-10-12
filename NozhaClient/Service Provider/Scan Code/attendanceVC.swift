//
//  attendanceVC.swift
//  NozhaClient
//
//  Created by mac book air on 2/11/21.
//

import UIKit
import IBAnimatable

class attendanceVC: UIViewController
{
    @IBOutlet weak var confirmBtn: AnimatableButton!
    @IBOutlet weak var taxLbl: UILabel!
    @IBOutlet weak var taxView: AnimatableView!
    @IBOutlet weak var userMobileLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userImgV: AnimatableImageView!
    @IBOutlet weak var noPersonsLbl: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var srvicePriceLbl: UILabel!
    @IBOutlet weak var serviceNameLbl: UILabel!
    @IBOutlet weak var organiserLbl: UILabel!
    @IBOutlet weak var noReservationLbl: UILabel!
    @IBOutlet weak var statusView: AnimatableView!
    @IBOutlet weak var statusLbl: UILabel!
    var reservation:Reservation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addBlurredBackground(style: UIBlurEffect.Style.light)
        userMobileLbl.text = reservation?.customer?.mobile ?? ""
        userNameLbl.text = reservation?.customer?.name ?? ""
        userImgV.fetchingImage(url: reservation?.customer?.image ?? "")
        noPersonsLbl.text = reservation?.personsCount?.description
        totalLbl.text = reservation?.totalAmount?.description.Pricing.valueWithCurrency
        srvicePriceLbl.text = reservation?.service?.price?.description.Pricing.valueWithCurrency
        serviceNameLbl.text = reservation?.service?.name ?? ""
        organiserLbl.text = reservation?.service?.organisers?.description
        noReservationLbl.text = "#\(reservation?.uuid?.description ?? "")"
        checkStatus()
        if reservation?.tax ?? 0 > 0 {
            taxView.isHidden = false
            taxLbl.text = reservation?.tax?.description.Pricing.valueWithCurrency
        }else{
            taxView.isHidden = true
        }
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
                statusLbl.textColor = .white
                statusLbl.text = reservation?.status?.localized
                self.confirmBtn.visibility = .visible
            }else {
                
                statusView.backgroundColor = Constants.WaittingPaymentColor
                statusLbl.textColor = .white
                statusLbl.text = "Watting payment".localized
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
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss()
    }
    
    @IBAction func confirmAttendanceAction(_ sender: Any) {
        confirmReservation()
    }
    
    func confirmReservation(){
        API.SP_RESERVATIONS_POST.startRequest(showIndicator:true,nestedParams: "\(self.reservation?.id?.description ?? "")/complete",completion: response)
    }
    func response(api :API,statusResult :StatusResult){
        
        if statusResult.isSuccess {
            
            if !(statusResult.data is NSNull)
            {
                self.showBunnerSuccessAlert(title: "", message: statusResult.message, completion: nil)
                self.dismiss()
            }
            
        }else{
            self.showOkAlert(title: "", message: statusResult.message)
        }
    }
}
