//
//  UICheckBox.swift
//  NozhaClient
//
//  Created by mac book air on 1/16/21.
//

import Foundation
import UIKit
import SDWebImage

class UICheckBox: UIButton {
        // Images
    var checkedImageValue = UIImage(named: "ic_checked_policy")!
    var uncheckedImageValue = UIImage(named: "ic_uncheck")! as UIImage
    
    
    

    
    @IBInspectable var checkedImage :UIImage {
        get{
           return checkedImageValue
        }
        set{
            checkedImageValue = newValue
        }
    }
    
    
    @IBInspectable var uncheckedImage :UIImage {
        get{
            return uncheckedImageValue
        }
        set{
            uncheckedImageValue = newValue
        }
    }
    
    
    
    var changeUnCheckTintColor :UIColor{
        get{
            return UIColor()
        }
        
        set{
        
            uncheckedImage = uncheckedImageValue.imageWithColorOld(color: newValue)!
            self.tintColor = newValue
            isChecked = (isChecked == true)
        }
    }
    
    
        // Bool property
        var isChecked: Bool = false {
            didSet{
                if isChecked == true {
                    self.setImage(checkedImageValue, for: UIControl.State.normal)
                } else {
                    self.setImage(uncheckedImageValue, for: UIControl.State.normal)
                }
                
            }
        }
        
        override func awakeFromNib() {
            self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
            self.tintColor = Constants.black_main_color
            self.isChecked = false
        }
        
        @objc func buttonClicked(sender: UIButton) {
            if sender == self {
                isChecked = !isChecked
            }
        }
}
