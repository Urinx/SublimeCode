//
//  Log.swift
//  Sublime
//
//  Created by Eular on 4/20/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation

// MARK: - Log
func Log<T>(message: T, file: String = #file, function: String = #function, line: Int = #line) {
    // Executed only on simulator
    #if arch(i386) || arch(x86_64)
        print("\(file.lastPathComponent)[\(line)], \(function): \(message)")
    #endif
}