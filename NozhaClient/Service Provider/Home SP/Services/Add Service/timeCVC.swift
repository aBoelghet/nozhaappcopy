//
//  timeCVC.swift
//  NozhaClient
//
//  Created by mac book air on 1/17/21.
//

import UIKit
import IBAnimatable

class timeCVC: UICollectionViewCell {
    @IBOutlet weak var timeLbl: AnimatableLabel!
    var viewController: ScheduleServiceVC!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBAction func deleteAction(_ sender: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            print(sender.tag)
            print(self.viewController.service_dates.count)
            self.viewController.service_dates.remove(at: sender.tag)
            self.viewController.timesCollectionView.deleteItems(at: [IndexPath(item: sender.tag, section: 0)])
            self.viewController.timesCollectionView.reloadData()
        }
    }
}
