//
//  Constant.swift
//  Sublime
//
//  Created by Eular on 4/26/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation

struct Constant {
    // Color
    static let TableCellColor = "#515151".color
    static let TableCellSeparatorColor = "#515151".color
    static let TableCellSelectedColor = RGB(60, 60, 60)
    static let ActionSheetColor = UIColor.whiteColor()
    static let ActionSheetTextColor = UIColor.blackColor()
    static let ActionSheetLineColor = RGB(200, 200, 200, alpha: 0.5)
    static let BlackMaskViewColor = RGB(0, 0, 0, alpha: 0.5)
    
    static let CapeCod = RGB(81, 81, 81)
    static let CodeBackgroudColor = RGB(52, 53, 46)
    static let CodeLineNumberBackgroudColor = RGB(39, 40, 34)
    static let TableLoadingCircleColor = RGB(78, 221, 200)
    static let GithubTableShowMsgLabelTextColor = UIColor.grayColor()
    static let GithubTableShowMsgLabelTextShadowColor = RGB(40, 40, 40)
    static let TabBatItemBadgeColor = RGB(256, 0, 0, alpha: 0.8)
    static let PopupMenuColor = UIColor.whiteColor()
    
    static let NavigationBarColor = RGB(81, 81, 81)
    static let NavigationBarAndTabBarColor = RGB(81, 81, 81)
    
    // Identifies
    static let GithubTableCellIdentifier = "GithubTableCellIdentifier"
    static let SettingTableCellIdentifier = "SettingTableCellIdentifier"
    static let GithubSegue = "githubSegue"
    static let FolderStoryboardID = "FolderStoryboard"
    static let ContactTableStoryboardID = "ContactTableVC"
    static let ContactInfoStoryboardID = "ContactInfoVC"
    
    static let AppGithubUrl = "https://github.com/urinx"
    
    // Number
    static let TabBarHeight: CGFloat = 49
    static let FilesTableSectionHight: CGFloat = 22
    static let SSHServerListCellHeight: CGFloat = 60
    static var NavigationBarOffset: CGFloat {
        guard let navBar = UIApplication.topViewController()?.navigationController?.navigationBar else { return 64 }
        return navBar.y + navBar.height
    }
    
    // License
    static let License = [
        "AASquaresLoading", "Alamofire", "AlamofireRSSParser", "Charts",
        "CYRTextView", "DGElasticPullToRefresh", "EZAudio",
        "Gifu", "NMSSH", "MobileVLCKit", "RongCloudIMKit", "SJCSimplePDFView", "SSZipArchive",
        "Swifter", "SwiftyJSON", "ZLMusicFlowWaveView", "ZLSinusWaveView"
    ]
    
    // Github Application
    static let githubClientID = "5b2b9bdf9c689989240c"
    static let githubClientSecret = "538fb1ae3b29ff7a5c86dea3b2605870a3d9e146"
    
    // Weixin Application
    static let weixinAppID = "wxb597aecde6aadd28"
    // static let weixinAppID = "wxeb7ec651dd0aefa9" //微信网页版ID
    
    // 融云
    static let RongCloudAppKey = "m7ua80gbu9itm"
    static let RongCloudAppSecret = "n36KioPk7esTtR"
    
    static let RongCloudAuthorUserID = "Urinx"
    static let RongCloudAuthorUserName = "Uri"
    static let RongCloudDefaultUserPortrait = "http://cdn.duitang.com/uploads/item/201509/27/20150927191624_2tnMS.thumb.700_0.jpeg"
    static let RongCloudRobotID = "KEFU145857181547734"
    static let RongCloudRobotName = "客服机器人"
    
    static let RongCloudUnreadMessageNotifi = "hasUnreadMessagesNotifi"
    
    // Share Items
    static let PopupMenuDefaultShareItems = [
        ["title":"QQ", "image":"Share_qq_icon"],
        ["title":"新浪微博", "image":"Share_sina_icon"],
        ["title":"微信", "image":"Share_wechat_session_icon"],
        ["title":"朋友圈", "image":"Share_wechat_timeline_icon"],
        ["title":"Facebook", "image":"Share_facebook_icon"],
        ["title":"Line", "image":"Share_line_icon"],
        ["title":"Instagram", "image":"Share_instagram"],
        ["title":"Twitter", "image":"Share_twitter_icon"],
        ["title":"QQ空间", "image":"Share_qzone_icon"],
        ["title":"Pinterest", "image":"Share_pinterest_icon"],
        ["title":"豆瓣", "image":"Share_douban_icon"]
    ]
    
    static var SublimeRoot: String {
        return NSHomeDirectory() + "/Documents/.Sublime"
    }
    
    static var CachePath: String {
        return NSHomeDirectory() + "/Library/Caches/"
    }
    
    static let AppGithubLink = "https://github.com/Urinx/Sublime"
}
