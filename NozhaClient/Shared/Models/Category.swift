//
//  Category.swift
//  NozhaClient
//
//  Created by mac book air on 1/20/21.
//

import Foundation


class Category : Codable {

        let icon : String?
        let id : Int?
        let name : String?
        let servicesCount : Int?

        enum CodingKeys: String, CodingKey {
                case icon = "icon"
                case id = "id"
                case name = "name"
                case servicesCount = "services_count"
        }
    
    
}
