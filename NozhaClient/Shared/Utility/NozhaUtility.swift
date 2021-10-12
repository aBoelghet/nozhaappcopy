//
//  NozhaUtility.swift
//  NozhaUser
//
//  Created by mac book air on 1/3/21.
//

import Foundation
import UIKit
import FirebaseMessaging
import FirebaseInstanceID
import Branch


class NozhaUtility: NSObject {
    
    
    
    static func isLogin() -> Bool{
        return UserDefaults.standard.object(forKey: "user") != nil
    }
    
    static func isCustomer() -> Bool{
        return self.loadUser()?.type == "customer"
    }
    
    
    
    static func GreaterIphoneX() -> Bool {
        let screenWidht = UIScreen.main.bounds.size.width
        
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone) {
            
            if ( screenWidht > 375) {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    
    static func saveFcmToken(fcmToken :String){
        UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
    }
    static func getFcmToken() -> String{
        return UserDefaults.standard.value(forKey: "fcmToken") as? String ?? ""
        
    }
    
    static func saveSettings(setting :Settings){
        UserDefaults.standard.set(try! PropertyListEncoder().encode(setting), forKey: "setting")
    }
    
    static func loadSetting() -> Settings?
    {
        let storedObject: Data? = UserDefaults.standard.object(forKey: "setting") as? Data
        if(storedObject != nil){
            guard let setting :Settings =  try? PropertyListDecoder().decode(Settings.self, from: storedObject!) else {
                return nil
            }
            return setting
        }
        return nil

    }
    static func saveUser(user :User){
        UserDefaults.standard.set(try! PropertyListEncoder().encode(user), forKey: "user")
        NozhaUtility.setCityId(cityId: user.city?.id ?? 0)
       
    }
    
 
    static func loadUser() -> User?{
        let storedObject: Data? = UserDefaults.standard.object(forKey: "user") as? Data
        if(storedObject != nil){
            guard let user :User =  try? PropertyListDecoder().decode(User.self, from: storedObject!) else {
                return nil
            }
            return user
        }
        return nil
        
    }
    
  
    static func isSubscribe() -> Bool{
        return UserDefaults.standard.bool(forKey: "subscribe")
    }
    
    static func setIsSubscribe(subscribe :Bool){
        UserDefaults.standard.set(subscribe, forKey: "subscribe")
    }
    

    
    static func cityId() -> Int{
        return UserDefaults.standard.integer(forKey: "city_id")
    }
    
    static func setCityId(cityId :Int){
        
        UserDefaults.standard.set(cityId, forKey: "city_id")
       
    }
    
    
    
    static func getNotificationNo() -> Int{
        return UserDefaults.standard.integer(forKey: "unread_notifications")
    }
    
    static func setNotificationNo(notifcation_number: Int){
        return UserDefaults.standard.set(notifcation_number, forKey: "unread_notifications")
    }
    
    
    
    
    static func logOut()
    {
        API.LOGOUT.startRequest(showIndicator: false) { (Api,response) in  }
        
        UserDefaults.standard.removeObject(forKey: "user")
        UserDefaults.standard.removeObject(forKey: "fcmToken")
        UserDefaults.standard.synchronize()
        NozhaUtility.setNotificationNo(notifcation_number: 0)
        UIApplication.shared.applicationIconBadgeNumber = 0
        Branch.getInstance().logout()
        Messaging.messaging().unsubscribe(fromTopic: API.USER_FIREBASE_SUBSCRIBE_Topic){ error in

            if error == nil {
                InstanceID.instanceID().deleteID { (error) in
                    if error != nil{
                        print("FIREBASE: ", error.debugDescription);

                    } else {
                        print("FIREBASE: Token Deleted");
                        print("FIREBASE: \(error.debugDescription)");
                        print("FIREBASE: \(error?.localizedDescription ?? "")");
                    }
                }

            }
        }
        Messaging.messaging().unsubscribe(fromTopic: NozhaUtility.isCustomer() ? API.GENERAL_FIREBASE_SUBSCRIBE_Topic_CUSTOMERS : API.GENERAL_FIREBASE_SUBSCRIBE_Topic_SUPPLIER){ error in

            if error == nil {
                InstanceID.instanceID().deleteID { (error) in
                    if error != nil{
                        print("FIREBASE: ", error.debugDescription);

                    } else {
                        print("FIREBASE: Token Deleted");
                        print("FIREBASE: \(error.debugDescription)");
                        print("FIREBASE: \(error?.localizedDescription ?? "")");
                    }
                }

            }
        }
       
        
        
        
        
    }
    
}
