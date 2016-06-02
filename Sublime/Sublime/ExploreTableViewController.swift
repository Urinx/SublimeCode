//
//  ExploreTableViewController.swift
//  Sublime
//
//  Created by Eular on 4/6/16.
//  Copyright © 2016 Eular. All rights reserved.
//

class ExploreTableViewController: UITableViewController {
    @IBOutlet weak var msgCountLB: UILabel!

    let secTitle = ["   Explore", "   Function"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        msgCountLB.hidden = true
        if Global.UnreadMessageCount != 0 {
            msgCountLB.text = "\(Global.UnreadMessageCount)"
            msgCountLB.hidden = false
        }
        tabBarController?.tabBar.hideRedBadgeOnItem(1)
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // Functions
        switch (indexPath.section, indexPath.row) {
//        case (0,0):
//            let gvc = GistTable()
//            gvc.hidesBottomBarWhenPushed = true
//            navigationController?.pushViewController(gvc, animated: true)
        case (1,1):
            let svc = SSHServerListTableViewController()
            svc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(svc, animated: true)
        case (1,2):
            if GitHubAPIManager.isLogin {
                let messageList = MessageListViewController()
                messageList.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(messageList, animated: true)
            } else {
                let alert = UIAlertController(title: "(*´ڡ`●)", message: "Ops! This function requires that Github account is logined.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
            }
        case (1,3):
            let rss = RSSListTableViewController()
            rss.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(rss, animated: true)
        case (1,4):
            let qrReader = QRCodeReaderViewController()
            qrReader.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(qrReader, animated: true)
        default: return
        }
    }

}
