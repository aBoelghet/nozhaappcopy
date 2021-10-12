//
//  CompleteOrder.swift
//  NozhaClient
//
//  Created by mac book air on 2/11/21.
//

import UIKit

class CompleteOrder: UIViewController {
    @IBOutlet weak var completedAtLbl: UILabel!
    
    @IBOutlet weak var reservationDate: UILabel!
    @IBOutlet weak var reservatioNoLbl: UILabel!
    var reservation:Reservation?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addBlurredBackground(style: UIBlurEffect.Style.light)
        
        
          reservatioNoLbl.text = "#\(reservation?.uuid?.description ?? "")"
        reservationDate.text = "\("Service date: ".localized)\(reservation?.service_time?.workDate?.description ?? "") | \(reservation?.service_time?.from?.description ?? "")-\(reservation?.service_time?.to?.description ?? "")"
        completedAtLbl.text = "\("Completed reservation at".localized): \(reservation?.completed_at ?? "")"
    }
    
    @IBAction func tryAgain(_ sender: Any) {
        self.dismiss()
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss()
    }

}
