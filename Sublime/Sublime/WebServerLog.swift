//
//  ServerLog.swift
//  Sublime
//
//  Created by Eular on 3/11/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation
import Swifter


public class WebServerLog {
    let output: UITextView
    var logFile: File?
    
    init(output: UITextView) {
        self.output = output
    }
    
    func log(msg: String, isError: Bool = false) {
        let t = formattedTimeString()
        let strList: [[String: AnyObject]] = [
            ["str": "[\(t)] ", "color": "#FD9720".color!],
            ["str": "\(msg)\n", "color": isError ? "#FF3C50".color! : UIColor.whiteColor()],
        ]
        outputString(toAttributedString(strList))
    }
    
    func log(r: HttpRequest, statusCode: Int = 200) {
        let t = formattedTimeString()
        let ip = r.address!
        let method = r.method
        let path = r.path
        let userAgent = r.headers["user-agent"]!
        
        let strList: [[String: AnyObject]] = [
            ["str": "[\(t)] ", "color": "#FD9720".color!],
            ["str": "-- ", "color": UIColor.whiteColor()],
            ["str": "\(ip) ", "color": "#66D9EF".color!],
            ["str": "\"\(method) \(path) HTTP/1.1\" ", "color": "#AE81FF".color!],
            ["str": "\(statusCode) ", "color": "#4CD964".color!],
            ["str": "\"\(userAgent)\"\n", "color": UIColor.grayColor()]
        ]
        
        outputString(toAttributedString(strList))
    }
    
    func saveInLogFile(str: String) {
        if logFile == nil {
            let t = formattedTimeString().split()[0]
            let fname = "\(t).log"
            let logFolder = Folder(path: Constant.SublimeRoot+"/var/log")
            if !logFolder.checkFileExist(fname) {
                logFolder.newFile(fname)
            }
            self.logFile = File(path: Constant.SublimeRoot+"/var/log/\(fname)")
        }
        
        logFile?.append(str)
    }
    
    private func toAttributedString(strList: [[String: AnyObject]]) -> NSMutableAttributedString {
        let attrStr = NSMutableAttributedString()
        for s in strList {
            let attr = [NSForegroundColorAttributeName: s["color"] as! UIColor]
            let str = NSMutableAttributedString(string: s["str"] as! String, attributes: attr)
            attrStr.appendAttributedString(str)
        }
        return attrStr
    }
    
    private func outputString(newLog: NSMutableAttributedString) {
        let log = NSMutableAttributedString()
        
        dispatch_async(dispatch_get_main_queue()) {
            let oldLog = NSMutableAttributedString(attributedString: self.output.attributedText)
            log.appendAttributedString(oldLog)
            log.appendAttributedString(newLog)
            self.output.attributedText = log
            self.output.setLineBreakMode(.ByCharWrapping)
            self.output.scrollToBottom()
        }
    }
    
    private func formattedTimeString() -> String {
        let now = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.stringFromDate(now)
    }
}