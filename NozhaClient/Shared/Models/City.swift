//
//  City.swift
//  NozhaClient
//
//  Created by mac book air on 1/19/21.
//

import Foundation

class City : Codable {

        let id : Int?
        let name : String?

        enum CodingKeys: String, CodingKey {
                case id = "id"
                case name = "name"
        }
    
      

}
