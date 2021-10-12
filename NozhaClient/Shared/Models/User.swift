//
//  User.swift
//  NozhaClient
//
//  Created by mac book air on 1/21/21.
//

import Foundation


class User : Codable {

            let accessToken : String?
            let active : Int?
            let avgRate : Double?
            let city : City?
            let countRate : Int?
            let email : String?
            let gender : String?
            let id : Int?
            let identityNumber : String?
            let identityPhoto : String?
            let image : String?
            let locale : String?
            let mobile : String?
            let name : String?
            let notification : Int?
            let reservationsCount : Int?
            let servicesCount : Int?
            let type : String?
            let unreadNotifications : Int?

            enum CodingKeys: String, CodingKey {
                    case accessToken = "access_token"
                    case active = "active"
                    case avgRate = "avg_rate"
                    case city = "city"
                    case countRate = "count_rate"
                    case email = "email"
                    case gender = "gender"
                    case id = "id"
                    case identityNumber = "identity_number"
                    case identityPhoto = "identity_photo"
                    case image = "image"
                    case locale = "locale"
                    case mobile = "mobile"
                    case name = "name"
                    case notification = "notification"
                    case reservationsCount = "reservations_count"
                    case servicesCount = "services_count"
                    case type = "type"
                    case unreadNotifications = "unread_notifications"
            }
        

    }
