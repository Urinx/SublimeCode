//
//  RCIM.swift
//  Sublime
//
//  Created by Eular on 3/23/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation
import Alamofire

// RongCloud
extension RCIM {
    
    func Login() {
        if let token = Global.Database.stringForKey("RongCloud-UserToken") {
            let user = GitHubAPIManager.sharedInstance.user
            let name = user["name"].string
            let portrait = user["avatar_url"].string
            
            RCIM.sharedRCIM().connectWithToken(token,
                success: { (userId) -> Void in
                    Log("登陆成功。当前登录的用户ID：\(userId)")
                    RCIM.sharedRCIM().currentUserInfo = RCUserInfo.init(userId: userId, name: name ?? userId, portrait: portrait ?? Constant.RongCloudDefaultUserPortrait)
                }, error: { (status) -> Void in
                    Log("登陆的错误码为: \(status.rawValue)")
                }, tokenIncorrect: {
                    Log("token错误")
                    self.getTokenAndLogin()
            })
        } else {
            Log("用户token不存在")
        }
    }
    
    private func makeHeaders() -> [String: String] {
        let appkey = Constant.RongCloudAppKey
        let appSecret = Constant.RongCloudAppSecret
        let nonce = String(random())
        let ts = String(timestamp())
        let signature = (appSecret + nonce + ts).sha1
        let headers = ["App-Key": appkey, "Nonce": nonce, "Timestamp": ts, "Signature": signature]
        return headers
    }
    
    func getToken(id: String, name: String, portrait: String, complete: () -> ()) {
        let url = "https://api.cn.rong.io/user/getToken.json"
        let params = ["userId": id, "name": name, "portraitUri": portrait]
        let headers = makeHeaders()
        
        Alamofire.request(.POST, url, parameters: params, headers: headers).responseJSON { response in
            if let data = response.result.value {
                if let token = data.stringForKey("token") {
                    Log("获取Token成功: \(token)")
                    Global.Database.setValue(token, forKey: "RongCloud-UserToken")
                    complete()
                }
            }
        }
    }
    
    func getInfo(id: String, complete: (String, String) -> ()) {
        
        if let info = Global.Database.objectForKey("RongCloud-User-\(id)") {
            let name = info.stringForKey("name")!
            let portrait = info.stringForKey("portrait")!
            complete(name, portrait)
            return
        }
        
        let url = "https://api.cn.rong.io/user/info.json"
        let params = ["userId": id]
        let headers = makeHeaders()
        
        Alamofire.request(.POST, url, parameters: params, headers: headers).responseJSON { response in
            if let data = response.result.value {
                Log("获取用户信息成功: \(data)")
                
                let name = data.stringForKey("userName") ?? id
                let portrait = data.stringForKey("userPortrait") ?? Constant.RongCloudDefaultUserPortrait
                Global.Database.setObject(["name": name, "portrait": portrait], forKey: "RongCloud-User-\(id)")
                complete(name, portrait)
            }
        }
    }
    
    func getTokenAndLogin() {
        let user = GitHubAPIManager.sharedInstance.user
        let id = user["login"].string!
        let name = user["name"].string ?? id
        let portrait = user["avatar_url"].string ?? Constant.RongCloudDefaultUserPortrait
        
        getToken(id, name: name, portrait: portrait, complete: Login)
    }
}

