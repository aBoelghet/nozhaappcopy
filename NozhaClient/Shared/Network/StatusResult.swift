//
//  StatusResult.swift
//  tamween
//
//  Created by Heba lubbad on 7/13/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import Foundation

class StatusResult
{
    
    var statusCode :Int?
    var success :Int?
    
    
    //if have more issue from server
    private var errors : [String] = []
    
    //if have one Single from server
    var message : String = ""
    
    var data : Any
    
    var isSuccess :Bool {
        get{
            return success == 1 ? true : false
        }
        set{
            if newValue == true {
                success = 1
            }else {
                success = 0
            }
        }
    }
    
    var errorMessege :String{
        get{
            if errors.isEmpty {
                return message
            }
            
            
            var errorMessage :String = ""
            if errors.isEmpty {
                errorMessage.append(message)
            }
            for value in errors {
                errorMessage.append(contentsOf: value + "\n")
                
            }
            
            return errorMessage
        }
        
        set{
            errors.append(newValue)
        }
    }
    
    init(json: [String:Any]){
        success = json["success"] as? Int ?? 0
        errors = json["error"] as? [String] ?? []
        message = json["message"] as? String ?? ""
        statusCode = json["status"] as? Int ?? 0
        data  = json["data"] ?? json
        
    }
    
}






