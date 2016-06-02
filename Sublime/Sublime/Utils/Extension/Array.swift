//
//  Array.swift
//  Sublime
//
//  Created by Eular on 4/20/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation

// MARK: - Array
extension Array {
    mutating func shift() -> Element? {
        return self.removeFirst()
    }
    
    mutating func pop() -> Element? {
        return self.popLast()
    }
}

class Array2D<T> {
    let rows: Int
    let columns: Int
    var array: Array<T?>
    
    init(_ rows: Int, _ columns: Int) {
        self.rows = rows
        self.columns = columns
        
        array = Array<T?>(count:rows * columns, repeatedValue: nil)
    }
    
    subscript(row: Int, column: Int) -> T? {
        get {
            return array[(row * columns) + column]
        }
        set {
            array[(row * columns) + column] = newValue
        }
    }
}