//
//  ViewExtention.swift
//  tamween
//
//  Created by Heba lubbad on 7/25/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import Foundation

import UIKit

class CustomDashedView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var dashWidth: CGFloat = 0
    @IBInspectable var dashColor: UIColor = .clear
    @IBInspectable var dashLength: CGFloat = 0
    @IBInspectable var betweenDashesSpace: CGFloat = 0

    var dashBorder: CAShapeLayer?

    override func layoutSubviews() {
        super.layoutSubviews()
        dashBorder?.removeFromSuperlayer()
        let dashBorder = CAShapeLayer()
        dashBorder.lineWidth = dashWidth
        dashBorder.strokeColor = dashColor.cgColor
        dashBorder.lineDashPattern = [dashLength, betweenDashesSpace] as [NSNumber]
        dashBorder.frame = bounds
        dashBorder.fillColor = nil
        if cornerRadius > 0 {
            dashBorder.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        } else {
            dashBorder.path = UIBezierPath(rect: bounds).cgPath
        }
        layer.addSublayer(dashBorder)
        self.dashBorder = dashBorder
    }
}
extension UIView {
    
 
  
    enum Visibility {
            case visible
            case invisible
            case gone
        }

        var visibility: Visibility {
            get {
                let constraint = (self.constraints.filter{$0.firstAttribute == .height && $0.constant == 0}.first)
                if let constraint = constraint, constraint.isActive {
                    return .gone
                } else {
                    return self.isHidden ? .invisible : .visible
                }
            }
            set {
                if self.visibility != newValue {
                    self.setVisibility(newValue)
                }
            }
        }

        private func setVisibility(_ visibility: Visibility) {
            let constraint = (self.constraints.filter{$0.firstAttribute == .height && $0.constant == 0}.first)
            let constraintW = (self.constraints.filter{$0.firstAttribute == .width && $0.constant == 0}.first)

            switch visibility {
            case .visible:
                constraint?.isActive = false
                constraintW?.isActive = false
                self.isHidden = false
                break
            case .invisible:
                constraint?.isActive = false
                constraintW?.isActive = false
                self.isHidden = true
                break
            case .gone:
                if let constraint = constraint {
                    constraint.isActive = true
                    constraintW!.isActive = true
                } else {
                    let constraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
                    self.addConstraint(constraint)
                    
                    
                    let constraintW = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
                                     self.addConstraint(constraint)
                    
                    
                    self.addConstraint(constraintW)

                    constraint.isActive = true
                    constraintW.isActive = true
                }
            }
        }
    

}

public extension UIView {

    func addBlurredBackground(style: UIBlurEffect.Style) {
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.frame
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurView)
        self.sendSubviewToBack(blurView)
    }
}
