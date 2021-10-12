//
//  CityCVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/18/21.
//

import UIKit

class CityCVC: UICollectionViewCell {
    @IBOutlet weak var checked: UIImageView!
    @IBOutlet weak var cityNameLbl: UILabel!
    @IBOutlet weak var content: UIView!
    
    override var isSelected: Bool {
        didSet {
            if isSelected == true {
            checked.isHidden = false
            self.content.backgroundColor = Constants.light_yellow
            self.cityNameLbl.textColor = Constants.black_main_color
            }else {
                checked.isHidden = true
                self.content.backgroundColor = .white
                self.cityNameLbl.textColor = Constants.gray_main_color
            }
        }
        
    }
    
}
