//
//  ReposTableViewController.swift
//  Sublime
//
//  Created by Eular on 2/29/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import UIKit
import AASquaresLoading

class ReposTableViewController: UITableViewController {
    @IBOutlet weak var starLB: UILabel!
    @IBOutlet weak var forkLB: UILabel!
    @IBOutlet weak var watcherLB: UILabel!
    @IBOutlet weak var commitTimeLB: UILabel!
    @IBOutlet weak var descriptionLB: UILabel!
    @IBOutlet weak var sizeLB: UILabel!
    @IBOutlet weak var webView: UIWebView!
    
    var repo: Repo!
    var loadingSquare: AASquaresLoading!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = repo.name
        
        let downloadBtn = UIBarButtonItem(image: UIImage(named: "repo_download"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.downloadRepo))
        navigationItem.rightBarButtonItem = downloadBtn
        
        watcherLB.text = "\(repo.watchers)"
        starLB.text = "\(repo.stargazers)"
        forkLB.text = "\(repo.forks)"
        commitTimeLB.text = "Created at: \(repo.created_at)"
        descriptionLB.text = repo.description
        sizeLB.text = "[\((repo.size * 1024).MB.afterPoint(2))M]"
        
        webView.backgroundColor = UIColor.clearColor()
        webView.opaque = false
        webView.scalesPageToFit = true
        webView.scrollView.showsHorizontalScrollIndicator = false

        repo.fatchReadmeFile("html") { (str) -> Void in
            self.webView.loadHTMLString(str, baseURL: nil)
        }
        
        //webView.loadRequest(NSURLRequest(URL: NSURL(string: "https://github.com/\(repo.ownerLogin)/\(repo.name)/blob/master/README.md")!))
        
        loadingSquare = AASquaresLoading(target: self.view, size: 40)
        loadingSquare.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        loadingSquare.color = UIColor.whiteColor()
    }
    
    func downloadRepo() {
        tableView.scrollEnabled = false
        let barItem = UIBarButtonItem(title: "0 %", style: .Plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = barItem
        
        loadingSquare.start()
        repo.download({ (bytesRead, totalBytesRead, totalBytesExpectedToRead) -> Void in
            let read = CGFloat(totalBytesRead)
            let total = CGFloat(totalBytesExpectedToRead)
            let r = Int(read * 100.0 / total)
            dispatch_async(dispatch_get_main_queue()) {
                // 导航栏右边按钮显示下载进度
                let barItem = UIBarButtonItem(title: "\(r) %", style: .Plain, target: nil, action: nil)
                self.navigationItem.rightBarButtonItem = barItem
            }
        }, completion: {
            self.loadingSquare.stop()
            self.tableView.scrollEnabled = true
            self.navigationItem.rightBarButtonItem = nil
        }) {
            self.loadingSquare.stop()
            self.tableView.scrollEnabled = true
            let downloadBtn = UIBarButtonItem(image: UIImage(named: "repo_download"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.downloadRepo))
            self.navigationItem.rightBarButtonItem = downloadBtn
            self.view.Toast(message: "Download Fail", hasNavigationBar: true)
        }
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [3,1,1][section]
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let secTitle = ["   \(repo.ownerLogin) / \(repo.name)", "   master", "   README.md"]
        let title = UILabel(frame: CGRectMake(0, 0, view.width, Constant.FilesTableSectionHight))
        title.backgroundColor = Constant.CapeCod
        title.text = secTitle[section]
        title.textColor = UIColor.whiteColor()
        title.font = title.font.fontWithSize(12)
        title.textAlignment = .Natural
        let headerView = UIView()
        headerView.addSubview(title)
        return headerView
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.section == 2 ? view.height - Constant.NavigationBarOffset : 44
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constant.FilesTableSectionHight
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
