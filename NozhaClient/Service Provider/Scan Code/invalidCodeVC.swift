//
//  invalidCodeVC.swift
//  NozhaClient
//
//  Created by mac book air on 2/11/21.
//

import UIKit

class invalidCodeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addBlurredBackground(style: UIBlurEffect.Style.light)
    }
    @IBAction func tryAgain(_ sender: Any) {
        self.dismiss()
    }
    



}
