//
//  SuccessOrderVC.swift
//  NozhaClient
//
//  Created by macbook on 19/02/2021.
//

import UIKit

class SuccessOrderVC: UIViewController {
    @IBOutlet weak var reserNoLbl: UILabel!
    
    
    @IBOutlet weak var waittingLbl: UILabel!
    var reservation:Reservation?
    override func viewDidLoad() {
        super.viewDidLoad()
        reserNoLbl.text = self.reservation?.uuid ?? ""
        if reservation?.service?.type ?? "event" == "event" {
            waittingLbl.text = ""
        }else {
            waittingLbl.text = "Waiting for the event organizer to accept the request".localized
        }
    }
    
    @IBAction func routeHome(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.routeToHomeCustomer()
        })
    }
    @IBAction func BrowseTicketAction(_ sender: Any) {
        let Info = ["reservationId": self.reservation?.id ?? 0] as [String : Any]
        self.dismiss(animated: true, completion: {
            self.routeToHomeCustomer()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pushReservationDetails"), object: self, userInfo: Info)
            
        })
    }
    
    @IBAction func browseReservationAction(_ sender: Any) {
        
        self.dismiss(animated: true, completion: {
            self.routeToHomeCustomer()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pushReservations"), object: self, userInfo: nil)
            
        })
    }
    
    
}
