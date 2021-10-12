//
//  NoInternetVC.swift
//  NozhaClient
//
//  Created by macbook on 22/02/2021.
//

import UIKit

class NoInternetVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func retryAction(_ sender: Any) {
        if self.isConnectedToNetwork() {
            self.dismiss()
        }
    }


}
