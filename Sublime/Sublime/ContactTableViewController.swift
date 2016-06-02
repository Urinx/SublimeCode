//
//  ContactTableViewController.swift
//  Sublime
//
//  Created by Eular on 3/21/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import UIKit

class ContactTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let infoBtn = UIBarButtonItem(image: UIImage(named: "user_info"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.lookUserInfo))
        navigationItem.rightBarButtonItem = infoBtn
        
        let lb = UILabel()
        lb.text = "2 位联系人"
        lb.font = lb.font.fontWithSize(13)
        lb.textAlignment = .Center
        lb.textColor = UIColor.grayColor()
        lb.frame = CGRectMake(0, 0, view.bounds.width, 60)
        tableView.tableFooterView = lb
    }
    
    func lookUserInfo() {
        let contactInfoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(Constant.ContactInfoStoryboardID) as! ContactInfoViewController
        contactInfoVC.id = RCIM.sharedRCIM().currentUserInfo.userId
        navigationController?.pushViewController(contactInfoVC, animated: true)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let chat = RCChatViewController()
        
        switch indexPath.section {
        case 1:
            chat.conversationType = .ConversationType_APPSERVICE
            chat.title = Constant.RongCloudRobotName
            chat.targetId = Constant.RongCloudRobotID
        case 2:
            chat.conversationType = .ConversationType_PRIVATE
            chat.title = Constant.RongCloudAuthorUserName
            chat.targetId = Constant.RongCloudAuthorUserID
        default:
            return
        }
        
        navigationController?.pushViewController(chat, animated: true)
    }
}
