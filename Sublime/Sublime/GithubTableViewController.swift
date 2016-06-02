//
//  GithubTableViewController.swift
//  Sublime
//
//  Created by Eular on 2/14/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import UIKit
import AASquaresLoading
import DGElasticPullToRefresh

class GithubTableViewController: UITableViewController {
    
    let github = GitHubAPIManager()
    var accuntBtn: UIBarButtonItem?
    var tag = 0
    var repoData = [Repo]()
    var loadingSquare: AASquaresLoading!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = ["Stars", "Repositories"][tag]
        view.backgroundColor = Constant.CapeCod
        tableView.separatorColor = Constant.CapeCod
        tableView.tableFooterView = UIView()
        
        accuntBtn = UIBarButtonItem(title: "0", style: .Plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = accuntBtn
        
        if Network.isConnectedToNetwork() {
            if GitHubAPIManager.isLogin {
                loadingSquare = AASquaresLoading(target: self.view, size: 40)
                loadingSquare.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
                loadingSquare.color = UIColor.whiteColor()
                loadingSquare.start()
                tableView.scrollEnabled = false
                
                // Table push Loading Circle
                let loadingView = DGElasticPullToRefreshLoadingViewCircle()
                loadingView.tintColor = Constant.TableLoadingCircleColor
                tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
                    self?.updateDataList()
                    self?.tableView.dg_stopLoading()
                    }, loadingView: loadingView)
                tableView.dg_setPullToRefreshFillColor(Constant.CodeBackgroudColor)
                tableView.dg_setPullToRefreshBackgroundColor(Constant.NavigationBarAndTabBarColor)
                
                updateDataList()
            } else {
                showMsgLabel("Not Login")
            }
        } else {
            showMsgLabel("No Network")
        }
        
    }
    
    deinit {
        tableView.dg_removePullToRefresh()
    }
    
    func showMsgLabel(text: String) {
        let lb = UILabel()
        lb.frame = view.frame
        lb.frame.origin.y -= Constant.NavigationBarOffset
        lb.text = text
        lb.textAlignment = .Center
        lb.textColor = Constant.GithubTableShowMsgLabelTextColor
        lb.shadowColor = Constant.GithubTableShowMsgLabelTextShadowColor
        lb.shadowOffset = CGSizeMake(1, 1)
        view.addSubview(lb)
        tableView.scrollEnabled = false;
    }
    
    func updateDataList() {
        switch tag {
        case 0:
            github.listStarred(handleRepos)
        case 1:
            github.listRepositories(handleRepos)
        default: break
        }
    }
    
    func handleRepos(repos: [Repo]) {
        repoData = repos
        accuntBtn?.title = "\(repos.count)"
        tableView.separatorColor = Constant.CapeCod
        tableView.reloadData()
        loadingSquare.stop()
        tableView.scrollEnabled = true
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repoData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        cell.backgroundColor = Constant.NavigationBarAndTabBarColor
        cell.selectedBackgroundView = UIView(frame: cell.frame)
        cell.selectedBackgroundView?.backgroundColor = Constant.TableCellSelectedColor
        cell.accessoryType = .DisclosureIndicator
        
        cell.textLabel?.text = repoData[indexPath.row].name
        cell.detailTextLabel?.text = repoData[indexPath.row].description
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.textColor = UIColor.grayColor()
        
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let rvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ReposTableView") as! ReposTableViewController
        rvc.repo = repoData[indexPath.row]
        rvc.repo.downloadFolder = Folder(path: github.githubFolder.path.stringByAppendingPathComponent(title!.lower))
        navigationController?.pushViewController(rvc, animated: true)
    }
}
