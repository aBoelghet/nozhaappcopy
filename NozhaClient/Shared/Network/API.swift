//
//  API.swift
//  tamween
//
//  Created by Heba lubbad on 7/13/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

enum API {
    
    private static let DEBUG = true
    private  static let TAG = "API - Service "
    
    
    static let DOMAIN_URL = "https://nozha.sa/api/v1/";
    
    static let GENERAL_FIREBASE_SUBSCRIBE_Topic = "users";
    static let GENERAL_FIREBASE_SUBSCRIBE_Topic_CUSTOMERS = "customers";
    static let GENERAL_FIREBASE_SUBSCRIBE_Topic_SUPPLIER = "suppliers";
    static let USER_FIREBASE_SUBSCRIBE_Topic = "user_\(NozhaUtility.loadUser()?.id ?? 0)";
    
    //GENERAL
    
    case GET_USER
    case SETTINGS
    case CATEGORIES
    case CITIES
    case DURATIONS
    case UPDATE_IMAGE
    
    
    //auth
    case LOGIN
    case REGISTER
    case FORGET
    case ACTIVATE
    case RESET_PASSWORD
    case LOGOUT
    case CHANGE_PASSWORD
    case UPDATE_USER
    
    
    
    //Supplier
    case SP_HOME
    case SP_SERVICES
    case SP_RESERVATIONS
    case SP_CURRENT_RESERVATIONS
    case SP_PREVIOUS_RESERVATIONS
    case SP_RESERVATIONS_POST
    case CREATE_SERVICE
    case SP_SERVICE
    case SP_DELETE_SERVICE
    case SP_DRAFT_SERVICE
    case SP_RESERVATION
    case SP_RATINGS
    case SCAN_RESERVATION
    case GROUP_RESERVATIONS
    case SP_ALLRESERVATIONS
    
    // Customer
    case C_HOME
    case C_SERVICES
    case MY_FAVORITES
    case ADD_REMOVE_FAVOURITE
    case C_SERVICE
    case C_RESERVATIONS
    case C_RESERVATION
    case SERVICE_HOURS
    case CREATE_RESERVATION
    case RESERVATION_DETAILS
    case RATE_RESERVATION
    case CONFIRM_PAYMENT
    
    //Notifications
    case ALL_NOTIFICATIONS
    case SET_NOTIFICATION
    case DELETE_NOTIFICATION
    
    
    //rate
    
    case RATE_ORDER
    
    //More
    case QUESTIONS
    case CONTACT_US
    case UPDATE_LANGUAGE
    case ABOUT
    case TERMS_CONDITIONS
    
    
    private var values : (url: String ,reqeustType: HTTPMethod,key :String?)
    {
        get
        {
            switch self {
            
            case .SETTINGS:
                return (API.DOMAIN_URL + "settings",.get,nil)
                
            case .GET_USER:
                return (API.DOMAIN_URL + "profile",.get,nil)
                
            case .UPDATE_IMAGE:
                return (API.DOMAIN_URL + "update_image",.post,nil)
                
            case.CATEGORIES:
                return (API.DOMAIN_URL + "categories",.get,nil)
                
            case.CITIES:
                return (API.DOMAIN_URL + "cities",.get,nil)
                
            case.DURATIONS:
                return (API.DOMAIN_URL + "durations",.get,nil)
                
                
            case .LOGIN:
                return (API.DOMAIN_URL + "login",.post,nil)
                
            case .REGISTER:
                return (API.DOMAIN_URL + "register",.post,nil)
                
            case .FORGET:
                return (API.DOMAIN_URL + "forget_password",.post,nil)
                
            case .ACTIVATE:
                return (API.DOMAIN_URL + "find",.post,nil)
                
            case .RESET_PASSWORD:
                return (API.DOMAIN_URL + "reset",.post,nil)
                
            case .LOGOUT:
                return (API.DOMAIN_URL + "logout",.post,nil)
                
            case .CHANGE_PASSWORD:
                return (API.DOMAIN_URL + "user/change_password",.post,nil)
                
            case .UPDATE_USER:
                return (API.DOMAIN_URL + "profile",.post,nil)
                
                
            //Main
            case .SP_HOME :
                return (API.DOMAIN_URL + "supplier/home",.get,nil)
                
            case .SP_SERVICES :
                return (API.DOMAIN_URL + "supplier/services",.get,nil)
                
            case .SP_SERVICE :
                return (API.DOMAIN_URL + "supplier/services/",.get,"nested")
                
            case .SP_RESERVATIONS :
                return (API.DOMAIN_URL + "supplier/service_reservations",.get,nil)
                
                
            case .GROUP_RESERVATIONS :
                return (API.DOMAIN_URL + "supplier/reservations_group",.get,nil)
                
                
            case .SP_CURRENT_RESERVATIONS:
                return (API.DOMAIN_URL + "supplier/current_reservations/",.get,"nested")
                
            case .SP_PREVIOUS_RESERVATIONS:
                return (API.DOMAIN_URL + "supplier/previous_reservations/",.get,"nested")
                
            case .SP_RESERVATIONS_POST:
                return (API.DOMAIN_URL + "supplier/reservations/",.post,"nested")
                
            case .CREATE_SERVICE:
                return (API.DOMAIN_URL + "supplier/services",.post,nil)
                
            case .SP_DELETE_SERVICE:
                return (API.DOMAIN_URL + "supplier/services/",.delete,"nested")
                
            case .SP_DRAFT_SERVICE:
                return (API.DOMAIN_URL + "supplier/service_draft_publish/",.post,"nested")
                
            case .SP_RESERVATION:
                return (API.DOMAIN_URL + "supplier/reservations/",.get,"nested")
                
            case .SP_RATINGS:
                return (API.DOMAIN_URL + "supplier/rates",.get,nil)
            case .SCAN_RESERVATION:
                return (API.DOMAIN_URL + "supplier/scan_reservation",.get,nil)
                
            case .SP_ALLRESERVATIONS:
                return (API.DOMAIN_URL + "supplier/all_reservations",.get,nil)
            // Customer
            
            case .C_HOME:
                return (API.DOMAIN_URL + "customer/home",.get,nil)
            case .C_SERVICES:
                return (API.DOMAIN_URL + "customer/services",.get,nil)
            case .C_SERVICE:
                return (API.DOMAIN_URL + "customer/services/",.get,"nested")
            case .C_RESERVATIONS:
                return (API.DOMAIN_URL + "customer/reservations",.get,nil)
            case .C_RESERVATION:
                return (API.DOMAIN_URL + "customer/reservations/",.get,"nested")
            case .SERVICE_HOURS:
                return (API.DOMAIN_URL + "customer/service_hours",.get,nil)
            case .CREATE_RESERVATION:
                return (API.DOMAIN_URL + "customer/reservations",.post,nil)
            case .RESERVATION_DETAILS:
                return (API.DOMAIN_URL + "customer/reservations/",.get,"nested")
            case .RATE_RESERVATION:
                return (API.DOMAIN_URL + "customer/reservations/",.post,"nested")
                
                
                
                
            //Favouraite
            
            case .MY_FAVORITES:
                return (API.DOMAIN_URL + "customer/favorites",.get,nil)
                
            case .ADD_REMOVE_FAVOURITE:
                return (API.DOMAIN_URL + "customer/favorites/",.post,"nested")
                
                
                
            //Notifications
            
            case .ALL_NOTIFICATIONS:
                return (API.DOMAIN_URL + "notifications",.get,"")
                
            case .DELETE_NOTIFICATION:
                return (API.DOMAIN_URL + "notifications/",.delete,"nested")
                
            case .SET_NOTIFICATION:
                return (API.DOMAIN_URL + "notifications/",.get,"nested")
                
                
                
            case .CONFIRM_PAYMENT:
                return (API.DOMAIN_URL + "customer/paid_reservation/",.post,"nested")
                
                
                
            //Rate
            case .RATE_ORDER:
                return (API.DOMAIN_URL + "user/rate_order/",.post,"nested")
                
            //More
            
            case .QUESTIONS:
                return (API.DOMAIN_URL + "faq",.get,nil)
                
            case .CONTACT_US:
                return (API.DOMAIN_URL + "contact_us",.post,nil)
                
            case .UPDATE_LANGUAGE:
                return (API.DOMAIN_URL + "update_language",.post,nil)
            case .ABOUT:
                return (API.DOMAIN_URL + "page/about_app",.get,nil)
                
            case .TERMS_CONDITIONS:
                return (API.DOMAIN_URL + "page/terms&conditions",.get,nil)
                
                
                
            }
        }
    }
    
    
    
    
    func startRequest(uiViewController:UIViewController? = nil,showIndicator:Bool = false ,nestedParams :String = "",params :Parameters = [:],header : [String:String] = [:],completion : @escaping (API,StatusResult)->Void)
    {
        let params = params;
        var header = header
        let nestedParams = nestedParams
        
        header["Accept"] = "application/json"
        header["Accept-Language"] = AppDelegate.shared.language
        
        if let authToken = NozhaUtility.loadUser()?.accessToken {
            header["Authorization"] = "Bearer \(authToken)"
        }
        
        let httpHeader = HTTPHeaders(header)
        if API.DEBUG {
            printRequest(nested: nestedParams,params: params, header: header)
        }
        
        let currentViewCountroller = AppDelegate.shared.viewController
        
        currentViewCountroller.isInterntConnected(){_ in
            self.startRequest(nestedParams:nestedParams,params: params, completion:completion)
        }
        
        
        startRequest(api: self,nestedParams: nestedParams,params: params,header: httpHeader) { (result,status,message) in
            if API.DEBUG {
                self.printResponse(result: result)
            }
            
            
            let statusResult = StatusResult(json: result)
            
            if statusResult.success == 0 {
                statusResult.isSuccess = false
                statusResult.errorMessege = message
            }
            
            
            if statusResult.statusCode == 401 {
                currentViewCountroller.singOutWithPermently(message: statusResult.message)
            }else{
                completion(self,statusResult)
            }
        }
    }
    
    private func printRequest(nested :String, params :Parameters = [:],header : [String:String] = [:]){
        print(API.TAG + "url : \(self.values.url)/\(nested)" )
        print(API.TAG + "params : \(params)" )
        print(API.TAG + "header : \(header)" )
        
    }
    
    private func printResponse(result: [String:Any]) {
        print(API.TAG + "result : \(result)" )
    }
    
    
    private func startRequest(api :API,nestedParams :String = "",params : [String:String] = [:],header: HTTPHeaders = [:], completion:@escaping ([String:Any],Bool,String)->Void){
        
        AF.request(api.values.url+nestedParams, method: api.values.reqeustType, parameters: params.isEmpty ? nil:params,encoding: URLEncoding.default, headers: header.isEmpty ? nil:header)
            //.validate(statusCode: 200..<600)
            .responseJSON { response  in
                if API.DEBUG {
                    if let statusCode = response.response?.statusCode {
                        print(API.TAG + "status code : \(statusCode)" )
                    }
                }
                
                switch(response.result)
                {
                case .success(let value):
                    if API.DEBUG {
                        let res = JSON(value)
                        print(res)
                    }
                    if let resp = value as? [String:Any] {
                        completion(resp,true,"")
                    }else {
                        completion([:],false,"no data was found in response")
                    }
                    if API.DEBUG {
                        debugPrint(value)
                    }
                case .failure(let error) :
                    if API.DEBUG {
                        print(response.error.debugDescription)
                        print(error.errorDescription ?? "")
                        
                    }
                    completion([:],false,error.localizedDescription)
                }
                
            }
    }
    
    
    
    
    
    ///file
    
    func startRequestWithFile(uiViewController:UIViewController? = nil,showIndicator:Bool = false,nestedParams :String = "" ,params :[String:String] = [:],data :[String:Data] = [:],headers : [String:String] = [:],completion : @escaping (API,StatusResult)->Void){
        let params = params;
        var headers = headers;
        
        headers["Accept"] = "application/json"
        headers["Accept-Language"] = AppDelegate.shared.language
        
        if let authToken = NozhaUtility.loadUser()?.accessToken {
            headers["Authorization"] = "Bearer \(authToken)"
        }
        
        if API.DEBUG {
            printRequest(nested: nestedParams, params: params, header: headers)
            print("data size 'file Numbers' \(data.count)")
            
        }
        
        let currentViewCountroller = AppDelegate.shared.viewController
        
        if  !currentViewCountroller.isConnectedToNetwork() {
            currentViewCountroller.isInterntConnected(){_ in
                self.startRequest(params: params, completion:completion)
            }
            return
        }
        
        
        if showIndicator{
            currentViewCountroller.showIndicator()
        }
        
        startRequest(api: self,nestedParams :nestedParams ,params: params,data: data,headers: HTTPHeaders(headers)) { (result,status,message) in
            if API.DEBUG {
                self.printResponse(result: result)
            }
            
            if showIndicator{
                currentViewCountroller.hideIndicator()
            }
            
            let statusResult = StatusResult(json: result)
            
            if !status {
                statusResult.isSuccess = status
                statusResult.errorMessege = message
            }
            completion(self,statusResult)
        }
    }
    
    
    
    
    private func startRequest(api :API,nestedParams :String = "",params : [String:String] = [:],data : [String:Data] = [:],headers: HTTPHeaders = [:], completion:@escaping ([String:Any],Bool,String)->Void){
        print("full domain \(api.values.url + nestedParams)")
        AF.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in params {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key )
            }
            
            
            for (key, value) in data {
                multipartFormData.append(value, withName: key,fileName: "\(key).jpg", mimeType: "image/jpeg")
            }
            
        }, to: api.values.url + nestedParams , method:api.values.reqeustType ,headers: headers).uploadProgress {(progress) in
            print("file upload progress \(progress)%")
            
        }.responseJSON { (response) in
            
            if API.DEBUG {
                if let statusCode = response.response?.statusCode {
                    print(API.TAG + "status code : \(statusCode)" )
                }
            }
            
            switch(response.result)
            {
            case .success(let value):
                if let resp = value as? [String:Any] {
                    completion(resp,true,"")
                }else {
                    completion([:],false,"no data was found in response")
                }
                if API.DEBUG {
                    debugPrint(value)
                }
            case .failure(let error) :
                if API.DEBUG {
                    print(response.error.debugDescription)
                    print(error.errorDescription ?? "")
                    
                }
                completion([:],false,error.localizedDescription)
            }
            
            
        }
    }
    
    private func startRequest(api :API,nestedParams :String = "",params :Parameters = [:],header: HTTPHeaders = [:], completion:@escaping ([String:Any],Bool,String)->Void){
        
        AF.request(api.values.url+nestedParams, method: api.values.reqeustType, parameters: params.isEmpty ? nil:params,encoding: URLEncoding.default, headers: header.isEmpty ? nil:header)
            //.validate(statusCode: 200..<600)
            .responseJSON { response  in
                if API.DEBUG {
                    if let statusCode = response.response?.statusCode {
                        print(API.TAG + "status code : \(statusCode)" )
                    }
                }
                
                switch(response.result)
                {
                case .success(let value):
                    if API.DEBUG {
                        let res = JSON(value)
                        print(res)
                    }
                    if let resp = value as? [String:Any] {
                        completion(resp,true,"")
                    }else {
                        completion([:],false,"no data was found in response")
                    }
                    if API.DEBUG {
                        debugPrint(value)
                    }
                case .failure(let error) :
                    if API.DEBUG {
                        print(response.error.debugDescription)
                        print(error.errorDescription ?? "")
                        
                    }
                    completion([:],false,error.localizedDescription)
                }
                
            }
    }
    
    
    
}
