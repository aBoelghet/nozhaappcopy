//
//  ResQuestionTVC.swift
//  NozhaClient
//
//  Created by mac book air on 2/11/21.
//

import UIKit
import IBAnimatable

class ResQuestionTVC: UITableViewCell {
    
    
    @IBOutlet var anwser: UILabel!
    @IBOutlet var questionLbl: UILabel!
    
    
    
    var question:ReservationQuestion?{
        didSet{
            self.anwser.text =  self.question?.answer ?? ""
            self.questionLbl.text = self.question?.question?.question ?? ""
        }
    }
        override func awakeFromNib() {
        super.awakeFromNib()
        
        }
        
        override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        }
        
        
    }
