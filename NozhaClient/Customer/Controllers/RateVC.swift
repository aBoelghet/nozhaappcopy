//
//  RateVC.swift
//  NozhaClient
//
//  Created by macbook on 21/02/2021.
//

import UIKit
import IBAnimatable
import UITextView_Placeholder
import IQKeyboardManagerSwift


protocol productseRated: class {
    func Rated(Reservation:Reservation)
   
}

class RateVC: UIViewController {

    @IBOutlet weak var loader: UIActivityIndicatorView!
    var selectedIndex: Int = 0
    var reservation:Reservation?
    @IBOutlet var buttons:[UIButton]!
    @IBOutlet var wordNoLvl: UILabel!
    @IBOutlet var commentTV: IQTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader.isHidden = true
        self.view.addBlurredBackground(style: UIBlurEffect.Style.light)
    }
    
    @IBAction func tabChanged(sender:UIButton) {
       
        selectedIndex = sender.tag
        
        for btn in buttons {
            if btn.tag == sender.tag {
                btn.backgroundColor = Constants.black_main_color
            }else {
                btn.backgroundColor = Constants.red_main
               
            }
        }
       
    }

    @IBAction func nextAction(_ sender: Any) {
        switch validationInput() {
        case .invalid(let error):
            self.showBunnerAlert(title: "", message: error)
            
        case .valid:
            startReqestAddRate()
            break
        }
        
    }
    
    func startReqestAddRate()
    {
        loader.isHidden = false
        loader.startAnimating()
        var params  = [String:Any]()
        params["rate"] =  self.selectedIndex.description
        params["comment"] = self.commentTV.text
      
        
        
        API.RATE_RESERVATION.startRequest(nestedParams:("\(self.reservation?.id!.description ?? "")/rate"),params:params) { (api, response) in
            
            self.loader.isHidden = true
            self.loader.stopAnimating()
            if response.isSuccess {
                
                self.showBunnerSuccessAlert(title: "", message: response.message)
                
                self.dismiss(animated: true) {
                    self.routeToHomeCustomer()
                }
            }else
            {
                self.showBunnerAlert(title: "", message: response.message)
            }
            
        }
        
    }
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss()
        
    }
    
    func validationInput() -> Validation{
        
        if selectedIndex == 0
        {
            return .invalid("You must add your rate".localized)
        }
    
        return .valid
    }

}
extension RateVC :UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        wordNoLvl.text = "\(textView.text.count)/100"
        return textView.text.count + (text.count - range.length) <= 100
    }
}

