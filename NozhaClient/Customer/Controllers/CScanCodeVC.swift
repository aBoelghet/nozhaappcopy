//
//  CScanCodeVC.swift
//  NozhaClient
//
//  Created by macbook on 21/02/2021.
//

import UIKit
import SVGKit
import IBAnimatable

class CScanCodeVC: UIViewController {
   
      
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var statusView: AnimatableView!
    @IBOutlet weak var codeImgV: UIImageView!
    @IBOutlet weak var serviceNameLbl: UILabel!
        @IBOutlet weak var organiserLbl: UILabel!
        @IBOutlet weak var noReservationLbl: UILabel!
        
        var reservation:Reservation?
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.view.addBlurredBackground(style: UIBlurEffect.Style.light)
            let svg = URL(string: "\(self.reservation?.qrCode ?? "")")!
            let data = try? Data(contentsOf: svg)
            let receivedimage: SVGKImage = SVGKImage(data: data)
            self.codeImgV.image = receivedimage.uiImage
            serviceNameLbl.text = reservation?.service?.name ?? ""
            organiserLbl.text = reservation?.service?.organisers?.description
            noReservationLbl.text = "#\(reservation?.uuid?.description ?? "")"
            checkStatus()
        }
    
    func checkStatus(){
        if reservation?.status == "pending" {
            statusLbl.text = reservation?.status?.localized ?? ""
            statusLbl.textColor = .white
            statusView.backgroundColor = Constants.PendingColor
           
        }
        if reservation?.status == "accepted" {
           
            if reservation?.paid ?? false {
                statusView.backgroundColor = Constants.acceptedColor
                statusLbl.textColor = .white
                statusLbl.text = reservation?.status?.localized ?? ""
            }else {
                
                statusView.backgroundColor = Constants.WaittingPaymentColor
                statusLbl.textColor = .white
                statusLbl.text = "Watting payment".localized
               
            }
           
        }
        
        if reservation?.status == "completed" {
            statusLbl.text = reservation?.status?.localized ?? ""
            statusLbl.textColor = .white
            statusView.backgroundColor = Constants.CompletedColor
          
        }
        if reservation?.status == "rejected"  ||  reservation?.status == "canceled" {
            statusLbl.text = reservation?.status?.localized ?? ""
            statusLbl.textColor = Constants.red_main
            statusView.backgroundColor = Constants.CancelledColor
            
        }
        
    }
        
        @IBAction func closeAction(_ sender: Any) {
            self.dismiss()
        }
        
        

    }
