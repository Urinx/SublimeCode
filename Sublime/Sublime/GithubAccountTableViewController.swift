//
//  GithubAccountTableViewController.swift
//  Sublime
//
//  Created by Eular on 2/24/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import UIKit
import AASquaresLoading

class GithubAccountTableViewController: UITableViewController, GithubAPIManagerDelegate {
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var idLB: UILabel!
    @IBOutlet weak var companyLB: UILabel!
    @IBOutlet weak var locationLB: UILabel!
    @IBOutlet weak var emailLB: UILabel!
    @IBOutlet weak var blogLB: UILabel!
    @IBOutlet weak var usageLB: UILabel!
    @IBOutlet weak var followerLB: UILabel!
    @IBOutlet weak var repoLB: UILabel!
    @IBOutlet weak var followingLB: UILabel!
    
    let github = GitHubAPIManager()
    var loadingSquare: AASquaresLoading?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constant.CapeCod
        title = "Github"
        
        if GitHubAPIManager.isLogin {
            updateUserInfo()
        } else {
            loadingSquare = AASquaresLoading(target: self.view, size: 40)
            loadingSquare?.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
            loadingSquare?.color = UIColor.whiteColor()
            
            showLoginView()
        }
        
        navigationController?.navigationBar.translucent = false
    }
    
    func updateUserInfo() {
        nameLB.text = github.user["name"].string
        idLB.text = github.user["login"].string
        companyLB.text = github.user["company"].string
        locationLB.text = github.user["location"].string
        emailLB.text = github.user["email"].string
        blogLB.text = github.user["blog"].string
        
        if let avatar_url = github.user["avatar_url"].string {
            avatarView.imageFromUrl(avatar_url)
        }
        
        followerLB.text = "\(github.user["followers"].int ?? 0)"
        repoLB.text = "\(github.user["public_repos"].int ?? 0)"
        followingLB.text = "\(github.user["following"].int ?? 0)"
        
        let used = (github.user["disk_usage"].double ?? 0) * 1024
        let total = (github.user["plan"]["space"].double ?? 0) * 1024
        usageLB.text = "\(used.GB.afterPoint(2))GB / \(total.GB.afterPoint(2))GB"
    }
    
    func showLoginView() {
        tableView.separatorColor = UIColor.blackColor().colorWithAlphaComponent(0)
        
        let loginView = UIView()
        loginView.tag = 1008611
        loginView.frame = view.frame
        loginView.y = view.height
        loginView.backgroundColor = Constant.CapeCod
        let img = UIImageView()
        let imgH: CGFloat = 290
        let imgW: CGFloat = 300
        let imgOffsetH: CGFloat = (view.height - imgH - Constant.NavigationBarOffset) / 2
        let imgOffsetW: CGFloat = (view.width - imgW) / 2
        img.frame = CGRectMake(imgOffsetW, imgOffsetH, imgW, imgH)
        img.image = UIImage(named: "github_login")
        let btn = UIButton()
        btn.frame = CGRectMake(imgOffsetW + 105, imgOffsetH + 165, 100, 50)
        //btn.layer.borderWidth = 1
        btn.addTarget(self, action: #selector(self.githubLogin), forControlEvents: .TouchUpInside)
        loginView.addSubview(img)
        loginView.addSubview(btn)
        view.addSubview(loginView)
        
        UIView.animateWithDuration(1) {
            loginView.y = 0
        }
    }
    
    func githubLogin() {
        github.delegate = self
        github.OAuth2()
    }
    
    func githubOAuthCode(notification: NSNotification) {
        github.handleOAuthCode(notification)
        loadingSquare?.start()
    }
    
    func githubGetUserInfoCompleted() {
        loadingSquare?.stop()
        updateUserInfo()
        tableView.reloadData()
        tableView.separatorColor = Constant.CapeCod
        
        if let loginView = view.viewWithTag(1008611) {
            UIView.animateWithDuration(1, animations: {
                loginView.alpha = 0
            }) { (_) -> Void in
                loginView.removeFromSuperview()
            }
        }
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return GitHubAPIManager.isLogin ? 3 : 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 6 : 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 2 {
            github.logout()
            showLoginView()
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constant.FilesTableSectionHight
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = Constant.CapeCod
        return headerView
    }

}
