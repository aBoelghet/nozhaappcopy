//
//  Ratings.swift
//  NozhaClient
//
//  Created by mac book air on 2/11/21.
//

import UIKit
import Foundation

class Ratings: Codable {

        let items : [Rate]?
        let paginate : Paginate?
        let rate1 : Int?
        let rate2 : Int?
        let rate3 : Int?
        let rate4 : Int?
        let rate5 : Int?
        let rateCount : Int?

        enum CodingKeys: String, CodingKey {
                case items = "items"
                case paginate = "paginate"
                case rate1 = "rate_1"
                case rate2 = "rate_2"
                case rate3 = "rate_3"
                case rate4 = "rate_4"
                case rate5 = "rate_5"
                case rateCount = "rate_count"
        }


}

struct Rate : Codable {

        let comment : String?
        let createdAt : String?
        let id : Int?
        let image : String?
        let name : String?
        let rate : Double?

        enum CodingKeys: String, CodingKey {
                case comment = "comment"
                case createdAt = "created_at"
                case id = "id"
                case image = "image"
                case name = "name"
                case rate = "rate"
        }
    
   

}
