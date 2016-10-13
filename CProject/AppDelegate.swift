//
//  AppDelegate.swift
//  CProject
//
//  Created by wpf on 16/9/19.
//  Copyright © 2016年 alex. All rights reserved.
//

import UIKit
import Foundation
import SVProgressHUD
import StoreKit
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var tabConfig: WTabBarController?
    var timer: Timer?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        SKPaymentQueue.default().add(IAPHelper.sharedInstance)
                
        
        self.initBase()
        self.initRoot()
        
        self.window?.backgroundColor = UIColor.white
        self.window?.makeKeyAndVisible()
        return true
    }
    
    func initBase() {
        WXApi.registerApp(WeChatAppID)
        
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.setForegroundColor(UIColor.cyan)
        SVProgressHUD.setBackgroundColor(PD_SVProgressColor())
        SVProgressHUD.setMinimumDismissTimeInterval(2)
    }
    
    func initRoot() {
        self.tabConfig = WTabBarController()
        self.window?.rootViewController = self.tabConfig
    }
    
    func reQuest() -> Void {
        NetWorkHelper.rePostData()
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if url.host == "safepay" {
            AlipaySDK.defaultService().processOrder(withPaymentResult: url, standbyCallback: { (resultDic) in
                AlipayHelper.shared().aliPayResult(resultDic, vc: self.window?.rootViewController)
            })
        } else {
            WXApi.handleOpen(url, delegate: WXApiManager.shared())
        }
        
        
        
        return true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        let ti:TimeInterval = 60*15
        self.timer = Timer.scheduledTimer(timeInterval: ti, target: self, selector:#selector(AppDelegate.reQuest), userInfo: nil, repeats: true)
        self.timer?.fire()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

