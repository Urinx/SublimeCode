//
//  Operation.swift
//  Sublime
//
//  Created by Eular on 4/20/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation

// MARK: - Operation
func + (left: Int, right: String) -> String {
    return "\(left)"+right
}

func + (left: String, right: Int) -> String {
    return left+"\(right)"
}

func * (left: String, right: Int) -> String {
    var s = ""
    for _ in 0..<right { s += left }
    return s
}

func % (left: Int, right: Int) -> Int {
    var tmp = left
    tmp %= right
    return tmp >= 0 ? tmp : tmp + right
}

func / (left: CGFloat, right: Int) -> CGFloat {
    return left / CGFloat(right)
}

func * (left: CGFloat, right: Int) -> CGFloat {
    return left * CGFloat(right)
}

func <<<T> (inout left: [T], right: T) {
    left.append(right)
}
