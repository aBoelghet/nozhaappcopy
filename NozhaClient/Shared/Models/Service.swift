//
//  Service.swift
//  NozhaClient
//
//  Created by mac book air on 2/4/21.
//


import Foundation

class Service : Codable {
    
    let active : Bool?
    let address : String?
    let approved : Int?
    let approvedAt : String?
    let categoryId : Category?
    let cityId : City?
    let descriptionField : String?
    let durationId : Duration?
    let hasPermission : Bool?
    let id : Int?
    let image : String?
    let images : [Image]?
    let lat : Float?
    let lng : Float?
    let name : String?
    let organisers : String?
    let peopleNumber : Int?
    let price : Double?
    var questions : [Question]?
    let rates : Double?
    let ratesCount : Int?
    let totalDuration : Double?
    let type : String?
    let videoUrl : String?
    var favorited: Bool?
    let workTimes : [WorkTime]?
    let supplier : Supplier?
    var selectedDate:String = ""
    var selectedTime: Int  = 0
    var selectedWorkTime: String  = ""
    var noPersons:Int = 0
    let complete_reservations  : Bool?
    let available_people:Int?
    
    
    enum CodingKeys: String, CodingKey {
        case active = "active"
        case address = "address"
        case approved = "approved"
        case approvedAt = "approved_at"
        case categoryId = "category_id"
        case cityId = "city_id"
        case descriptionField = "description"
        case durationId = "duration_id"
        case hasPermission = "has_permission"
        case id = "id"
        case image = "image"
        case images = "images"
        case lat = "lat"
        case lng = "lng"
        case name = "name"
        case organisers = "organisers"
        case peopleNumber = "people_number"
        case price = "price"
        case questions = "questions"
        case rates = "rates"
        case ratesCount = "rates_count"
        case totalDuration = "total_duration"
        case type = "type"
        case videoUrl = "video_url"
        case favorited = "favorited"
        case workTimes = "work_times"
        case supplier = "supplier"
        case complete_reservations = "complete_reservations"
        case available_people = "available_people"
        
    }
    
    
}

class Image : Codable {
    
    let id : Int?
    let image : String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case image = "image"
    }
    
    
}

class Question : Codable {
    
    let id : Int?
    let question : String?
    var answer: String = ""
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case question = "question"
    }
    
    
    
}



class ReservationQuestion : Codable {
    
    let answer : String?
    let id : Int?
    let question : Question?
    
    enum CodingKeys: String, CodingKey {
        case answer = "answer"
        case id = "id"
        case question = "question"
    }
    
    
    
}

class WorkTime : Codable {

        let from : String?
        let id : Int?
        let to : String?
        let workDate : String?

        enum CodingKeys: String, CodingKey {
                case from = "from"
                case id = "id"
                case to = "to"
                case workDate = "work_date"
        }
    
      
}
class Supplier : Codable {

        let id : Int?
        let image : String?
        let name : String?

        enum CodingKeys: String, CodingKey {
                case id = "id"
                case image = "image"
                case name = "name"
        }
    
}
