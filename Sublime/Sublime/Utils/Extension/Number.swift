//
//  Number.swift
//  Sublime
//
//  Created by Eular on 4/20/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation

// MARK: - Int
extension Int {
    var KB: Int {
        return self / 1024
    }
    
    var MB: Int {
        return self.KB / 1024
    }
    
    var GB: Int {
        return self.MB / 1024
    }
    
    func times(block: () -> ()) {
        for _ in 0..<self {
            block()
        }
    }
}

// MARK: - Double
extension Double {
    
    var size: String {
        var str = ""
        var tmp = self
        
        for i in ["KB", "MB", "GB"] {
            tmp = tmp / 1000
            str = "\(tmp.afterPoint(1)) \(i)"
            
            if tmp < 1000 {
                break
            }
            
        }
        
        return str
    }
    
    var KB: Double {
        return self / 1024
    }
    
    var MB: Double {
        return self.KB / 1024
    }
    
    var GB: Double {
        return self.MB / 1024
    }
    
    func afterPoint(n: Int) -> Double {
        let s = String(format: "%.\(n)f", self)
        return Double(s)!
    }
    
    func formatedTime(format: String) -> String {
        let d = NSDate(timeIntervalSince1970: self)
        let GTMzone = NSTimeZone(forSecondsFromGMT: 0)
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = GTMzone
        return formatter.stringFromDate(d)
    }
}