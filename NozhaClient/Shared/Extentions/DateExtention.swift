//
//  DateExtention.swift
//  tamween
//
//  Created by Heba lubbad on 7/27/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import Foundation


extension Date{
static func changeFormat(dateString: String ,toFormat: String = "dd MMM yyyy") -> String{
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = toFormat
    
    return formatter.string(from: Date.convertToDate(date: dateString))
}
static func convertToDate(date :String,formatText :String = "yyyy-MM-dd") -> Date{
      let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
       formatter.dateFormat = formatText
       return formatter.date(from: date) ?? Date()
    }
    
}
