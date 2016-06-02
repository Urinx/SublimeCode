//
//  Code.swift
//  Sublime
//
//  Created by Eular on 5/10/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation

class Code: File {
    
    let language: String
    
    var id: String {
        return self.read().md5
    }
    
    var lastReadPosition: Double {
        get {
            return Global.Database.doubleForKey("Code-\(id)")
        }
        set {
            Global.Database.setDouble(newValue, forKey: "Code-\(id)")
        }
    }
    
    init(path: String, language: String) {
        self.language = language
        super.init(path: path)
    }
    
}