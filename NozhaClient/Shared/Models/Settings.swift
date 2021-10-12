//
//  Settings.swift
//  NozhaClient
//
//  Created by mac book air on 1/20/21.
//

import Foundation


class Settings : Codable {
    
    let androidUrl : String?
    let email : String?
    let tiktok : String?
    let instagram : String?
    let iosUrl : String?
    let logo : String?
    let logoMin : String?
    let mobile : String?
    let twitter : String?
    let whatsApp : String?
    let youtube : String?
    let tax : Double?
    let reservations_count:Int?
    let required_gender:Bool?
    
    enum CodingKeys: String, CodingKey {
        case androidUrl = "android_url"
        case email = "email"
        case tiktok = "tiktok"
        case instagram = "instagram"
        case iosUrl = "ios_url"
        case logo = "logo"
        case logoMin = "logo_min"
        case mobile = "mobile"
        case twitter = "twitter"
        case whatsApp = "whatsApp"
        case youtube = "youtube"
        case tax = "tax"
        case reservations_count = "reservations_count"
        case required_gender = "required_gender"
    }
    
    
    
}
