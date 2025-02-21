//
//  AppDelegate.swift
//  SanskarEP
//
//  Created by Warln on 10/01/22.
//
import Firebase
import UserNotifications
import FirebaseMessaging
import FirebaseCore
import UIKit
import IQKeyboardManagerSwift
import AVFoundation
import FirebaseMessaging
import FirebaseCore
@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate,MessagingDelegate  {
    var audioPlayer: AVAudioPlayer?
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
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        UNUserNotificationCenter.current().delegate = self
        if #available(iOS 10.0, *) {
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
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings.authorizationStatus.rawValue)")
        }
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM Token: \(token)")
                self.fcmString = token
                UserDefaults.standard.set(token, forKey: "token")
                idenity.kDeviceToken = token
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
                UserDefaults.standard.set(token, forKey: "token")
                idenity.kDeviceToken = token
            }
        }
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        print("Firebase registration token received: \(fcmToken)")
        self.fcmString = fcmToken
      //  UserDefaults.standard.set(fcmToken, forKey: "token")
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                                -> Void) {
        let userInfo = notification.request.content.userInfo
        print(userInfo)
       // playNotificationSound()
        if let notificationType = userInfo["data"] as? [String: Any],
              let type = notificationType["notification_type"] as? Int {
               playNotificationSound(type: type)
           } else {
               playNotificationSound(type: nil)
           }
        if #available(iOS 14.0, *) {
            completionHandler([[.banner,.alert,.sound]])
        } else {
            completionHandler([[.alert,.sound]])
        }
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
        if let aps = userInfo["aps"] as? [String: Any],
           let alert = aps["alert"] as? [String: Any],
           let notificationTitle = alert["title"] as? String {
            DispatchQueue.main.async {
                if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                    if let navigationController = rootViewController as? UINavigationController {
                        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NotificationVc") as? NotificationVc {
                            vc.titleTxt = "Notification"
                            navigationController.pushViewController(vc, animated: true)
                        }
                    } else {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let vc = storyboard.instantiateViewController(withIdentifier: "NotificationVc") as? NotificationVc {
                            vc.titleTxt = "Notification"
                            let navController = UINavigationController(rootViewController: vc)
                            UIApplication.shared.windows.first?.rootViewController = navController
                            UIApplication.shared.windows.first?.makeKeyAndVisible()
                        }
                    }
                }
            }
        }

        completionHandler()
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)
                     -> Void) {
        Messaging.messaging().appDidReceiveMessage(userInfo)
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
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

    func playNotificationSound(type: Int?) {
        var soundFileName: String

        switch type {
        case 8:
            soundFileName = "bell" // Replace with actual file name
        case 7:
            soundFileName = "bell2/7" // Replace with actual file name
        default:
            soundFileName = "bell2" // Default sound
        }

        guard let soundURL = Bundle.main.url(forResource: soundFileName, withExtension: "mp3") else {
            print("Sound file not found!")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }

}



