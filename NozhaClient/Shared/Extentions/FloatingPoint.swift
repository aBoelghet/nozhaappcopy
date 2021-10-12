//
//  FloatingPoint.swift
//  tamween
//
//  Created by Heba lubbad on 7/14/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import Foundation


extension FloatingPoint {
  var isInteger: Bool { get{return rounded() == self} }

    var whole: Self { modf(self).0 }
    var fraction: Self { modf(self).1 }
}

extension Double {
    
    var Pricing : String{
    
    let val = self
        if val.fraction ==  0.00{
            return "\(String(format:"%.0f",val ))"
        }else {
            return "\(String(format:"%.02f",val ))"
        }

    }

    
}

