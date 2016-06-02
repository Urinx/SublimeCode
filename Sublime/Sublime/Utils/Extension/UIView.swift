//
//  UIView.swift
//  Sublime
//
//  Created by Eular on 4/20/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation

// MARK: - UIView
extension UIView {
    
    var x: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            self.frame.origin.x = newValue
        }
    }
    
    var y: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            self.frame.origin.y = newValue
        }
    }
    
    var width: CGFloat {
        get {
            return self.frame.width
        }
        set {
            self.frame.size.width = newValue
        }
    }
    
    var height: CGFloat {
        get {
            return self.frame.height
        }
        set {
            self.frame.size.height = newValue
        }
    }
    
    func atCenter(hasNavigationBar: Bool = false) {
        if let s = self.superview {
            self.center = s.center
            
            if hasNavigationBar {
                self.y -= 64
            }
        }
    }
    
    func snapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, UIScreen.mainScreen().scale)
        self.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func snapshot(frame: CGRect) -> UIImage {
        let pt = frame.origin
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.mainScreen().scale)
        let context = UIGraphicsGetCurrentContext()
        CGContextConcatCTM(context, CGAffineTransformMakeTranslation(-pt.x, -pt.y))
        
        // Dirty fix: force update layer
        self.snapshotViewAfterScreenUpdates(true)
        // Is there someone who help me to can fix this problem, T_T...
        
        self.layer.renderInContext(context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func Toast(message msg: String, hasNavigationBar: Bool = false) {
        let toast = UILabel()
        let h: CGFloat = 30
        toast.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        toast.text = msg
        toast.textColor = UIColor.whiteColor()
        toast.textAlignment = .Center
        toast.font = toast.font.fontWithSize(12)
        toast.alpha = 0
        toast.frame = CGRectMake(0, 0, toast.intrinsicContentSize().width + 10, h)
        addSubview(toast)
        bringSubviewToFront(toast)
        toast.atCenter(hasNavigationBar)
        
        UIView.animateWithDuration(0.5, animations: {
            toast.alpha = 1
        }) { (_) -> Void in
            UIView.animateWithDuration(4, animations: {
                toast.alpha = 0
                }, completion: { (_) -> Void in
                    toast.removeFromSuperview()
            })
        }
    }
    
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
    
    func autoLayout(top top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: superview, attribute: .Top, multiplier: 1, constant: top))
        superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .Left, relatedBy: .Equal, toItem: superview, attribute: .Left, multiplier: 1, constant: left))
        superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: superview, attribute: .Bottom, multiplier: 1, constant: bottom))
        superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .Right, relatedBy: .Equal, toItem: superview, attribute: .Right, multiplier: 1, constant: right))
    }
    
    func autoLayout(top top: CGFloat, left: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: superview, attribute: .Top, multiplier: 1, constant: top))
        superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .Left, relatedBy: .Equal, toItem: superview, attribute: .Left, multiplier: 1, constant: left))
        superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: self.width))
        superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: self.height))
    }
    
    func autoLayout(left left: CGFloat, bottom: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .Left, relatedBy: .Equal, toItem: superview, attribute: .Left, multiplier: 1, constant: left))
        superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: superview, attribute: .Bottom, multiplier: 1, constant: bottom))
        superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: self.width))
        superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: self.height))
    }
    
    func autoLayout(right right: CGFloat, bottom: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .Right, relatedBy: .Equal, toItem: superview, attribute: .Right, multiplier: 1, constant: right))
        superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: superview, attribute: .Bottom, multiplier: 1, constant: bottom))
        superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: self.width))
        superview?.addConstraint(NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: self.height))
    }
}
