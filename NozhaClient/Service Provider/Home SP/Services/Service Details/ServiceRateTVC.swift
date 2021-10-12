//
//  ServiceRateTVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/15/21.
//

import UIKit
import Cosmos
import IBAnimatable
import SkeletonView

class ServiceRateTVC: UITableViewCell {
    @IBOutlet var mainSkelton: UIView!
    @IBOutlet var skeltonableViews: [UIView]!
    @IBOutlet weak var coment: UILabel!
    @IBOutlet weak var userImgV: AnimatableImageView!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var rate: CosmosView!
    @IBOutlet weak var nameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        let gradient = SkeletonGradient(baseColor: UIColor.clouds)
        let animationType = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
        for view in skeltonableViews{
            view.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animationType)
        }
     
        mainSkelton.isHidden = false
    }
    
    func  setUpRate(rate:Rate){
        coment.text = rate.comment ?? ""
        userImgV.fetchingImage(url: rate.image ?? "")
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSz"
        let date = dateFormatter.date(from:rate.createdAt ?? "")!
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        let str =  dateFormatter.string(from: date)
        timeLbl.text =  str
        self.rate.rating = rate.rate ?? 0.0 
        nameLbl.text = rate.name ?? ""
        mainSkelton.isHidden = true
        for view in skeltonableViews{
            view.hideSkeleton()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
