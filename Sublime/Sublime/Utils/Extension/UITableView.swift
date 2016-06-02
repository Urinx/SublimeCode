//
//  UITableView.swift
//  Sublime
//
//  Created by Eular on 4/20/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation

// MARK: - UITableView
extension UITableView {
    
    func scrollToBottomAnimated(animated: Bool) {
        let row = numberOfRowsInSection(0) - 1
        if row >= 0 {
            let indexPath = NSIndexPath(forRow: row, inSection: 0)
            scrollToIndexPath(indexPath, animated: animated)
        }
    }
    
    func scrollToIndexPath(indexPath: NSIndexPath, animated: Bool) {
        scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
    }
    
}