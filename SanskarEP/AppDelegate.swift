//
//  AppDelegate.swift
//  SanskarEP
//
//  Created by Warln on 10/01/22.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate,MessagingDelegate  {
    
    var window: UIWindow?
    let gcmMessageIDKey = "sanskarEp"
    var fcmString: String = ""
    static private(set) var shared: AppDelegate?
//    var appDel:AppDelegate? = nil

    lazy var operationQueue:OperationQueue = {
         let queue = OperationQueue()
         queue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
         queue.name = "ServerInteractionQueue"
         queue.qualityOfService = .background
         return queue
     }()
     
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
            )
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                print( "Remote FCM registration token: \(token)")
                self.fcmString = token
//                UserDefaults.standard.set(token, forKey: "token")
//                idenity.kDeviceToken = token
            }
        }
        AppFlow()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        return true
    }
    
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    //    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    //MARK: - --------------------Messages------------------------------------
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        print("Firebase registration token: \(String(describing: fcmToken))")
//        
//        let dataDict: [String: String] = ["token": fcmToken ?? ""]
//        NotificationCenter.default.post(
//            name: Notification.Name("FCMToken"),
//            object: nil,
//            userInfo: dataDict
//        )
//    }
    
//    func application(_ application: UIApplication,
//                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        Messaging.messaging().apnsToken = deviceToken
//        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
//        print(token)
//         if token.isEmpty{
//            UserDefaults.standard.set(fcmString, forKey: "token")
//            idenity.kDeviceToken = token
//        }else{
//             UserDefaults.standard.set(token, forKey: "token")
//            idenity.kDeviceToken = token
//        }
//    }
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("APNs Device Token: \(token)")

        Messaging.messaging().token { fcmToken, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let fcmToken = fcmToken {
                print("FCM Token: \(fcmToken)")
                self.fcmString = fcmToken
                UserDefaults.standard.set(fcmToken, forKey: "token")
            }
        }
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        print("Firebase registration token received: \(fcmToken)")
        self.fcmString = fcmToken
        UserDefaults.standard.set(fcmToken, forKey: "token")
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                                -> Void) {
        let userInfo = notification.request.content.userInfo
        print(userInfo)
        completionHandler([[.alert,.sound]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        if currentUser.EmpCode != "" {
            NotificationCenter.default.post(name: NSNotification.Name("Note"), object: nil)
            note = true
        }
        completionHandler()
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)
                     -> Void) {
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
        
    }
    
    
    //MARK: - App Flow
    func AppFlow() {
        
        if currentUser.EmpCode != "" {
            let story = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = story.instantiateViewController(withIdentifier: "NewHomeVC") as! NewHomeVC
            AppDelegate.shared?.window?.rootViewController = vc
            AppDelegate.shared?.window?.makeKeyAndVisible()
        }else{
            let story = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = story.instantiateViewController(withIdentifier: idenity.login) as! LoginVc
            AppDelegate.shared?.window?.rootViewController = vc
            AppDelegate.shared?.window?.makeKeyAndVisible()
        }
    }
    
    
}



