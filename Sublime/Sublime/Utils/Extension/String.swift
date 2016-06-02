//
//  String.swift
//  Sublime
//
//  Created by Eular on 4/20/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation

// MARK: - String
extension String {
    // MARK: - property
    
    // md5 need import <CommonCrypto/CommonCrypto.h> in bridging header file
    var md5: String! {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.dealloc(digestLen)
        
        return String(format: hash as String)
    }
    
    // sha1 need import <CommonCrypto/CommonHMAC.h> in bridging header file
    var sha1: String {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
        var digest = [UInt8](count:Int(CC_SHA1_DIGEST_LENGTH),repeatedValue:0)
        CC_SHA1(data.bytes, CC_LONG(data.length), &digest)
        
        let output = NSMutableString(capacity: Int(CC_SHA1_DIGEST_LENGTH))
        for byte in digest{
            output.appendFormat("%02x", byte)
        }
        return output as String
    }
    
    // length of the string
    var count: Int {
        return self.characters.count
    }
    
    var lower: String {
        return self.lowercaseString
    }
    
    var upper: String {
        return self.uppercaseString
    }
    
    var islower: Bool {
        return self == self.lower
    }
    
    var isupper: Bool {
        return self == self.upper
    }
    
    var lastPathComponent: String {
        return (self as NSString).lastPathComponent
    }
    
    var pathExtension: String {
        return (self as NSString).pathExtension
    }
    
    var stringByDeletingLastPathComponent: String {
        return (self as NSString).stringByDeletingLastPathComponent
    }
    var stringByDeletingPathExtension: String {
        return (self as NSString).stringByDeletingPathExtension
    }
    
    var pathComponents: [String] {
        return (self as NSString).pathComponents
    }
    
    // format: "#ffffff"
    var color: UIColor? {
        if self[0] == "#" {
            if let r = Int(self[1,3], radix: 16),
                let g = Int(self[3,5], radix: 16),
                let b = Int(self[5,nil], radix: 16) {
                return RGB(r, g, b)
            }
        }
        return nil
    }
    
    // MARK: - method
    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.stringByAppendingPathComponent(path)
    }
    
    func stringByAppendingPathExtension(ext: String) -> String? {
        let nsSt = self as NSString
        return nsSt.stringByAppendingPathExtension(ext)
    }
    
    // Return the number of non-overlapping occurrences of substring sub in string S[start:end]
    func count(subString: String) -> Int {
        var n = 0
        if let r = self.rangeOfString(subString) {
            n += 1 + self.substringFromIndex(r.endIndex).count(subString)
        }
        return n
    }
    
    func has(subString: String) -> Bool {
        if self.rangeOfString(subString) != nil {
            return true
        }
        return false
    }
    
    func hasAny(strArr: Array<String>) -> Bool {
        let r = strArr.filter() { self.has($0) }
        return !r.isEmpty
    }
    
    // Remove the last character and return it
    mutating func pop() -> Character {
        return self.removeAtIndex(self.endIndex.predecessor())
    }
    
    // Return the lowest index in S where substring sub is found
    func find(subString: String) -> Int {
        if let r = self.rangeOfString(subString) {
            return Int(String(r.startIndex))!
        } else {
            return -1
        }
    }
    
    // Return a string which is the concatenation of the strings in the iterable.
    func join(arr: Array<AnyObject>) -> String {
        var str = ""
        for i in arr {
            str += String(i) + self
        }
        str.pop()
        return str
    }
    
    func split(separator: String = " ") -> [String] {
        return self.componentsSeparatedByString(separator)
    }
    
    func replace(before: String, _ after: String) -> String {
        return self.stringByReplacingOccurrencesOfString(before, withString: after)
    }
    
    // Return a copy of the string S with leading and trailing whitespace removed
    func strip(char: Character = " ") -> String {
        return String(self.characters.filter() { $0 != char } )
    }
    
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(.whitespaceCharacterSet())
    }
    
    func trim(charSet charSet: NSCharacterSet) -> String {
        return self.stringByTrimmingCharactersInSet(charSet)
    }
    
    func urlencode() -> String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
    }
    
    // String indices
    subscript(index: Int) -> Character {
        if index >= 0 {
            return self[self.startIndex.advancedBy(index)]
        } else {
            return self[self.endIndex.advancedBy(index)]
        }
    }
    
    subscript(m: Int?, n: Int?) -> String {
        var i1: Index, i2: Index
        if m != nil {
            i1 = self.startIndex.advancedBy(m!)
        } else {
            i1 = self.startIndex
        }
        if n != nil {
            if n >= 0 {
                i2 = self.startIndex.advancedBy(n!)
            } else {
                i2 = self.endIndex.advancedBy(n!)
            }
        } else {
            i2 = self.endIndex
        }
        let indexRange = Range(i1..<i2)
        return self.substringWithRange(indexRange)
    }
    
    subscript(range: Range<Int>) -> String {
        return self[range.startIndex, range.endIndex]
    }
}