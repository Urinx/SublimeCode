//
//  Github.swift
//  Sublime
//
//  Created by Eular on 2/24/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import UIKit
import Foundation
import SafariServices
import Alamofire
import SwiftyJSON

class GitHubAPIManager {

    private let clientID = Constant.githubClientID
    private let clientSecret = Constant.githubClientSecret
    private var OAuthToken: String!
    private var safariVC: SFSafariViewController?
    
    static let sharedInstance = GitHubAPIManager()
    static let GetOAuthCodeNotifi = "GetOAuthCodeNotifi"
    static let GetUserInfoDoneNotifi = "GetUserInfoDoneNotifi"
    
    static var isLogin: Bool {
        set {
            Global.Database.setBool(newValue, forKey: "github-islogin")
        }
        get {
            return Global.Database.boolForKey("github-islogin")
        }
    }
    
    let githubFolder: Folder!
    var user: JSON!
    var delegate: UIViewController? {
        didSet {
            self.addObserver(delegate!)
        }
    }
    
    init() {
        
        githubFolder = Folder(path: Constant.SublimeRoot+"/home/sublime/github")
        if !githubFolder.checkFileExist("stars") {
            githubFolder.newFolder("stars")
        }
        if !githubFolder.checkFileExist("repositories") {
            githubFolder.newFolder("repositories")
        }
        
        
        if GitHubAPIManager.isLogin {
            OAuthToken = Global.Database.stringForKey("github-oauthtoken")
            if let data = Global.Database.objectForKey("github-user") as? NSData {
                user = JSON(data: data)
            }
        } else {
            OAuthToken = ""
            user = JSON("")
        }
    }
    
    func OAuth2() {
        let OAuthURL = "https://github.com/login/oauth/authorize?scope=user,repo,gist&client_id=\(clientID)"
        safariVC = SFSafariViewController(URL: NSURL(string: OAuthURL)!)
        safariVC!.modalPresentationStyle = .OverCurrentContext
        delegate!.presentViewController(safariVC!, animated: true, completion: nil)
    }
    
    func handleOAuthCode(notification: NSNotification) {
        safariVC!.dismissViewControllerAnimated(true, completion: nil)
        let info = notification.userInfo as! Dictionary<String, AnyObject>
        let code = info["code"] as! String
        getOAuthToken(code)
    }
    
    private func getOAuthToken(code: String) {
        let TokenURL = "https://github.com/login/oauth/access_token"
        let params = ["client_id": clientID, "client_secret": clientSecret, "code": code]
        Alamofire.request(.POST, TokenURL, parameters: params).responseString { response in
            if let str = response.result.value {
                self.OAuthToken = str.split("&")[0].split("=")[1]
                Global.Database.setValue(self.OAuthToken, forKey: "github-oauthtoken")
                self.getUserInfo()
            }
        }
    }
    
    func getUserInfo() {
        let url = "https://api.github.com/user"
        let params = ["access_token": OAuthToken]
        Alamofire.request(.GET, url, parameters: params).responseJSON { response in
            if let data = response.result.value {
                self.user = JSON(data)
                Global.Database.setObject(try! self.user.rawData(), forKey: "github-user")
                GitHubAPIManager.isLogin = true
                Global.Notifi.postNotificationName(GitHubAPIManager.GetUserInfoDoneNotifi, object: nil)
            }
        }
    }
    
    func listRepositories(completion: (repos: [Repo]) -> Void) {
        let url = "https://api.github.com/user/repos"
        let params = ["access_token": OAuthToken, "sort": "pushed"]
        
        Alamofire.request(.GET, url, parameters: params).responseJSON { response in
            if let data = response.result.value {
                var repos = [Repo]()
                for (_, r) in JSON(data) {
                    repos.append(Repo(json: r))
                }
                completion(repos: repos)
            }
        }
    }
    
    func listStarred(completion: (repos: [Repo]) -> Void) {
        let url = "https://api.github.com/user/starred"
        let params = ["access_token": OAuthToken]
        
        Alamofire.request(.GET, url, parameters: params).responseJSON { response in
            if let data = response.result.value {
                var repos = [Repo]()
                for (_, r) in JSON(data) {
                    repos.append(Repo(json: r))
                }
                completion(repos: repos)
            }
        }
    }
    
    func logout() {
        GitHubAPIManager.isLogin = false
        Global.Database.setValue("", forKey: "github-oauthtoken")
        Global.Database.setValue("", forKey: "github-user")
    }
    
    private func addObserver(observer: UIViewController) {
        // ----------------- Rewrite Code Later -----------------
        Global.Notifi.addObserver(observer, selector: #selector(GithubAccountTableViewController.githubOAuthCode(_:)), name: GitHubAPIManager.GetOAuthCodeNotifi, object: nil)
        Global.Notifi.addObserver(observer, selector: #selector(GithubAccountTableViewController.githubGetUserInfoCompleted), name: GitHubAPIManager.GetUserInfoDoneNotifi, object: nil)
    }
    
    static func handleURL(url: NSURL) {
        if url.host == "githubLogin" {
            Global.Notifi.postNotificationName(GitHubAPIManager.GetOAuthCodeNotifi, object: nil, userInfo: ["code": url.query!.split("=")[1]])
        }
    }
    
    func star(owner: String, repo: String, success: (() -> Void)? = nil, fail: (() -> Void)? = nil) {
        let url = "https://api.github.com/user/starred/\(owner)/\(repo)"
        let headers = ["Authorization": "token " + OAuthToken]
        
        Alamofire.request(.PUT, url, headers: headers).response { result in
            let response = result.1
            if let code = response?.statusCode {
                if code == 204 {
                    success?()
                } else {
                    fail?()
                }
            }
        }
    }
    
    func follow(user: String, success: (() -> Void)? = nil, fail: (() -> Void)? = nil) {
        let url = "https://api.github.com/user/following/\(user)"
        let headers = ["Authorization": "token " + OAuthToken]
        
        Alamofire.request(.PUT, url, headers: headers).response { result in
            let response = result.1
            if let code = response?.statusCode {
                if code == 204 {
                    success?()
                } else {
                    fail?()
                }
            }
        }
    }
    
    func listGists(completion: ((gists: [Gist]) -> Void)? = nil) {
        let url = "https://api.github.com/gists/public"
        
        Alamofire.request(.GET, url).responseJSON { response in
            if let data = response.result.value {
                var gists = [Gist]()
                for (_, r) in JSON(data) {
                    if r["owner"] != nil && r["files"] != nil {
                        gists.append(Gist(json: r))
                    }
                }
                completion?(gists: gists)
            }
        }
    }
}

protocol GithubAPIManagerDelegate {
    // return OAuth code
    func githubOAuthCode(notification: NSNotification)
    // get user info complete
    func githubGetUserInfoCompleted()
}


