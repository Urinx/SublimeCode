//
//  AppInfoViewController.swift
//  Sublime
//
//  Created by Eular on 2/24/16.
//  Copyright © 2016 Eular. All rights reserved.
//

class AppInfoViewController: UIViewController {
    
    let popupMenu = PopupMenu()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sublime"
        view.backgroundColor = Constant.CapeCod
        
        if let logo = UIView.loadFromNibNamed("LogoView") {
            logo.frame = view.frame
            logo.height -= Constant.NavigationBarOffset
            view.addSubview(logo)
        }
        
        let version = UILabel()
        view.addSubview(version)
        version.text = "Version 1.0"
        version.font = version.font.fontWithSize(13)
        version.width = 100
        version.height = 20
        version.autoLayout(left: 12, bottom: -9)
        version.textColor = UIColor.lightGrayColor()
        
        let btn = UIButton()
        view.addSubview(btn)
        btn.setTitle("Github", forState: .Normal)
        btn.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.width = 50
        btn.height = 20
        btn.autoLayout(right: -10, bottom: -10)
        btn.addTarget(self, action: #selector(self.goToAppGithub), forControlEvents: .TouchUpInside)
        
        // 设置分享菜单
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: popupMenu, action: #selector(popupMenu.showUp))
        popupMenu.controller = self
        
        // 摇一摇
        UIApplication.sharedApplication().applicationSupportsShakeToEdit = true
        self.becomeFirstResponder()
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate) // 震动
            var mySound: SystemSoundID = 0
            if let url = NSBundle.mainBundle().URLForResource("shake", withExtension: "wav") {
                AudioServicesCreateSystemSoundID(url, &mySound)
                AudioServicesPlaySystemSound(mySound)
            }
            
            let go = GomokuViewController()
            self.presentViewController(go, animated: true, completion: nil)
        }
    }

    func goToAppGithub() {
        let svc = SublimeSafari(URL: NSURL(string: Constant.AppGithubUrl)!)
        svc.title = "Urinx"
        navigationController?.pushViewController(svc, animated: true)
    }
    
}
