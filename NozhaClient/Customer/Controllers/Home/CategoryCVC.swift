//
//  CategoryCVC.swift
//  NozhaClient
//
//  Created by macbook on 17/02/2021.
//
import UIKit
import IBAnimatable
import SkeletonView

class CategoryCVC: UICollectionViewCell {
    
    @IBOutlet var sk_views: [UIView]!
    @IBOutlet weak var skeltonView: UIView!
    @IBOutlet weak var noLbl: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var imgV: AnimatableImageView!
    
    
    var cat: Category? {
        didSet {
            
            noLbl.text = "\(cat?.servicesCount?.description ?? "") + \("Offers & Srvice".localized)"
            name.text = cat?.name ?? ""
            imgV.fetchingImage(url: cat?.icon ?? "")
            skeltonView.isHidden = true
            for view in sk_views{
                view.hideSkeleton()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let gradient = SkeletonGradient(baseColor: UIColor.clouds)
        let animationType = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight)
        for view in sk_views{
            view.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animationType)
        }
        skeltonView.isHidden = false
        
    }

}
