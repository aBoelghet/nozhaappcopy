//
//  CategoryTVC.swift
//  NozhaClient
//
//  Created by macbook on 17/02/2021.
//

import UIKit
import MOLH

class CategoryTVC: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var cats :[Category]? {
        didSet{
            collectionView.reloadData()
            if MOLHLanguage.isRTLLanguage()  && cats?.count ?? 0 > 2 {
                
                collectionView?.scrollToItem(at: IndexPath(item: 0, section: 0) , at: .right, animated: false)
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
    
    
    
}

extension CategoryTVC :UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return cats?.count ?? 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCVC", for: indexPath) as! CategoryCVC
        if self.cats != nil {
            cell.cat = self.cats?[indexPath.row]
            
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 190 , height: 85)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.cats?.count ?? 0 > 0 {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc :ServicesVC = mainStoryboard.instanceVC()
        if self.cats?.count ?? 0 > 0 {
            vc.category = self.cats?[indexPath.item]
        }
        self.parentContainerViewController()?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
