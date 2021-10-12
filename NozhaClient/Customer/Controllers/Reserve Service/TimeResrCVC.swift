//
//  TimeResrCVC.swift
//  NozhaClient
//
//  Created by macbook on 19/02/2021.
//

import UIKit
import IBAnimatable

class TimeResrCVC: UICollectionViewCell {
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var container: AnimatableView!
    
    var time:String?{
        didSet{
            timeLbl.text = time ?? ""
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
            self.container.backgroundColor = Constants.black_main_color
                self.timeLbl.textColor = .white
            }else{
                self.container.backgroundColor = .clear
                self.timeLbl.textColor =  Constants.black_main_color
            }
            
        }
        
    }
    
}
