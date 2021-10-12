//
//  Notifications.swift
//  NozhaClient
//
//  Created by mac book air on 2/11/21.
//

import Foundation

class Notification : Codable {
    
    let createdAt : String?
    let icon : String?
    let id : String?
    let message : String?
    let others : Other?
    let seen : Bool?
    let title : String?
    let type : String?
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case icon = "icon"
        case id = "id"
        case message = "message"
        case others = "others"
        case seen = "seen"
        case title = "title"
        case type = "type"
       
    }
    
    
}

class Other : Codable {
    
    let id : Int?
    let type : String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
    }
    
}
