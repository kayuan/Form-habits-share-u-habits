//
//  AppDelegate.swift
//  HabitPromiss
//
//  Created by 주호박 on 2018. 5. 24..
//  Copyright © 2018년 주호박. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    lazy var launchView = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //런치 스크린 0.5초 이후에 꺼지도록..
        Thread.sleep(forTimeInterval: 0.5)
        
        // 로컬 노티 알람 옵션이 Allow 안되있을 경우 딜리게이트를 통해 그 알랏을 띄운다.
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        } else {
            // Fallback on earlier versions
        }
        return true
    }
    
    // background 들어갈때..
    func applicationWillResignActive(_ application: UIApplication) {
        window?.addSubview((launchView?.view)!)
    }
    // back -> 활성화 될때
    func applicationDidBecomeActive(_ application: UIApplication) {
        if #available(iOS 11.0, *) {
            if (window?.contains((launchView?.view)!))!{
                launchView?.view.removeFromSuperview()
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {// tap 제스쳐 발생시 keyboard dismiss
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate{
    // 로컬 노티를 띄우기 위해서 확인 알랏을 띄우는 거임.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}


  


