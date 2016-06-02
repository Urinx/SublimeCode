//
//  AppDelegate.swift
//  Sublime
//
//  Created by Eular on 2/10/16.
//  Copyright © 2016 Eular. All rights reserved.
//

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate, RCIMUserInfoDataSource, RCIMReceiveMessageDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        window?.backgroundColor = Constant.CapeCod
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        UINavigationBar.appearance().barStyle = UIBarStyle.Black
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // Remove navigationBar border
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(Constant.NavigationBarColor.toImage(), forBarMetrics: UIBarMetrics.Default)
        
        UITabBar.appearance().barTintColor = Constant.NavigationBarAndTabBarColor
        UITabBar.appearance().tintColor = UIColor.whiteColor()
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.grayColor()], forState: UIControlState.Normal)
        
        // Remove tabBar border
        UITabBar.appearance().translucent = false
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        
        // 微信
        WXApi.registerApp(Constant.weixinAppID)
        
        // 融云
        RCIM.sharedRCIM().showUnkownMessageNotificaiton = true
        RCIM.sharedRCIM().enableTypingStatus = true
        RCIM.sharedRCIM().initWithAppKey(Constant.RongCloudAppKey)
        RCIM.sharedRCIM().userInfoDataSource = self
        RCIM.sharedRCIM().receiveMessageDelegate = self
        
        // 推送处理
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes:[.Alert, .Badge, .Sound], categories: nil))
        
        RCIM.sharedRCIM().Login()
        
        // Cycript
        if Config.CycriptStartListen { CYListenServer(8888) }
        
        return true
    }
    
    func getUserInfoWithUserId(userId: String!, completion: ((RCUserInfo!) -> Void)!) {
        RCIM.sharedRCIM().getInfo(userId) { (name, portrait) in
            var username = name
            if (userId == Constant.RongCloudAuthorUserID) {
                username = Constant.RongCloudAuthorUserName
            }
            completion(RCUserInfo(userId: userId, name: username, portrait: portrait))
        }
    }
    
    func onRCIMReceiveMessage(message: RCMessage!, left: Int32) {
        Global.UnreadMessageCount += 1
        if left == 0 {
            Global.Notifi.postNotificationName(Constant.RongCloudUnreadMessageNotifi, object: nil)
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return WXApi.handleOpenURL(url, delegate: self)
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        // 处理 github token 跳转的链接
        GitHubAPIManager.handleURL(url)
        
        // 处理接收到的文件
        if url.fileURL {
            let app = options[UIApplicationOpenURLOptionsSourceApplicationKey] ?? "AirDrop"
            Log("Receive a file from \(app!), url: \(url)")
        }
        
        // 微信
        return WXApi.handleOpenURL(url, delegate: self)
    }

}

