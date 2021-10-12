//
//  TableViewExtention.swift
//  tamween
//
//  Created by Heba lubbad on 7/9/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable class intrinsicTableView: UITableView {
    
    override var intrinsicContentSize : CGSize {
        // Drawing code
        layoutIfNeeded()
        
        #if TARGET_INTERFACE_BUILDER
        //    return CGSizeMake(UIViewNoIntrinsicMetric, 300);
        return  CGSize(width: UIView.noIntrinsicMetric, height: 300)
        #else
        return CGSize(width: UIView.noIntrinsicMetric, height: self.contentSize.height);
        #endif
        
    }
    
    override var contentSize:CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
}
