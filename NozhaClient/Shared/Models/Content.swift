//
//  Content.swift
//  NozhaClient
//
//  Created by mac book air on 1/21/21.
//

import Foundation

class Content : Codable {
    
    let key : String?
    let name : String?
    let content : String?
    
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case content = "content"
        case key = "key"
      
    }
    
    
    
}
