//
//  AppDelegate.swift
//  ShowMe
//
//  Created by Karthick Selvaraj on 06/01/20.
//  Copyright © 2020 Demo. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Reachability

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var reachabilityManager: Reachability?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        checkNetworkAvailablity()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        return true
    }
    
    // MARK: - UISceneSession Lifecycle
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    // MARK: - Custom methods
    
    /**Configures etwork reachability monitoring*/
    func checkNetworkAvailablity() {
        do {
            reachabilityManager = try Reachability()
            NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(notification:)), name: .reachabilityChanged, object: reachabilityManager)
            perform(#selector(startNetworkListening), with: nil, afterDelay: 1.0)
        } catch {
            // Do nothing
        }
    }
    
    /**Starts network status change listner*/
    @objc func startNetworkListening() {
        do {
            try reachabilityManager?.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    @objc func reachabilityChanged(notification: Notification) {
        reachabilityManager = notification.object as? Reachability
        if let manager = reachabilityManager {
            switch manager.connection {
            case .wifi:
                NotificationCenter.default.post(name: Notification.Name(rawValue: kNetworkConnectedViaLANorWIFI) , object: nil)
            case .cellular:
                NotificationCenter.default.post(name: Notification.Name(rawValue: kNetworkConnectedViaLANorWIFI) , object: nil)
            case .unavailable, .none:
                NotificationCenter.default.post(name: Notification.Name(rawValue: kNetworkNotConnected) , object: nil)
            }
        }
    }
    
    /**Checks sevice network reachability status*/
    func isHavingNetworkReachability() -> Bool {
        guard let manager = reachabilityManager else { return true } // If `reachabilityManager` is nil, consider we have network connection. If network is not available we will show alert from API response.
        if manager.connection == .unavailable {
            return false
        } else {
            return true
        }
    }
    
}

