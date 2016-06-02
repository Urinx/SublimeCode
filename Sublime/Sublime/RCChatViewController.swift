//
//  ChatViewController.swift
//  Sublime
//
//  Created by Eular on 4/1/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import UIKit

class RCChatViewController: RCConversationViewController {
    override func didTapCellPortrait(userId: String!) {
        let contactInfoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(Constant.ContactInfoStoryboardID) as! ContactInfoViewController
        contactInfoVC.id = userId == Constant.RongCloudRobotID ? "" : userId
        navigationController?.pushViewController(contactInfoVC, animated: true)
    }
}