//
//  EditServiceVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/15/21.
//

import UIKit
import IBAnimatable

protocol  editServiceDelegate {
    func dialogDissmised(service:Service)
}

class EditServiceVC: UIViewController {
    var delegate :editServiceDelegate?
   
    @IBOutlet weak var pauseView: AnimatableView!
    @IBOutlet weak var pauseLbl: UILabel!
    var service:Service?
    override func viewDidLoad() {
        super.viewDidLoad()
        if service?.approved ?? 0 == 1 {
            self.pauseView.visibility = .visible
            if service?.active ?? false{
                pauseLbl.text = "Pause".localized
              
            }else {
                pauseLbl.text = "Restart".localized
            }
        }else {
            self.pauseView.visibility = .invisible
        }
       
        self.view.addBlurredBackground(style: UIBlurEffect.Style.light)
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss()
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        API.SP_DELETE_SERVICE.startRequest(showIndicator: true,nestedParams:self.service?.id?.description ?? "0") { (api, response) in
            if response.isSuccess {
                self.showBunnerSuccessAlert(title: "", message: response.message)
                self.dismiss(animated: true) {
                    self.routeToHomeSP()
                }
            }
            
            else
            {
                self.showOkAlert(title: "", message: response.message)
            }
        }
    }
    
    @IBAction func pauseAction(_ sender: Any) {
        API.SP_DRAFT_SERVICE.startRequest(showIndicator: true,nestedParams:self.service?.id?.description ?? "0") { (api, response) in
            if response.isSuccess {
                let value = response.data as! [String:Any]
                
                let data_service = try! JSONSerialization.data(withJSONObject: value, options: [])
                let service = try! JSONDecoder().decode(Service.self, from: data_service)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateHomeSupplier"), object: self, userInfo: nil)
                self.showBunnerSuccessAlert(title: "", message: response.message)
                self.dismiss(animated: true) {
                    self.delegate?.dialogDissmised(service: service)
                }
               
            }
            
            else
            {
                self.showOkAlert(title: "", message: response.message)
            }
        }
    }
}
