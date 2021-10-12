//
//  NewService.swift
//  NozhaClient
//
//  Created by mac book air on 2/9/21.
//

import Foundation
import UIKit

class NewService: NSObject {
    
    var name: String?
    var en_name: String?
    var type: String?
    var price: Double?
    var city_id:Int?
    var total_duration:Double?
    var duration_id:Int?
    var description_str: String?
    var en_description_str: String?
    var people_number:Int?
    var images :[UIImage] = []
    var category_id:Int?
    var address: String?
    var lat:Double?
    var lng: Double?
    var has_permission:Int?
    var questions:[String]?
    var en_questions:[String]?
    var work_date:[String]?
    var service_dates:[String]?
    var from:[String]?
    var to:[String]?
    var video_url:String?
    var organiser:String?
    var categoryName:String?
    
    
    
    
    override init() {
    
        self.name = ""
        self.en_name = ""
        self.type = ""
        self.price = 0
        self.city_id = 0
        self.total_duration = 0.0
        self.duration_id = 0
        self.description_str = ""
        self.en_description_str = ""
        self.people_number = 0
        self.images  = []
        self.category_id = 0
        self.address = ""
        self.lat = 0.0
        self.lng = 0.0
        self.has_permission = 0
        self.questions = []
        self.en_questions = []
        self.work_date = []
        self.from = []
        self.to = []
        self.video_url = ""
        self.service_dates  = []
        self.organiser  = ""
        self.categoryName = ""
        
    }
    
}

class Global {
    
    static let share = Global()
    var new_Service = NewService.init()
    
}

