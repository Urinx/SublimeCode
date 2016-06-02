//
//  Constant.swift
//  Sublime
//
//  Created by Eular on 2/14/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation

struct Global {
    static var UnreadMessageCount = 0
    
    static let Database = NSUserDefaults.standardUserDefaults()
    static let Notifi = NSNotificationCenter.defaultCenter()
}
