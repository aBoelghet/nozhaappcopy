//
//  Customer.swift
//  NozhaClient
//
//  Created by mac book air on 1/19/21.
//

import Foundation

class Customer_User : Codable {

        let accessToken : String?
        let active : Int?
        let city : City?
        let email : String?
        let gender : String?
        let id : Int?
        let image : String?
        let locale : String?
        let mobile : String?
        let name : String?
        let notification : Int?
        let type : String?
        let unreadNotifications : Int?

        enum CodingKeys: String, CodingKey {
                case accessToken = "access_token"
                case active = "active"
                case city = "city"
                case email = "email"
                case gender = "gender"
                case id = "id"
                case image = "image"
                case locale = "locale"
                case mobile = "mobile"
                case name = "name"
                case notification = "notification"
                case type = "type"
                case unreadNotifications = "unread_notifications"
        }
    
 

}
