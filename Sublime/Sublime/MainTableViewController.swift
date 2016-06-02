//
//  FilesTableViewController.swift
//  Sublime
//
//  Created by Eular on 2/12/16.
//  Copyright © 2016 Eular. All rights reserved.
//

class MainTableViewController: FolderTableViewController {
        
    var gitList = [File(path: "Stars"), File(path: "Repositories")]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sublime"
        mainViewFlag = 0
        
        Global.Notifi.addObserver(self, selector: #selector(self.hasUnreadMessages), name: Constant.RongCloudUnreadMessageNotifi, object: nil)
    }
    
    deinit {
        Global.Notifi.removeObserver(self)
    }
    
    func hasUnreadMessages() {
        dispatch_async(dispatch_get_main_queue()) {
            self.tabBarController?.tabBar.showRedBadgeOnItem(1, totalItemNums: 3)
        }
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0: return gitList.count
            case 1: return fileList.count
            default: return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        if indexPath.section == 0 {
            let f = gitList[indexPath.row]
            setFileTableCell(cell, name: f.name, imgname: f.name, isDir: true)
        } else {
            let f = fileList[indexPath.row]
            setFileTableCell(cell, name: f.name, imgname: f.img, isDir: f.isDir)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let secTitle = ["   Github", "   Local"]
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
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constant.FilesTableSectionHight
    }

}
