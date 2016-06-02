//
//  Configure.swift
//  Sublime
//
//  Created by Eular on 4/26/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation

struct Config {
    // Cycript开启监听
    static var CycriptStartListen: Bool {
        get {
            return Global.Database.boolForKey("Config-CycriptStartListen")
        }
        set {
            Global.Database.setBool(newValue, forKey: "Config-CycriptStartListen")
        }
    }
    
    // 下滑全屏
    static var FullScreenCodeReadingMode: Bool {
        get {
            return Global.Database.boolForKey("Config-FullScreenCodeReadingMode")
        }
        set {
            Global.Database.setBool(newValue, forKey: "Config-FullScreenCodeReadingMode")
        }
    }
    
    // 显示隐藏文件
    static var ShowHiddenFiles: Bool {
        get {
            return Global.Database.boolForKey("Config-ShowHiddenFiles")
        }
        set {
            Global.Database.setBool(newValue, forKey: "Config-ShowHiddenFiles")
        }
    }
    
    // 是否为本项目点赞
    static var Starred: Bool {
        get {
            return Global.Database.boolForKey("Donate-Starred")
        }
        set {
            Global.Database.setBool(newValue, forKey: "Donate-Starred")
        }
    }
    
    // 是否关注作者
    static var FollowedAuthor: Bool {
        get {
            return Global.Database.boolForKey("Donate-FollowedAuthor")
        }
        set {
            Global.Database.setBool(newValue, forKey: "Donate-FollowedAuthor")
        }
    }
    
    static var WeixinDonated: Bool {
        get {
            return Global.Database.boolForKey("Donate-WeixinDonated")
        }
        set {
            Global.Database.setBool(newValue, forKey: "Donate-WeixinDonated")
        }
    }
    
    static var AlipayDonated: Bool {
        get {
            return Global.Database.boolForKey("Donate-AlipayDonated")
        }
        set {
            Global.Database.setBool(newValue, forKey: "Donate-AlipayDonated")
        }
    }
}