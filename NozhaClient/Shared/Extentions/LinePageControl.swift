//
//  LinePageControl.swift
//  tamween
//
//  Created by Heba lubbad on 8/19/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import UIKit


class LinePageControl: UIPageControl {
    
   override func layoutSubviews() {
         super.layoutSubviews()
         
         guard !subviews.isEmpty else { return }
         
         let spacing: CGFloat = 3
         
         let width: CGFloat = 16
         
         let height: CGFloat = 3
         
         var total: CGFloat = 0
         
         for (index,view) in subviews.enumerated() {
            view.layer.cornerRadius = 1.5
           
                 view.frame = CGRect(x: total, y: frame.size.height / 2 - height / 2, width: width, height: height)
                 total += width + spacing
         }
         
         total -= spacing
         
         frame.origin.x = frame.origin.x + frame.size.width / 2 - total / 2
         frame.size.width = total
     }
     
}
