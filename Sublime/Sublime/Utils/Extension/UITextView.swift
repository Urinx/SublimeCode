//
//  UITextView.swift
//  Sublime
//
//  Created by Eular on 4/20/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation

// MARK: - UITextView
extension UITextView {
    func scrollToBottom() {
        let range:NSRange = NSMakeRange(self.text.characters.count - 1, 1)
        self.scrollRangeToVisible(range)
        self.scrollEnabled = false
        self.scrollEnabled = true
    }
    
    func setLineBreakMode(mode: NSLineBreakMode) {
        let attrStr = self.attributedText.mutableCopy()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = mode
        attrStr.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attrStr.mutableString.length))
        self.attributedText = attrStr as! NSAttributedString
    }
}