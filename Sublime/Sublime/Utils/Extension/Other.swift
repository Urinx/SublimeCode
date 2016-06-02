//
//  Other.swift
//  Sublime
//
//  Created by Eular on 4/20/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation

// MARK: - UIImage
extension UIImage {
    func saveToCameraRoll() {
        UIImageWriteToSavedPhotosAlbum(self, nil, nil, nil)
    }
}

// MARK: - UITabBar
extension UITabBar {
    func showRedBadgeOnItem(index: Int, totalItemNums: Int) {
        hideRedBadgeOnItem(index)
        
        let badgeSize: CGFloat = 8
        
        let badgeView = UIView()
        badgeView.tag = 888 + index
        badgeView.layer.cornerRadius = badgeSize / 2
        badgeView.backgroundColor = Constant.TabBatItemBadgeColor
        
        let percentX = (CGFloat(index) + 0.6) / totalItemNums
        let x = CGFloat(ceilf(Float(percentX * self.width)))
        let y = CGFloat(ceilf(Float(0.1 * self.height)))
        badgeView.frame = CGRectMake(x, y, badgeSize, badgeSize)
        addSubview(badgeView)
    }
    
    func hideRedBadgeOnItem(index: Int) {
        for subView in self.subviews {
            if (subView.tag == 888 + index) {
                subView.removeFromSuperview()
            }
        }
    }
}

// MARK: - Range
extension Range {
    func each(iterator: (Element) -> ()) {
        for i in self {
            iterator(i)
        }
    }
}