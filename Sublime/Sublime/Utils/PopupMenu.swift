//
//  PopupMenu.swift
//  Sublime
//
//  Created by Eular on 5/3/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation

protocol PopupMenuDelegate {
    func tapOnPopupMenuItem(itemIndex i: Int)
}

class PopupMenu {
    var delegate: PopupMenuDelegate?
    var controller: UIViewController?
    var itemsToShare: [AnyObject] = []
    var items: [[String:String]] = []
    
    private var menu: UIView?
    private var mask: UIView?
    
    private let defaultItem = ["title":"更多", "image":"Share_more_icon"]
    private let itemNumInRow: Int
    private let menuColor = Constant.PopupMenuColor
    private let maskColor = Constant.BlackMaskViewColor
    
    init(itemNumInRow: Int = 4) {
        self.itemNumInRow = itemNumInRow
        self.items = [
            ["title":"QQ", "image":"Share_qq_icon"],
            ["title":"新浪微博", "image":"Share_sina_icon"],
            ["title":"微信", "image":"Share_wechat_session_icon"],
            ["title":"朋友圈", "image":"Share_wechat_timeline_icon"],
            ["title":"Facebook", "image":"Share_facebook_icon"],
            ["title":"Line", "image":"Share_line_icon"],
            ["title":"Instagram", "image":"Share_instagram"],
            ["title":"Twitter", "image":"Share_twitter_icon"],
            ["title":"QQ空间", "image":"Share_qzone_icon"],
            ["title":"Pinterest", "image":"Share_pinterest_icon"],
            ["title":"豆瓣", "image":"Share_douban_icon"]
        ]
    }
    
    @objc func showUp() {
        let window = controller?.view.window
        let width = window?.width ?? 0
        let hight = window?.height ?? 0
        
        var menuItems = items
        menuItems << defaultItem
        
        let rowNum = (menuItems.count - 1) / itemNumInRow + 1
        let itemWidth = width / itemNumInRow
        let rowHight = itemWidth
        let menuHight = rowHight * rowNum
        
        let popupMenu = UIView()
        popupMenu.backgroundColor = menuColor
        popupMenu.frame = CGRectMake(0, hight, width, menuHight)
        
        // Insert item label into menu
        for (i, item) in menuItems.enumerate() {
            let btn = UIButton()
            btn.frame = CGRectMake(itemWidth * (i % itemNumInRow), rowHight * (i / itemNumInRow), itemWidth, rowHight)
            btn.setImage(UIImage(named: item["image"] ?? defaultItem["image"]!), forState: .Normal)
            btn.tag = i
            btn.addTarget(self, action: #selector(tapOnPopupMenuItem(_:)), forControlEvents: .TouchUpInside)
            popupMenu.addSubview(btn)
        }
        
        // Black the below view
        let blackMaskView = UIView(frame: window?.frame ?? CGRectZero)
        blackMaskView.backgroundColor = maskColor
        blackMaskView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnBlackMaskView)))
        
        window?.addSubview(blackMaskView)
        window?.addSubview(popupMenu)
        
        self.menu = popupMenu
        self.mask = blackMaskView
        
        UIView.animateWithDuration(0.3) { () -> Void in
            popupMenu.y -= menuHight
        }
    }
    
    @objc private func tapOnBlackMaskView() {
        dismissPopupMenu()
    }
    
    @objc private func tapOnPopupMenuItem(btn: UIButton) {
        dismissPopupMenu {
            if btn.tag == self.items.count {
                let activityVC = UIActivityViewController(activityItems: self.itemsToShare, applicationActivities: nil)
                self.controller?.presentViewController(activityVC, animated: true, completion: nil)
            } else {
                self.delegate?.tapOnPopupMenuItem(itemIndex: btn.tag)
            }
        }
    }
    
    private func dismissPopupMenu(completion: (() -> Void)? = nil) {
        if let popupMenu = self.menu, blackMaskView = self.mask {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                popupMenu.y += popupMenu.height
            }, completion: { (_) -> Void in
                popupMenu.removeFromSuperview()
                blackMaskView.removeFromSuperview()
                completion?()
            })
        }
    }
}
