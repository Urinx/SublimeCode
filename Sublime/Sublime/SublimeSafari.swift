//
//  SublimeSafari.swift
//  Sublime
//
//  Created by Eular on 4/19/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import UIKit
import WebKit

class SublimeSafari: UIViewController, WKNavigationDelegate {
    
    let popupMenu = PopupMenu()
    let url: NSURL
    var webView: WKWebView!
    var progressBar: UIProgressView!
    
    init(URL: NSURL) {
        url = URL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constant.CapeCod
        self.automaticallyAdjustsScrollViewInsets = false
        
        // 设置分享菜单
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: popupMenu, action: #selector(popupMenu.showUp))
        popupMenu.controller = self
        popupMenu.itemsToShare = [url]
        
        webView = WKWebView()
        webView.frame = CGRectMake(0, 0, view.width, view.height - Constant.NavigationBarOffset)
        webView.backgroundColor = UIColor.clearColor()
        webView.scrollView.backgroundColor = UIColor.clearColor()
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        if let host = url.host {
            let hostLB = UILabel()
            hostLB.frame = CGRectMake(0, 10, view.width, 20)
            hostLB.text = "网页由 \(host) 提供"
            hostLB.font = hostLB.font.fontWithSize(12)
            hostLB.textAlignment = .Center
            hostLB.textColor = UIColor.grayColor()
            
            webView.addSubview(hostLB)
            webView.sendSubviewToBack(hostLB)
        }
        
        progressBar = UIProgressView()
        progressBar.frame = CGRectMake(0, 0, view.width, 0)
        progressBar.progress = 0
        progressBar.progressTintColor = UIColor.greenColor()
        progressBar.trackTintColor = UIColor.clearColor()
        webView.addSubview(progressBar)
        
        webView.loadRequest(NSURLRequest(URL: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
    // 准备加载页面
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressBar.setProgress(0.5, animated: true)
    }
    
    // 已开始加载页面
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        progressBar.setProgress(0.9, animated: true)
    }
    
    // 页面已全部加载
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        if title == nil {
            title = webView.title
        }
        progressBar.removeFromSuperview()
    }

}
