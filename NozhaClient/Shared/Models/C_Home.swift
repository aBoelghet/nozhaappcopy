//
//  C_Home.swift
//  NozhaClient
//
//  Created by macbook on 17/02/2021.
//

import Foundation


class C_Home : Codable {
    
    let categories : [Category]?
    let mostOrdered : [Service]?
    let nearServices : [Service]?
    let slider : [Slider]?
    
    enum CodingKeys: String, CodingKey {
        case categories = "categories"
        case mostOrdered = "most_ordered"
        case nearServices = "near_services"
        case slider = "slider"
    }
    
    
}



class Slider : Codable {
    
    let expireAt : String?
    let id : Int?
    let image : String?
    let type : String?
    let service_id : Int?
    let category_id : Int?
    let url : String?
    
    enum CodingKeys: String, CodingKey {
        case expireAt = "expire_at"
        case id = "id"
        case image = "image"
        case type = "type"
        case service_id = "service_id"
        case category_id = "category_id"
        case url = "url"
    }
    
    
    
}
