//
//  UIViewController.swift
//  Sublime
//
//  Created by Eular on 4/20/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation

// MARK: - Loading
extension UIViewController {
    func startLoading(text: String) {
        
        let backView = UIView()
        backView.frame = CGRectMake((view.width - 100) / 2, (view.height - 100) / 2, 100, 100)
        backView.backgroundColor = RGB(0, 0, 0)
        backView.alpha = 0.8
        backView.layer.cornerRadius = 10
        backView.tag = 10086
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRectMake(25, 15, 50, 50)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.hidesWhenStopped = true
        
        let lb = UILabel()
        lb.frame = CGRectMake(0, 72, 100, 20)
        lb.font = lb.font.fontWithSize(12)
        lb.text = text
        lb.textAlignment = .Center
        lb.textColor = UIColor.whiteColor()
        
        backView.addSubview(lb)
        backView.addSubview(activityIndicator)
        
        view.addSubview(backView)
        activityIndicator.startAnimating()
    }
    
    func stopLoading() {
        if let v = view.viewWithTag(10086) {
            v.removeFromSuperview()
        }
    }
}