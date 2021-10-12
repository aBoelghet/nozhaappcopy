//
//  ReservationInfo.swift
//  NozhaClient
//
//  Created by mac book air on 2/8/21.
//

import Foundation


class ReservationInfo : Codable {

        let price : Double?
        let service_time : WorkTime?
        let serviceId : Int?
        let totalAmounts : Double?
        let totalPersons : Int?
        let totalReservation : Int?
        var status : String?

        enum CodingKeys: String, CodingKey {
                case price = "price"
                case service_time = "service_time"
                case serviceId = "service_id"
                case totalAmounts = "total_amounts"
                case totalPersons = "total_persons"
                case totalReservation = "total_reservation"
        }
    
}
