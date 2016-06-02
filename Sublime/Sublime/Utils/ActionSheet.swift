//
//  DropdownMenu.swift
//  Sublime
//
//  Created by Eular on 5/3/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation

protocol ActionSheetDelegate {
    func tapOnActionSheetItem(itemAtRow row: Int)
}

class ActionSheet {
    var delegate: ActionSheetDelegate?
    var controller: UIViewController?
    var items: [String] = []
    
    private var sheet: UIView?
    private var mask: UIView?
    
    private let rowWidth: CGFloat
    private let rowHight: CGFloat
    private let cancelGap: CGFloat = 5
    
    private let textColor = Constant.ActionSheetTextColor
    private let splitLineColor = Constant.ActionSheetLineColor
    private let actionSheetColor = Constant.ActionSheetColor
    private let maskColor = Constant.BlackMaskViewColor
    
    init(rowWidth: CGFloat, rowHight: CGFloat) {
        self.rowWidth = rowWidth
        self.rowHight = rowHight
    }
    
    @objc func showUp() {
        let window = controller?.view.window
        
        var sheetItems = items
        sheetItems << "Cancel"
        let numberOfRow = sheetItems.count
        let actionSheetHight = rowHight * numberOfRow + cancelGap
        
        let actionSheet = UIView(frame: CGRectMake(0, window?.height ?? 0, rowWidth, actionSheetHight))
        actionSheet.backgroundColor = actionSheetColor
        
        // Insert item label into menu
        for i in 0..<numberOfRow {
            let btn = UIButton()
            btn.frame = CGRectMake(0, rowHight * i + (i == numberOfRow - 1 ? cancelGap : 0), rowWidth, rowHight)
            btn.setTitle(sheetItems[i], forState: .Normal)
            btn.setTitleColor(textColor, forState: .Normal)
            btn.tag = i
            btn.addTarget(self, action: #selector(tapOnActionSheetItem(_:)), forControlEvents: .TouchUpInside)
            actionSheet.addSubview(btn)
            
            // Draw a line
            if i != 0 {
                let line = UILabel()
                line.frame = CGRectMake(0, rowHight * i, rowWidth, i == numberOfRow - 1 ? cancelGap : 1)
                line.backgroundColor = splitLineColor
                actionSheet.addSubview(line)
            }
        }
        
        // Black the below view
        let blackMaskView = UIView(frame: window?.frame ?? CGRectZero)
        blackMaskView.backgroundColor = maskColor
        blackMaskView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnBlackMaskView)))
        
        window?.addSubview(blackMaskView)
        window?.addSubview(actionSheet)
        
        UIView.animateWithDuration(0.3) { () -> Void in
            actionSheet.y -= actionSheet.height
        }
        
        self.sheet = actionSheet
        self.mask = blackMaskView
    }
    
    @objc private func tapOnBlackMaskView() {
        dismissActionSheet()
    }
    
    @objc private func tapOnActionSheetItem(btn: UIButton) {
        dismissActionSheet {
            if btn.tag != self.items.count {
                self.delegate?.tapOnActionSheetItem(itemAtRow: btn.tag)
            }
        }
    }
    
    private func dismissActionSheet(completion: (() -> Void)? = nil) {
        if let actionSheet = self.sheet, blackMaskView = self.mask {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                actionSheet.y += actionSheet.height
            }, completion: { (_) -> Void in
                actionSheet.removeFromSuperview()
                blackMaskView.removeFromSuperview()
                completion?()
            })
        }
    }
}