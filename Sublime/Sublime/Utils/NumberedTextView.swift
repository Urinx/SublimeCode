//
//  NumberedTextView.swift
//  Sublime
//
//  Created by Eular on 5/3/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation

class NumberedTextView: UITextView {
    
    init(frame: CGRect) {
        super.init(frame: frame, textContainer: nil)
        self.frame.origin.y = -7
        self.frame.size.height += 7
        self.backgroundColor = RGB(52, 53, 46)
        self.editable = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let lineAttr = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    let lineNumAttr = [
        NSForegroundColorAttributeName: UIColor.grayColor(),
        NSBackgroundColorAttributeName: RGB(39, 40, 34)
    ]
    
    override var text: String! {
        didSet {
            let tmp = NSMutableAttributedString()
            
            for (i, line) in text.split("\n").enumerate() {
                let attrLineNum = NSMutableAttributedString(string: "\(i)\t", attributes: lineNumAttr)
                let attrLine = NSMutableAttributedString(string: "\(line)\n", attributes: lineAttr)
                tmp.appendAttributedString(attrLineNum)
                tmp.appendAttributedString(attrLine)
            }
            
            self.attributedText = tmp
            self.contentOffset = CGPoint(x: 0, y: 0)
        }
    }
    
}