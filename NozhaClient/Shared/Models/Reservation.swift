//
//  Reservation.swift
//  NozhaClient
//
//  Created by mac book air on 2/4/21.
//

import Foundation


class Reservation : Codable {
    
    
    let address : String?
    let amount : Double?
    let chargeId : String?
    let cityId : City?
    let createdAt : String?
    let customer : Customer_User?
    var id : Int?
    let lat : Float?
    let lng : Float?
    let notes : String?
    let paid : Bool?
    let personsCount : Int?
    let qrCode : String?
    let reservationQuestions : [ReservationQuestion]?
    let service : Service?
    let category_id:Category?
    let status : String?
    let statusName : String?
    let tax : Double?
    let totalAmount : Double?
    let uuid : String?
    let rated:Bool?
    let type : String?
    let previous_reservations :Int?
    let current_reservations: Int?
    let image:String?
    let name: String?
    let organisers:String?
    let server_time:String?
    let accepted_at:String?
    let service_time:WorkTime?
    let completed_at : String?
    
    enum CodingKeys: String, CodingKey {
        case address = "address"
        case amount = "amount"
        case chargeId = "charge_id"
        case cityId = "city_id"
        case createdAt = "created_at"
        case customer = "customer"
        case id = "id"
        case lat = "lat"
        case lng = "lng"
        case notes = "notes"
        case paid = "paid"
        case personsCount = "persons_count"
        case qrCode = "qr_code"
        case reservationQuestions = "reservation_questions"
        case service = "service"
        case status = "status"
        case statusName = "status_name"
        case tax = "tax"
        case totalAmount = "total_amount"
        case uuid = "uuid"
        case rated = "rated"
        case type = "type"
        case previous_reservations = "previous_reservations"
        case current_reservations = "current_reservations"
        case image = "image"
        case name = "name"
        case category_id = "category_id"
        case organisers = "organisers"
        case server_time = "server_time"
        case accepted_at = "accepted_at"
        case service_time = "service_time"
        case completed_at = "completed_at"
    }
    
    
    
}
