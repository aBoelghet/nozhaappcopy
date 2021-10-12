//
//  LaunchScreenVC.swift
//  NozhaUser
//
//  Created by mac book air on 1/2/21.
//

import UIKit

class LaunchScreenVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if  NozhaUtility.isLogin() {
            updateUser()
        }
        startReqestGetCities()
        startReqestGetDurations()
        startReqestGetCategories()
        startReqestGetSettingsData()
        
        
    }
    
    
    func updateUser()
    {
        API.GET_USER.startRequest(showIndicator: false) { (api, response) in
            if response.isSuccess {
                let value = response.data as! [String :Any]
                let userData = try! JSONSerialization.data(withJSONObject: value, options: [])
                let user = try! JSONDecoder().decode(User.self, from: userData)
                NozhaUtility.saveUser(user :user)
                NozhaUtility.setCityId(cityId:user.city?.id ?? 0)
                NozhaUtility.setNotificationNo(notifcation_number:user.unreadNotifications ?? 0)
                UIApplication.shared.applicationIconBadgeNumber = user.unreadNotifications ?? 0
                
                NozhaUtility.setIsSubscribe(subscribe: true)
                self.subscribeToNotificationsTopic()
                
                
            }
            
        }
    }
    
    func startReqestGetCities()
    {
        API.CITIES.startRequest(showIndicator: false) { (api, response) in
            if response.isSuccess {
                let value = response.data
                let citiesData = try! JSONSerialization.data(withJSONObject: value, options: [])
                let Cities = try! JSONDecoder().decode([City].self, from: citiesData)
                Constants.cities = Cities
                if NozhaUtility.isLogin() {
                    if NozhaUtility.isCustomer() {
                        self.routeToHomeCustomer()
                    }else {
                        self.routeToHomeSP()
                    }
                }else {
                    if NozhaUtility.cityId() != 0 {
                        self.routeToHomeCustomer()
                    }else {
                        self.routeToUserCities()
                    }
                }
                
            }
            else
            {
                self.showOkAlert(title: "", message: response.message)
            }
        }
    }
    
    func startReqestGetDurations()
    {
        API.DURATIONS.startRequest(showIndicator: false) { (api, response) in
            if response.isSuccess {
                let value = response.data
                let durationsData = try! JSONSerialization.data(withJSONObject: value, options: [])
                let durations = try! JSONDecoder().decode([Duration].self, from: durationsData)
                Constants.durations = durations
                
            }
            else
            {
                self.showOkAlert(title: "", message: response.message)
            }
        }
    }
    func startReqestGetSettingsData()
    {
        API.SETTINGS.startRequest(showIndicator: false) { (api, response) in
            if response.isSuccess {
                let value = response.data
                let settingData = try! JSONSerialization.data(withJSONObject: value, options: [])
                let setting = try! JSONDecoder().decode(Settings.self, from: settingData)
                NozhaUtility.saveSettings(setting: setting)
                
                
            }
            else
            {
                self.showOkAlert(title: "", message: response.message)
            }
        }
    }
    
    func startReqestGetCategories()
    {
        API.CATEGORIES.startRequest(showIndicator: false) { (api, response) in
            if response.isSuccess {
                let value = response.data
                let categoriesData = try! JSONSerialization.data(withJSONObject: value, options: [])
                let categories = try! JSONDecoder().decode([Category].self, from: categoriesData)
                Constants.categories = categories
                
            }
            else
            {
                self.showOkAlert(title: "", message: response.message)
            }
        }
    }
    
    
    
}
