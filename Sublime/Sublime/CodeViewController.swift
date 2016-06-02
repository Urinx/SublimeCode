//
//  FileViewController.swift
//  Sublime
//
//  Created by Eular on 2/14/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import UIKit
import CYRTextView

class CodeViewController: UIViewController, UIScrollViewDelegate, PopupMenuDelegate {
    
    var curFile: Code?
    var codeShareImage: UIImage?
    var codeCardView: UIView?
    var blackMaskView: UIView?
    var hideStatusBar = false
    
    let codeText = CodeEngine().textView
    let popupMenu = PopupMenu()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = curFile!.name
        view.backgroundColor = Constant.CodeBackgroudColor
        self.automaticallyAdjustsScrollViewInsets = false
        
        let bottom = Constant.NavigationBarOffset
        codeText.frame = view.frame
        codeText.contentInset.bottom = bottom
        codeText.scrollIndicatorInsets.bottom = bottom
        
        codeText.text = curFile!.read()+"\n"
        codeText.setLineBreakMode(.ByCharWrapping)
        
        view.addSubview(codeText)

        
        
        // 设置分享菜单
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: popupMenu, action: #selector(popupMenu.showUp))
        popupMenu.controller = self
        popupMenu.delegate = self
        popupMenu.itemsToShare = [curFile!.url]
        
        // Add a selected menu item
        let shareCodeItem = UIMenuItem(title: NSLocalizedString("SHARE_IN_PICTURE", comment: "Share in picture"), action: #selector(self.shareCodeInPicture))
        UIMenuController.sharedMenuController().menuItems = [shareCodeItem]
        
        // 保持屏幕常亮
        UIApplication.sharedApplication().idleTimerDisabled = true
        
        // 下滑显示导航栏+状态栏，上滑收起导航栏+状态栏
        (codeText as UIScrollView).delegate = self
        
        // 点击屏幕显示或隐藏导航栏+状态栏
        if Config.FullScreenCodeReadingMode {
            codeText.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hideOrShowStatusBar)))
        }
    }
    
    // 下滑显示导航栏+状态栏，上滑收起导航栏+状态栏
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if Config.FullScreenCodeReadingMode {
            if velocity.y < 0 { hideStatusBar = false }
            else if velocity.y > 0 { hideStatusBar = true }
            
            let bottom = hideStatusBar ? 0 : Constant.NavigationBarOffset
            codeText.contentInset.bottom = bottom
            codeText.scrollIndicatorInsets.bottom = bottom
            
            navigationController?.setNavigationBarHidden(hideStatusBar, animated: true)
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    func hideOrShowStatusBar() {
        hideStatusBar = !hideStatusBar

        let bottom = hideStatusBar ? 0 : Constant.NavigationBarOffset
        codeText.contentInset.bottom = bottom
        codeText.scrollIndicatorInsets.bottom = bottom
        
        navigationController?.setNavigationBarHidden(hideStatusBar, animated: true)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return hideStatusBar
    }
    
    override func viewDidDisappear(animated: Bool) {
        // 取消屏幕常亮
        UIApplication.sharedApplication().idleTimerDisabled = false
        // 记录位置
        curFile?.lastReadPosition = Double(codeText.contentOffset.y)
    }
    
    // Generate a picture to share code
    func shareCodeInPicture() {
        let rects = codeText.selectionRectsForRange(codeText.selectedTextRange!)
        codeText.selectable = false
        codeText.setLineBreakMode(.ByCharWrapping)
        
        let minR = rects.minElement { (a, b) -> Bool in
            return a.rect.origin.y < b.rect.origin.y
        }
        let maxR = rects.maxElement { (a, b) -> Bool in
            return a.rect.origin.y < b.rect.origin.y
        }
        let frame = CGRectMake(0, minR!.rect.origin.y, codeText.width, maxR!.rect.origin.y - minR!.rect.origin.y + 16)
        
        makeShareCodePicture(codeText.snapshot(frame))
        
        codeText.selectable = true
    }
    
    func makeShareCodePicture(codeImg: UIImage) -> UIImage {
        
        let w = codeImg.size.width
        let h = codeImg.size.height
        let sideMargin: CGFloat = 15
        let topMargin: CGFloat = 100
        let buttomMargin: CGFloat = 60
        
        let headImg = UIImageView(frame: CGRectMake(sideMargin, 20, 60, 60))
        headImg.image = UIImage(named: "setting_sublime")
        
        let nameLB = UILabel()
        nameLB.frame = CGRectMake(sideMargin + headImg.width + 10, 25, w - headImg.width - 10, 15)
        nameLB.text = "Sublime"
        nameLB.textColor = UIColor.grayColor()
        nameLB.font = nameLB.font.fontWithSize(14)
        
        if GitHubAPIManager.isLogin {
            nameLB.text = GitHubAPIManager.sharedInstance.user["name"].string
            if let avatar_url = GitHubAPIManager.sharedInstance.user["avatar_url"].string {
                headImg.imageFromUrl(avatar_url)
                headImg.layer.cornerRadius = headImg.width / 2
                headImg.clipsToBounds = true
                headImg.layer.borderWidth = 1
                headImg.layer.borderColor = UIColor.whiteColor().CGColor
            }
        }
        
        let textInput = UITextView()
        textInput.frame = CGRectMake(sideMargin + headImg.width + 5, nameLB.y + nameLB.height, w - headImg.width - 5, 50)
        textInput.text = "What’s amazing, this code save me from hair pulling!"
        textInput.textColor = UIColor.whiteColor()
        textInput.textContainer.maximumNumberOfLines = 2
        textInput.backgroundColor = UIColor.clearColor()
        textInput.font = textInput.font?.fontWithSize(16)
        textInput.setLineBreakMode(.ByWordWrapping)
        textInput.tag = 211
        
        let doneBtn = UIButton()
        doneBtn.frame = CGRectMake(2 * sideMargin + w - 50, 10, 40, 30)
        doneBtn.setImage(UIImage(named: "code_share_btn"), forState: .Normal)
        doneBtn.addTarget(self, action: #selector(self._tapOnShareCodeSendButton), forControlEvents: .TouchUpInside)
        doneBtn.tag = 212
        
        let codeImgView = UIImageView(frame: CGRectMake(sideMargin, topMargin, w, h))
        codeImgView.image = codeImg
        // set shadow
        codeImgView.layer.shadowOffset = CGSizeMake(0, 2)
        codeImgView.layer.shadowRadius = 2
        codeImgView.layer.shadowColor = UIColor.blackColor().CGColor
        codeImgView.layer.shadowOpacity = 0.5
        
        let fileLB = UILabel()
        fileLB.frame = CGRectMake(sideMargin, topMargin + h + 20, w, 20)
        fileLB.text = "—— \(curFile!.name)"
        fileLB.textColor = UIColor.grayColor()
        fileLB.textAlignment = .Right
        fileLB.font = fileLB.font.fontWithSize(14)
        
        let codeCard = UIView()
        codeCard.backgroundColor = Constant.CodeLineNumberBackgroudColor
        codeCard.frame = CGRectMake(0, 0, w + 2 * sideMargin, topMargin + h + buttomMargin)
        // set shadow
        codeCard.layer.shadowOffset = CGSizeMake(0, 2)
        codeCard.layer.shadowRadius = 2
        codeCard.layer.shadowColor = UIColor.blackColor().CGColor
        codeCard.layer.shadowOpacity = 0.5
        codeCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self._tapOnShareCodeBlackMaskView)))
        
        let blackView = UIView()
        blackView.frame = view.window!.frame
        blackView.backgroundColor = RGB(0, 0, 0, alpha: 0.8)
        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self._tapOnShareCodeBlackMaskView)))
        
        codeCard.addSubview(headImg)
        codeCard.addSubview(nameLB)
        codeCard.addSubview(textInput)
        codeCard.addSubview(doneBtn)
        codeCard.addSubview(codeImgView)
        codeCard.addSubview(fileLB)
        
        codeCard.transform = CGAffineTransformMakeScale(0, 0)
        
        view.window?.addSubview(blackView)
        view.window?.addSubview(codeCard)
        codeCard.atCenter()
        
        UIView.animateWithDuration(0.5) { 
            codeCard.transform = CGAffineTransformMakeScale(0.85, 0.85)
        }
        
        blackMaskView = blackView
        codeCardView = codeCard
        
        return codeImg
    }
    
    func _tapOnShareCodeBlackMaskView() {
        _removeShareCode(completion: nil)
    }
    
    func _removeShareCode(completion completion: ((codeCard: UIView) -> Void)?) {
        if let blackView = blackMaskView, let codeCard = codeCardView {
            let input = codeCard.viewWithTag(211) as! UITextView
            if !input.resignFirstResponder() {
                UIView.animateWithDuration(0.5, animations: {
                    codeCard.y += self.view.height
                    }, completion: { (_) in
                        codeCard.removeFromSuperview()
                        blackView.removeFromSuperview()
                        completion?(codeCard: codeCard)
                })
            }
        }
    }
    
    func _tapOnShareCodeSendButton() {
        _removeShareCode { (codeCard) in
            codeCard.transform = CGAffineTransformMakeScale(1, 1)
            codeCard.viewWithTag(212)?.removeFromSuperview()
            self.codeShareImage = codeCard.snapshot()
            self.popupMenu.showUp()
        }
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == #selector(self.shareCodeInPicture) {
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    // 旋转屏幕
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        let bottom = Constant.NavigationBarOffset
        codeText.frame = CGRectMake(0, 0, view.width, view.height + bottom)
        codeText.contentInset.bottom = bottom
        codeText.scrollIndicatorInsets.bottom = bottom
    }
    
    func tapOnPopupMenuItem(itemIndex i: Int) {
        switch i {
        case 2: // 微信
            if let codeImg = codeShareImage {
                codeShareImage = nil
                WXShareImage(codeImg)
            } else {
                getGhostbinUrl(curFile!.codeLang, text: curFile!.read(), target: self) {
                    url in
                    self.WXShareLink(self.curFile!.name, desc: "给你分享一个神奇的代码", img: "file_code_share", link: url)
                }
            }
        case 3: // 朋友圈
            if let codeImg = codeShareImage {
                codeShareImage = nil
                WXShareImage(codeImg, isTimeline: true)
            } else {
                getGhostbinUrl(curFile!.codeLang, text: curFile!.read(), target: self) {
                    url in
                    self.WXShareLink("这是一份神奇的代码: \(self.curFile!.name)", desc: "", img: "file_code_share", link: url, isTimeline: true)
                }
            }
        default: return
        }
    }
}
