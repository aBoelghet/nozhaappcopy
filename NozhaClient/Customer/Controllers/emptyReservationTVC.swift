//
//  emptyReservationTVC.swift
//  NozhaClient
//
//  Created by macbook on 23/03/2021.
//

import UIKit
import IBAnimatable

class emptyReservationTVC: UITableViewCell {

    @IBOutlet weak var loginBtn: AnimatableButton!
    @IBOutlet weak var addResrLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCell(){
        if !NozhaUtility.isLogin() {
            loginBtn.isHidden = false
            addResrLbl.text = "You must be logged to browse reservations".localized
        }else{
            loginBtn.isHidden = true
            addResrLbl.text = "".localized
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func loginAction(_ sender: Any) {
        self.parentContainerViewController()?.signIn()
    }
}
