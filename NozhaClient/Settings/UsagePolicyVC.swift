//
//  UsagePolicyVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/18/21.
//

import UIKit
import SkeletonView

class UsagePolicyVC: UIViewController {
    @IBOutlet var scrorllView: UIScrollView!
    @IBOutlet var termsLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrorllView.showAnimatedGradientSkeleton()
        startRequestTerms()
        
    }
    
    
    
    func startRequestTerms(){
        API.TERMS_CONDITIONS.startRequest() { (api, response) in
            if response.isSuccess {
                let value = response.data as! [String:Any]
                
                let data_content = try! JSONSerialization.data(withJSONObject: value, options: [])
                let content = try! JSONDecoder().decode(Content.self, from: data_content)
                
                self.termsLbl.text = content.content?.htmlAttributedString?.string ?? ""
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    
                    self.scrorllView.hideSkeleton()
                }
                
            }
            else
            {
                self.showOkAlert(title: "", message: response.message)
            }
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
}
