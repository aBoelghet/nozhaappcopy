//
//  TextFieldExtention.swift
//  tamween
//
//  Created by Heba lubbad on 7/12/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import Foundation
import UIKit
import MOLH

extension UIDatePicker {
    open override func awakeFromNib() {
        super.awakeFromNib()
       
        let loc = Locale(identifier: "en_US_POSIX")
        self.locale = loc
        self.semanticContentAttribute = .forceLeftToRight
      
    }
}

extension UITextView {
    open override func awakeFromNib() {
        super.awakeFromNib()
        if MOLHLanguage.isArabic(){
            if textAlignment == .natural {
                self.textAlignment = .right
            }
        }else {
            if textAlignment == .natural {
                self.textAlignment = .left
            }
        }
    }
}
extension UITextField  {
    
    
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        if MOLHLanguage.isArabic(){
            if textAlignment == .natural {
                self.textAlignment = .right
            }
        }else {
            if textAlignment == .natural {
                self.textAlignment = .left
            }
        }
    }
    
    func selected(){
        
        
        if self.rightViewMode != .always {
            setRightPaddingPoints(CGFloat(16))
        }
        
        if self.leftViewMode != .always {
            setLeftPaddingPoints(CGFloat(16))
        }
        
    }
    
    
    func notSelected(){
        
        
    }
    
    
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height ))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    
    
    func setLeftImage(uiImage: UIImage){
        let arrow = UIImageView(image: uiImage)
        
        arrow.contentMode = .center
        arrow.image = uiImage
        
        arrow.frame = CGRect(x: 8 , y: -2.0, width: uiImage.size.width , height: uiImage.size.height)
        
        
        var view  = UIView(frame: CGRect(x: 20, y: 0, width:  uiImage.size.width + 8, height: uiImage.size.height))
        
        view.addSubview(arrow)
        self.leftViewMode = .always
        //arrow.contentMode = UIView.ContentMode.center
        self.leftView = view
    }
    
    
    
    func setRightImage(uiImage: UIImage){
        let arrow = UIImageView(image: uiImage)
        arrow.contentMode = .center
        arrow.image = uiImage
        
        
        let view  = UIView(frame: CGRect(x: 0, y: 0, width:  uiImage.size.width + 16, height: uiImage.size.height))
        
        
        arrow.frame = CGRect(x: view.center.x - (uiImage.size.width / 2) , y: -2.0, width: uiImage.size.width , height: uiImage.size.height)
        
        
        
        view.addSubview(arrow)
        self.rightViewMode = .always
        //arrow.contentMode = UIView.ContentMode.center
        self.rightView = view
    }
    
    
    
    
    @IBInspectable var startImage:UIImage? {
        set {
            if newValue != nil {
                if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
                    setRightImage(uiImage: newValue!)
                    setLeftPaddingPoints(8)
                    
                }else{
                    setLeftImage(uiImage: newValue!)
                    setRightPaddingPoints(8)
                    
                }
            }
        }
        get {
            
            if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
                
                guard let image :UIImageView = (self.rightView! as? UIImageView) else{
                    return nil
                }
                return image.image
            }else{
                
                guard let image :UIImageView = (self.leftView! as? UIImageView) else{
                    return nil
                }
                
                return image.image
            }
        }
    }
    
    
    
    @IBInspectable var endImage:UIImage? {
        set {
            if newValue != nil {
                if UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
                    setRightImage(uiImage: newValue!)
                    setLeftPaddingPoints(8)
                }else{
                    setLeftImage(uiImage: newValue!)
                    setRightPaddingPoints(8)
                    
                }
            }
        }
        get {
            
            if UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
                
                guard let image :UIImageView = (self.rightView! as? UIImageView) else{
                    return nil
                }
                return image.image
            }else{
                
                guard let image :UIImageView = (self.leftView! as? UIImageView) else{
                    return nil
                }
                
                return image.image
            }
        }
    }
    
    

    
    
}


