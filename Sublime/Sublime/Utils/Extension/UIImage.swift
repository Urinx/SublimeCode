//
//  UIImage.swift
//  Sublime
//
//  Created by Eular on 5/8/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation

extension UIImage {
    func rescaleImageToSize(width: CGFloat, _ height: CGFloat) -> UIImage {
        let rect = CGRectMake(0, 0, width, height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.mainScreen().scale)
        self.drawInRect(rect)
        let resImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resImage
    }
    
    func rescaleImageByWidth(width: CGFloat) -> UIImage {
        let height = width / self.size.width * self.size.height
        return self.rescaleImageToSize(width, height)
    }
}