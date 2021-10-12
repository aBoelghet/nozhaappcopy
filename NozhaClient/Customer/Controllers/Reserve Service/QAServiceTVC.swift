//
//  QAServiceTVC.swift
//  NozhaClient
//
//  Created by macbook on 19/02/2021.
//

import UIKit
import IBAnimatable
class QAServiceTVC: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var questionLbl: UILabel!
    
    @IBOutlet weak var answerTF: AnimatableTextField!
    var question:Question? {
        didSet{
            questionLbl.text =  question?.question ?? ""
        }
    }
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        question?.answer = textField.text ?? ""
    }
}
