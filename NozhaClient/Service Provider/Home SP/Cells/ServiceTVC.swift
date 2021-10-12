//
//  ServiceTVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/28/21.
//

import UIKit
import SkeletonView
import IBAnimatable
import MOLH
class ServiceTVC: UITableViewCell {
    
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var browseBtn: AnimatableButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lastUpdateLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    
    
    var services :[Service]? {
        didSet{
            collectionView.reloadData()
            if MOLHLanguage.isRTLLanguage()  && services?.count ?? 0 > 2 {
                
                collectionView?.scrollToItem(at: IndexPath(item: 0, section: 0) , at: .right, animated: false)
            }
            
            if services?.count == 0 {
                collectionHeight.constant = 0
            }else {
                if NozhaUtility.isCustomer() || !NozhaUtility.isLogin() {
                    collectionHeight.constant = 260
                }else {
                    collectionHeight.constant = 300
                }
            }
        }
    }
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.minimumInteritemSpacing = 12 // for vertical spacing
        flowLayout.minimumLineSpacing = 12 // for horizontal spacing
        flowLayout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = flowLayout
        
        if MOLHLanguage.isRTLLanguage() {
            collectionView.semanticContentAttribute = .forceRightToLeft
            
        }else {
            collectionView.semanticContentAttribute = .forceLeftToRight
        }
        
        collectionView.reloadData()
        
        
    }
    
    @IBAction func browseAllAction(_ sender: UIButton) {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc :ServicesVC = mainStoryboard.instanceVC()
        if NozhaUtility.isCustomer()  || !NozhaUtility.isLogin(){
            vc.services_tag = sender.tag
        }
        self.parentContainerViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ServiceTVC :UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return services?.count ?? 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServiceCVC", for: indexPath) as! ServiceCVC
        if self.services != nil {
            cell.service = self.services?[indexPath.row]
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        if NozhaUtility.isCustomer() || !NozhaUtility.isLogin()  {
            return CGSize(width: 220 , height: 255)
        }else {
            return CGSize(width: 220 , height: 300)
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc :ServiceDetailsVC = mainStoryboard.instanceVC()
        if self.services?.count ?? 0 > 0{
            vc.service_obj =  self.services?[indexPath.item]
        }
        self.parentContainerViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    
    
}
