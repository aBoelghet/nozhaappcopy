//
//  Durations.swift
//  NozhaClient
//
//  Created by mac book air on 1/20/21.
//

import Foundation


class Duration : Codable {

        let id : Int?
        let name : String?

        enum CodingKeys: String, CodingKey {
                case id = "id"
                case name = "name"
        }
    
      
}
