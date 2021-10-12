//
//  Paginate.swift
//  NozhaClient
//
//  Created by mac book air on 2/9/21.
//

import Foundation


class Paginate : Codable {

        let currentPage : Int?
        let firstPageUrl : String?
        let from : Int?
        let lastPage : Int?
        let lastPageUrl : String?
        let nextPageUrl : String?
        let perPage : Int?
        let prevPageUrl : String?
        let to : Int?
        let total : Int?

        enum CodingKeys: String, CodingKey {
                case currentPage = "current_page"
                case firstPageUrl = "first_page_url"
                case from = "from"
                case lastPage = "last_page"
                case lastPageUrl = "last_page_url"
                case nextPageUrl = "next_page_url"
                case perPage = "per_page"
                case prevPageUrl = "prev_page_url"
                case to = "to"
                case total = "total"
        }
    
        
}
