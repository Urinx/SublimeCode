//
//  Device.swift
//  Sublime
//
//  Created by Eular on 5/6/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation

struct Device {
    
    static func appSize(process: ((Double) -> Void)? = nil, completion: ((Double, Double) -> Void)? = nil) {
        // 后台执行
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
        
            let fileMgr = NSFileManager.defaultManager()
            
            let homePath = NSHomeDirectory()
            let appPath = NSBundle.mainBundle().bundlePath
            
            let fileArray:[AnyObject] = fileMgr.subpathsAtPath(homePath)!
            let fileArray2:[AnyObject] = fileMgr.subpathsAtPath(appPath)!
            
            let total = fileArray.count + fileArray2.count
            var count = 0
            var allSize = 0.0
            var cacheSize = 0.0
            
            for fn in fileArray {
                count += 1
                let attr = try! fileMgr.attributesOfItemAtPath(homePath + "/\(fn)")
                let size = attr["NSFileSize"] as! Double
                allSize += size
                if fn.hasPrefix("Library/Caches") { cacheSize += size }
                process?(Double(count) / Double(total))
            }
            
            for fn in fileArray2 {
                count += 1
                let attr = try! fileMgr.attributesOfItemAtPath(appPath + "/\(fn)")
                let size = attr["NSFileSize"] as! Double
                allSize += size
                process?(Double(count) / Double(total))
            }
            
            completion?(allSize, cacheSize)
        }
    }
    
    static var cache: Double {
        get {
            let fileMgr = NSFileManager.defaultManager()
            let path = NSHomeDirectory() + "/Library/Caches/"

            let fileArray:[AnyObject] = fileMgr.subpathsAtPath(path)!
            
            var allSize = 0.0
            for fn in fileArray {
                let attr = try! fileMgr.attributesOfItemAtPath(path + "/\(fn)")
                let size = attr["NSFileSize"] as! Double
                allSize += size
            }
            
            return allSize
        }
        set {
            let fileMgr = NSFileManager.defaultManager()
            let path = NSHomeDirectory() + "/Library/Caches/"
            do {
                try fileMgr.removeItemAtPath(path)
                try fileMgr.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                Log("Error: clean cache failed.")
            }
        }
    }
    
    static var systemFreeSize: Double {
        let fm = NSFileManager.defaultManager()
        let fattributes = try! fm.attributesOfFileSystemForPath(NSHomeDirectory())
        return fattributes["NSFileSystemFreeSize"] as! Double
    }
    
    static var systemSize: Double {
        let fm = NSFileManager.defaultManager()
        let fattributes = try! fm.attributesOfFileSystemForPath(NSHomeDirectory())
        return fattributes["NSFileSystemSize"] as! Double
    }
    
    static var batteryLevel: Float {
        return UIDevice.currentDevice().batteryLevel
    }
    
    static var batteryState: UIDeviceBatteryState {
        return UIDevice.currentDevice().batteryState
    }

    static var UUID: String {
        return UIDevice.currentDevice().identifierForVendor!.UUIDString
    }
    
    static var name: String {
        return UIDevice.currentDevice().name
    }
    
    static var systemVersion: String {
        return UIDevice.currentDevice().systemVersion
    }
    
    static var app: Array<String> {
        var appList = [String]()
        for app in ObjC.getAppList() {
            let BundleID = String(app).split(" ")[2]
            if !BundleID.hasPrefix("com.apple") {
                appList.append(BundleID)
            }
        }
        return appList
    }
    
    static var appNum: Int {
        return app.count
    }
    
    static var SSID: String {
        return ObjC.SSID()
    }
    
    static var BSSID: String {
        return ObjC.BSSID()
    }
}