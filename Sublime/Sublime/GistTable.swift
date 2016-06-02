//
//  GistTable.swift
//  Sublime
//
//  Created by Eular on 5/9/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation

class GistTable: UITableViewController {
    
    let github = GitHubAPIManager()
    let refreshController = UIRefreshControl()
    var gistData: [Gist] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Gist"
        view.backgroundColor = Constant.CapeCod
        tableView.separatorColor = UIColor.clearColor()
        tableView.estimatedRowHeight = 216
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsSelection = false
        
        makeTableHeader()
        
        // add pull-to-refresh
        refreshController.addTarget(self, action: #selector(self.refreshData), forControlEvents: UIControlEvents.ValueChanged)
        refreshController.tintColor = UIColor.whiteColor()
        tableView.addSubview(refreshController)
        
        // right bar item
        let downloadBtn = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: nil)
        navigationItem.rightBarButtonItem = downloadBtn
        
        refreshData()
    }
    
    func makeTableHeader() {
        let headerView = UIView()
        let bgImgView = UIImageView()
        let headImgView = UIImageView()
        let nameLabel = UILabel()
        
        let headerWidth = self.view.bounds.size.width
        let headerHeight = headerWidth - 30
        let imgOffset = CGFloat(-60)
        let headImgWidth = CGFloat(70)
        let labelWidth = headerWidth - headImgWidth - 25
        let labelHeight = CGFloat(30)
        
        headerView.frame = CGRectMake(0, 0, headerWidth, headerHeight)
        headerView.backgroundColor = UIColor.whiteColor()
        bgImgView.frame = CGRectMake(0, imgOffset, headerWidth + 5, headerWidth)
        bgImgView.image = UIImage(named: "gist_bg")
        bgImgView.contentMode = .ScaleAspectFill
        headerView.addSubview(bgImgView)
        
        headImgView.frame = CGRectMake(headerWidth - headImgWidth - 10, headerHeight - headImgWidth - 10, headImgWidth, headImgWidth)
        headImgView.layer.borderWidth = 1
        headImgView.layer.borderColor = UIColor.whiteColor().CGColor
        if let avatar_url = github.user["avatar_url"].string {
            headImgView.imageFromUrl(avatar_url)
        }
        headerView.addSubview(headImgView)
        
        nameLabel.frame = CGRectMake(0, headerHeight - labelHeight - 35, labelWidth, labelHeight)
        nameLabel.text = github.user["name"].string
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.textAlignment = .Right
        nameLabel.font = UIFont(name: nameLabel.font.fontName, size: 19)
        headerView.addSubview(nameLabel)
        
        tableView.tableHeaderView = headerView
    }
    
    func refreshData() {
        github.listGists { gists in
            self.gistData = gists
            self.tableView.reloadData()
            self.refreshController.endRefreshing()
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gistData.count == 0 ? 1:gistData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("gistCell", forIndexPath: indexPath)
        if gistData.count != 0 {
            let gist = gistData[indexPath.row]
            
            let header = cell.viewWithTag(6) as! UIImageView
            let title = cell.viewWithTag(3) as! UILabel
            let description = cell.viewWithTag(4) as! UILabel
            let comment = cell.viewWithTag(7) as! UILabel
            let time = cell.viewWithTag(5) as! UILabel
            let codeView = cell.viewWithTag(2)!
            let codeText = CodeEngine().textView
            codeView.addSubview(codeText)
            codeText.autoLayout(top: 0, left: 0, bottom: 0, right: 0)
            
            header.imageFromUrl(gist.avatar_url)
            title.text = "\(gist.ownerLogin) / \(gist.files[0]["filename"]!)"
            description.text = gist.description
            comment.text = "\(gist.comments)"
            
            let now = NSDate()
            let diff = now - gist.created_at.toGMTDate("yyyy-MM-dd HH:mm:ss")!
            time.text = "\(diff.minute) minutes ago"
            
            gist.getRawData { content in
                codeText.text = content
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
