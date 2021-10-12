//
//  AppDelegate.swift
//  NozhaUser
//
//  Created by mac book air on 12/22/20.
//

import UIKit
import CoreData
import MOLH
import IQKeyboardManagerSwift
import GoogleMaps
import Firebase
import FirebaseMessaging
import Sentry
import Branch


@UIApplicationMain
class AppDelegate:  UIResponder, UIApplicationDelegate , UNUserNotificationCenterDelegate  {
    
    var window: UIWindow?
    static let GOOGLE_MAP_API_KEY = "AIzaSyA_wumWncuQeIQMfQ1GNx6BB5v1CNFm3vI"
    var sortedBy = SortedDialogVC.all
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initLanguage()
        UIFont.overrideInitialize()
        FirebaseApp.configure()
        registerNotification()
        GMSServices.provideAPIKey(AppDelegate.GOOGLE_MAP_API_KEY)
        IQKeyboardManager.shared.enable = true
        SentrySDK.start { options in
            options.dsn = "https://f82e9c0292ab4cb0b84448c3e7fff3fb@o545168.ingest.sentry.io/5666662"
            options.debug = true // Enabled debug when first installing is always helpful
        }
        Branch.setUseTestBranchKey(false)
        // listener for Branch Deep Link data
        Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
            // do stuff with deep link data (nav to page, display content, etc)
            print(params as? [String: AnyObject] ?? {})
            
            if params?["id"] != nil {
                
                var service_id = params?["id"] as? Int ?? 0
                if service_id == 0 {
                    service_id = Int(params?["id"] as? String ?? "0") ?? 0
                }
                let serviceID = ["id": service_id ] as [String : Any]
              
                var supplier_id = params?["supplier"] as? Int ?? 0
                if supplier_id == 0 {
                    supplier_id = Int(params?["supplier"] as? String ?? "0") ?? 0
                }
                let supplierID = ["supplier": supplier_id ] as [String : Any]
                
                print("Service id \(serviceID)")
                print("supplier id \(supplierID)")
                
                let info = ["id": serviceID,
                            "supplier" :supplierID
                ] as [String : Any]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ServiceDetailsNotification"), object: self, userInfo: info)
            }
        }
        return true
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Branch.getInstance().application(app, open: url, options: options)
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
       
        Branch.getInstance().handlePushNotification(userInfo)
    }
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // handler for Universal Links
        Branch.getInstance().continue(userActivity)
        return true
    }
    func initLanguage(){
        
        MOLHLanguage.setDefaultLanguage("ar")
        if NozhaUtility.isLogin() && NozhaUtility.loadUser()?.locale != nil{
            
            MOLH.setLanguageTo(NozhaUtility.loadUser()?.locale ?? "ar")
        }else{
            MOLH.setLanguageTo(MOLHLanguage.currentLocaleIdentifier())
        }
        if MOLHLanguage.isArabic() {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        }else {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        MOLH.shared.activate(true)
        
    }
    
    func initAppInterface()
    {
        if MOLHLanguage.currentLocaleIdentifier() == "ar" {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        }else {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        
    }
    
    
    func registerNotification(){
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        
        
        let center  = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
            if error == nil{
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        Messaging.messaging().delegate = self
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                
                NozhaUtility.saveFcmToken(fcmToken: token )
            }
        }
        
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "NozhaUser")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

extension AppDelegate : MOLHResetable{
    static var shared : AppDelegate{
        get{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            return appDelegate
        }
    }
    
    
    
    
    var viewController :UIViewController {
        get{
            var topController = self.window!.rootViewController!
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            return topController
        }
    }
    
    var language :String {
        set{
            MOLH.setLanguageTo(newValue)
            MOLH.reset()
        }
        get{
            return MOLHLanguage.currentLocaleIdentifier()
        }
    }
    
    
    
    func reset() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LaunchScreenVC")
        self.window!.rootViewController = vc
    }
    
    @available(iOS 13.0, *)
    func swichRoot(){
        //Flip Animation before changing rootView
        animateView()
        
        // switch root view controllers
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LaunchScreenVC")
        
        let scene = UIApplication.shared.connectedScenes.first
        if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
            sd.window!.rootViewController = vc
        }
        
    }
    @available(iOS 13.0, *)
    func animateView() {
        var transition = UIView.AnimationOptions.transitionFlipFromRight
        if !MOLHLanguage.isRTLLanguage() {
            transition = .transitionFlipFromLeft
        }
        animateView(transition: transition)
    }
    
    @available(iOS 13.0, *)
    func animateView(transition: UIView.AnimationOptions) {
        if let delegate = UIApplication.shared.connectedScenes.first?.delegate {
            UIView.transition(with: (((delegate as? SceneDelegate)!.window)!), duration: 0.5, options: transition, animations: {}) { (f) in
            }
        }
    }
    
    
    
}
extension AppDelegate: MessagingDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        
        print("will present user info\(notification.request.content.userInfo)")
        let userInfo = notification.request.content.userInfo
        if userInfo["id"] != nil {
            
            
            let badge = userInfo["unread_notifications"] as? String ?? "0"
            
            let badge_no = Int(badge)
            NozhaUtility.setNotificationNo(notifcation_number: badge_no ?? 0)
            if badge_no  ?? 0 > 0 {
                NozhaUtility.setNotificationNo(notifcation_number:badge_no ?? 0 )
                UIApplication.shared.applicationIconBadgeNumber = badge_no ?? 0
                let BadgeInfo = ["badge": badge_no ?? 0] as [String : Any]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateNotificationNumber"), object: self, userInfo: BadgeInfo)
            }
            
            
            
        }
        completionHandler([.alert, .badge, .sound])
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(" did rcv user info\(response.notification.request.content.userInfo)")
        handelNotification(ofUserInfo: response.notification.request.content.userInfo)
        completionHandler()
    }
    
    
    
    
    
    func handelNotification(ofUserInfo userInfo :[AnyHashable : Any]){
        if userInfo["id"] != nil {
            
            let id = userInfo["id"] as? String ?? "0"
            let badge = userInfo["unread_notifications"] as? String ?? "0"
            let notification_id = userInfo["notification_id"] as? String ?? ""
            let uuid = userInfo["uuid"] as? String ?? ""
            let type = userInfo["type"] as? String ?? ""
            
            let badge_no = Int(badge)
            if badge_no ?? 0 > 0 {
                NozhaUtility.setNotificationNo(notifcation_number:badge_no ?? 0 )
                UIApplication.shared.applicationIconBadgeNumber = badge_no ?? 0
                let BadgeInfo = ["badge": badge_no ?? 0] as [String : Any]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateNotificationNumber"), object: self, userInfo: BadgeInfo)
            }
            
            let info = ["id": Int(id) ?? 0,
                        "notification_id" : notification_id,
                        "uuid":uuid,
                        "type":type
            ] as [String : Any]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "handelNotification"), object: self, userInfo: info)
            
            
        }
    }
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken ?? "")")
        
        NozhaUtility.saveFcmToken(fcmToken: fcmToken ?? "")
        Messaging.messaging().subscribe(toTopic: API.GENERAL_FIREBASE_SUBSCRIBE_Topic)
        if NozhaUtility.isSubscribe() && NozhaUtility.isLogin()
        {
            Messaging.messaging().subscribe(toTopic: API.USER_FIREBASE_SUBSCRIBE_Topic)
        }
        if NozhaUtility.isCustomer()
        {
            Messaging.messaging().subscribe(toTopic: API.GENERAL_FIREBASE_SUBSCRIBE_Topic_CUSTOMERS)
        }else {
            Messaging.messaging().subscribe(toTopic: API.GENERAL_FIREBASE_SUBSCRIBE_Topic_SUPPLIER)
        }
        
        
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                
                NozhaUtility.saveFcmToken(fcmToken: token )
            }
        }
    }
}

