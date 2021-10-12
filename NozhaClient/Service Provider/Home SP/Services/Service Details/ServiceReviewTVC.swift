//
//  ServiceReviewTVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/15/21.
//

import UIKit

class ServiceReviewTVC: UITableViewCell {

    @IBOutlet weak var rate1Lbl: UILabel!
    @IBOutlet weak var rate2Lbl: UILabel!
    @IBOutlet weak var rate3Lbl: UILabel!
    @IBOutlet weak var rate4Lbl: UILabel!
    @IBOutlet weak var rate5Lbl: UILabel!
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var total: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUpRatings(rateings:Ratings){
        rate1Lbl.text = rateings.rate1?.description
        rate2Lbl.text = rateings.rate2?.description
        rate3Lbl.text = rateings.rate3?.description
        rate4Lbl.text = rateings.rate4?.description
        rate5Lbl.text = rateings.rate5?.description
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
