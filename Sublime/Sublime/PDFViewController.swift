//
//  PDFViewController.swift
//  Sublime
//
//  Created by Eular on 2/22/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import UIKit
import SJCSimplePDFView

class PDFViewController: UIViewController, PopupMenuDelegate {
    
    var curFile: File!
    var pdfView: SJCSimplePDFView!
    
    let pagenumLabel = UILabel()
    let popupMenu = PopupMenu()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        tabBarController?.tabBar.hidden = true

        view.backgroundColor = Constant.CapeCod
        title = curFile.name
        
        pdfView = SJCSimplePDFView()
        pdfView.frame = CGRectMake(0, 0, view.width, view.height - Constant.NavigationBarOffset)
        pdfView.pageBackgroundColour = UIColor.whiteColor()
        pdfView.PDFFileURL = curFile.url
        pdfView.pageInsets = UIEdgeInsets(top: 2.5, left: 5, bottom: 2.5, right: 5)
        
        let viewMode = Global.Database.integerForKey("pdf-viewmode-\(curFile.path.md5)")
        pdfView.viewMode = [.Continuous, .PageVertical, .PageHorizontal][viewMode]
        let curPage = Global.Database.integerForKey("pdf-curPage-\(curFile.path.md5)")
        pdfView.currentPage = UInt(curPage) // bug: currentPage为'0,1'都显示第一页，'2'显示第三页
        
        view.addSubview(pdfView)
        
        // 设置分享菜单
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: popupMenu, action: #selector(popupMenu.showUp))
        popupMenu.controller = self
        popupMenu.delegate = self
        popupMenu.itemsToShare = [curFile.url]
        popupMenu.items = [
            ["title":"QQ", "image":"Share_qq_icon"],
            ["title":"新浪微博", "image":"Share_sina_icon"],
            ["title":"微信", "image":"Share_wechat_session_icon"],
            ["title":"Facebook", "image":"Share_facebook_icon"],
            ["title":"Line", "image":"Share_line_icon"],
            ["title":"Instagram", "image":"Share_instagram"],
            ["title":"Twitter", "image":"Share_twitter_icon"],
            ["title":"Pinterest", "image":"Share_pinterest_icon"],
            ["title":"PDF Continuous", "image":"pdf_continuous"],
            ["title":"PDF Vertical", "image":"pdf_vertical"],
            ["title":"PDF Horizontal", "image":"pdf_horizontal"],
        ]
        
        pdfView.addObserver(self, forKeyPath: "currentPage", options: NSKeyValueObservingOptions.New, context: nil)
        
        
        pagenumLabel.frame = CGRectMake(0, view.height - 30, 0, 0)
        pagenumLabel.layer.masksToBounds = true
        pagenumLabel.layer.cornerRadius = 3
        pagenumLabel.backgroundColor = RGB(0, 0, 0, alpha: 0.5)
        pagenumLabel.textColor = UIColor.whiteColor()
        pagenumLabel.textAlignment = .Center
        pagenumLabel.alpha = 0
        view.addSubview(pagenumLabel)
    }
    
    func setPagenumLabelText(str: String) {
        pagenumLabel.text = str
        pagenumLabel.sizeToFit()
        pagenumLabel.width += 10
        pagenumLabel.x = (view.width - pagenumLabel.width) / 2
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.pagenumLabel.alpha = 1
        }) { (_) -> Void in
            UIView.animateWithDuration(2) {
                self.pagenumLabel.alpha = 0
            }
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "currentPage" {
            let n = change?[NSKeyValueChangeNewKey]?.integerValue
            setPagenumLabelText("\(n!) / \(pdfView.documentPageCount)")
        }
    }
    
    deinit {
        pdfView.removeObserver(self, forKeyPath: "currentPage")
    }
    
    override func viewWillDisappear(animated: Bool) {
        Global.Database.setInteger(Int(pdfView.currentPage)-1, forKey: "pdf-curPage-\(curFile.path.md5)")
    }
    
    func tapOnPopupMenuItem(itemIndex i: Int) {
        switch i {
        case 2:
            WXShareFile(curFile.name, desc: curFile.name, file: curFile)
        case 8:
            pdfView.viewMode = .Continuous
            Global.Database.setInteger(0, forKey: "pdf-viewmode-\(curFile.path.md5)")
        case 9:
            pdfView.viewMode = .PageVertical
            Global.Database.setInteger(1, forKey: "pdf-viewmode-\(curFile.path.md5)")
        case 10:
            pdfView.viewMode = .PageHorizontal
            Global.Database.setInteger(2, forKey: "pdf-viewmode-\(curFile.path.md5)")
        default: return
        }
    }
}
