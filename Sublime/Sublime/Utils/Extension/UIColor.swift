//
//  UIColor.swift
//  Sublime
//
//  Created by Eular on 5/4/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation

extension UIColor{
    func toImage() -> UIImage {
        let rect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        self.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}