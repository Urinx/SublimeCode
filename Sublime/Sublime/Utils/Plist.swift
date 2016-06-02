//
//  Plist.swift
//  Sublime
//
//  Created by Eular on 3/31/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation

struct Plist {
    enum PlistError: ErrorType {
        case FileNotWritten
        case FileDoesNotExist
    }
    
    let name: String
    let path: String
    
    init(path: String) {
        self.path = path
        self.name = path.lastPathComponent
        
        if !NSFileManager.defaultManager().fileExistsAtPath(path) {
            let f = Folder(path: path.stringByDeletingLastPathComponent)
            f.newFile(name)
        }
    }
    
    func getDictInPlistFile() -> NSDictionary? {
        guard let dict = NSDictionary(contentsOfFile: path) else { return .None }
        return dict
    }
    
    func getMutableDictInPlistFile() -> NSMutableDictionary? {
        guard let dict = NSMutableDictionary(contentsOfFile: path) else { return .None }
        return dict
    }
    
    func getArrayInPlistFile() -> NSArray? {
        guard let arr = NSArray(contentsOfFile: path) else { return .None }
        return arr
    }
    
    func getMutableArrayInPlistFile() -> NSMutableArray? {
        guard let arr = NSMutableArray(contentsOfFile: path) else { return .None }
        return arr
    }
    
    func saveToPlistFile(any: AnyObject) throws {
        if !any.writeToFile(path, atomically: false) {
            throw PlistError.FileNotWritten
        }
    }
    
    func appendToPlistFile(any: AnyObject) throws {
        if let arr = getMutableArrayInPlistFile() {
            arr.addObject(any)
            if !arr.writeToFile(path, atomically: false) {
                throw PlistError.FileNotWritten
            }
        } else {
            if !NSArray(array: [any]).writeToFile(path, atomically: false) {
                throw PlistError.FileNotWritten
            }
        }
    }
}