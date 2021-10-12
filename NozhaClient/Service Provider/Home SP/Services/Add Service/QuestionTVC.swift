//
//  QuestionTVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/17/21.
//

import UIKit
import IBAnimatable

class QuestionTVC: UITableViewCell {

    @IBOutlet weak var en_questionTF: AnimatableTextField!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var questionTF: AnimatableTextField!
    var viewController: addServcieStep3VC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
   
    @IBAction func deleteAction(_ sender: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
          
            self.viewController.questions.remove(at: sender.tag)
            self.viewController.tableView.deleteRows(at: [IndexPath(row: sender.tag, section: 0)], with: UITableView.RowAnimation.automatic)
            self.viewController.tableView.reloadData()
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension QuestionTVC:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       
        if textField == questionTF {
        viewController.questions[textField.tag] = textField.text ?? ""
        }else {
            viewController.en_questions[textField.tag] = textField.text ?? ""
        }
        print(textField.text ?? "")
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == questionTF {
        viewController.questions[textField.tag] = textField.text ?? ""
        }else {
            viewController.en_questions[textField.tag] = textField.text ?? ""
        }
        print(textField.text ?? "")
    }
}
