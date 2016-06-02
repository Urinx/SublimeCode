//
//  MessageListViewController.swift
//  Sublime
//
//  Created by Eular on 3/21/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import UIKit

class MessageListViewController: RCConversationListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Messages"
        showConnectingStatusOnNavigatorBar = true
        emptyConversationView.atCenter()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(self.newChat))
        
        //设置需要显示哪些类型的会话
        self.setDisplayConversationTypes([
            RCConversationType.ConversationType_PRIVATE.rawValue,
            RCConversationType.ConversationType_DISCUSSION.rawValue,
            RCConversationType.ConversationType_CHATROOM.rawValue,
            RCConversationType.ConversationType_GROUP.rawValue,
            RCConversationType.ConversationType_APPSERVICE.rawValue,
            RCConversationType.ConversationType_SYSTEM.rawValue])
        //设置需要将哪些类型的会话在会话列表中聚合显示
        self.setCollectionConversationType([
            RCConversationType.ConversationType_DISCUSSION.rawValue,
            RCConversationType.ConversationType_GROUP.rawValue])
        
        if RCIM.sharedRCIM().getConnectionStatus() == .ConnectionStatus_Unconnected {
            RCIM.sharedRCIM().getTokenAndLogin()
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        Global.UnreadMessageCount = 0
        tabBarController?.tabBar.hideRedBadgeOnItem(2)
    }
    
    override func onSelectedTableRow(conversationModelType: RCConversationModelType, conversationModel model: RCConversationModel!, atIndexPath indexPath: NSIndexPath!) {
        let chat = RCChatViewController(conversationType: model.conversationType, targetId: model.targetId)
        chat.title = model.conversationTitle
        navigationController?.pushViewController(chat, animated: true)
    }
    
    override func didTapCellPortrait(model: RCConversationModel!) {
        let contactInfoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(Constant.ContactInfoStoryboardID) as! ContactInfoViewController
        contactInfoVC.id = model.targetId == Constant.RongCloudRobotID ? "" : model.targetId
        navigationController?.pushViewController(contactInfoVC, animated: true)
    }
    
    func newChat() {
        let contactVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(Constant.ContactTableStoryboardID) as! ContactTableViewController
        navigationController?.pushViewController(contactVC, animated: true)
    }
}

