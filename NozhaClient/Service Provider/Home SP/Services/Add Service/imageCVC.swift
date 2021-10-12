//
//  imageCVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/17/21.
//

import UIKit
import IBAnimatable


class imageCVC: UICollectionViewCell {
    
    @IBOutlet var img: AnimatableImageView!
    var viewController: addServiceVC!
    @IBOutlet var deleteBtn: AnimatableButton!
    func setUp(image:UIImage){
        img.image = image
    }
    @IBAction func deletePhotoAction(_ sender: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.viewController.modelsPhotos.remove(at: sender.tag)
            self.viewController.collectionView.deleteItems(at: [IndexPath(item: sender.tag, section: 0)])
            self.viewController.collectionView.reloadData()
        }
        
    }
}
