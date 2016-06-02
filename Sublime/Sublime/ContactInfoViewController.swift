//
//  ContactInfoViewController.swift
//  Sublime
//
//  Created by Eular on 4/1/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import UIKit

class ContactInfoViewController: UIViewController, PopupMenuDelegate {
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var githubLabel: UILabel!
    @IBOutlet weak var QRImageView: UIImageView!
    
    let popupMenu = PopupMenu()
    
    var id = ""
    var nameCardImage: UIImage {
        get {
            return view.snapshot(CGRectMake(0, Constant.NavigationBarOffset, view.width, view.height - 100))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if id.isEmpty {
            githubLabel.text = "github: null"
            headImageView.image = UIImage(named: "user_robot")
            nameLabel.text = Constant.RongCloudRobotName
            QRImageView.image = QRCode().makeWithColor(Constant.AppGithubLink)
        } else {
            githubLabel.text = "github: \(id)"
            
            RCIM.sharedRCIM().getInfo(id) { (name, portrait) in
                dispatch_async(dispatch_get_main_queue()) {
                    self.headImageView.imageFromUrl(portrait)
                    self.nameLabel.text = name
                }
            }
            
            QRImageView.image = QRCode().makeWithColor("https://github.com/\(id)")
        }
        
        // set shadow
        QRImageView.layer.shadowOffset = CGSizeMake(0, 2)
        QRImageView.layer.shadowRadius = 2
        QRImageView.layer.shadowColor = UIColor.blackColor().CGColor
        QRImageView.layer.shadowOpacity = 0.5
        
        // recognize qrcode
        QRImageView.recognizeQRCodeEnabled = true
        
        // 设置分享菜单
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: popupMenu, action: #selector(popupMenu.showUp))
        popupMenu.controller = self
        popupMenu.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        popupMenu.itemsToShare = [nameCardImage]
    }
    
    func tapOnPopupMenuItem(itemIndex i: Int) {
        switch i {
        case 2:
            WXShareImage(nameCardImage)
        case 3:
            WXShareImage(nameCardImage, isTimeline: true)
        default:
            return
        }
    }

}
