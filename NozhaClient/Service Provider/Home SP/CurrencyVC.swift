//
//  CurrencyVC.swift
//  NozhaClient
//
//  Created by macbook on 17/03/2021.
//

import UIKit

class CurrencyVC: UIViewController {
    @IBOutlet weak var curencyLbl: UILabel!
    @IBOutlet weak var balanceValLbl: UILabel!
    
    var balance:Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.balanceValLbl.text = "\(balance?.description.Pricing ?? "")"
        self.curencyLbl.text = "".valueWithCurrency
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    
}
