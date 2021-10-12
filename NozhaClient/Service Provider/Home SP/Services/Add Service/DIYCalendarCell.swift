//
//  DIYCalendarCell.swift
//  FSCalendarSwiftExample
//
//  Created by dingwenchao on 06/11/2016.
//  Copyright © 2016 wenchao. All rights reserved.
//

import Foundation
import FSCalendar


import UIKit

enum SelectionType : Int {
    case none
    case single
    case leftBorder
    case middle
    case rightBorder
}


class DIYCalendarCell: FSCalendarCell {
    
    weak var circleImageView: UIImageView!
    weak var selectionLayer: CAShapeLayer!
    
    var selectionType: SelectionType = .none {
        didSet {
            setNeedsLayout()
        }
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let selectionLayer = CAShapeLayer()
        selectionLayer.actions = ["hidden": NSNull()]
        self.contentView.layer.insertSublayer(selectionLayer, below: self.titleLabel!.layer)
        self.selectionLayer = selectionLayer
        self.shapeLayer.isHidden = true
        let view = UIView(frame: self.bounds)
        self.backgroundView = view;
        
    }
    
    override func layoutSubviews() {
    
    
            super.layoutSubviews()
        
        let circleImageView = UIImageView(image: UIImage(named: "circle")!)
        self.circleImageView = circleImageView
        
            self.circleImageView.frame = self.contentView.bounds
            self.backgroundView?.frame = self.bounds.insetBy(dx: 1, dy: 1)
            self.selectionLayer.frame = self.contentView.bounds
            
          
                let diameter: CGFloat = min(self.selectionLayer.frame.height, self.selectionLayer.frame.width)
                self.selectionLayer.path = UIBezierPath(ovalIn: CGRect(x: self.contentView.frame.width / 2 - diameter / 2, y: self.contentView.frame.height / 2 - diameter / 2, width: diameter, height: diameter)).cgPath
      

    }
    
    override func configureAppearance() {
        super.configureAppearance()
        if self.isPlaceholder {
            self.eventIndicator.isHidden = true
            self.titleLabel.textColor = Constants.gray_main_color
        }
        if self.dateIsToday {
            self.eventIndicator.isHidden = false
            self.titleLabel.textColor = Constants.gray_main_color
        }
    }
    
}
