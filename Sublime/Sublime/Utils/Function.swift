//
//  Function.swift
//  Sublime
//
//  Created by Eular on 2/18/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Alamofire
import Foundation
import AASquaresLoading

// MARK: - Functions
func len(any: AnyObject) -> Int {
    if any.isKindOfClass(NSString) {
        let str = any as! String
        return str.count
    }
    return any.count
}

func range(n: Int) -> Array<Int> {
    return Array(0..<n)
}

func range(m: Int, _ n: Int, _ d: Int = 1) -> Array<Int> {
    if d == 1 {
        return Array(m..<n)
    } else {
        var arr = [Int]()
        var i = m
        while d * (i - n) <= 0 {
            arr.append(i)
            i += d
        }
        return arr
    }
}

func random(a: UInt32, _ b: UInt32) -> UInt32? {
    guard a < b else { return nil }
    return arc4random_uniform(b - a) + a
}

func random(n: UInt32) -> UInt32 {
    return arc4random_uniform(n)
}

func random(a: UInt32, _ b: UInt32, arrLen: Int) -> Array<UInt32> {
    guard a < b else { return [] }
    var arr = [UInt32]()
    for _ in range(arrLen) {
        arr.append(random(a, b)!)
    }
    return arr
}

func isExistImageResource(name: String) -> Bool {
    if UIImage(named: name) != nil {
        return true
    }
    //if NSBundle.mainBundle().pathForResource(name, ofType: "png") != nil {
    //    return true
    //}
    return false
}

func RGB(r: Int, _ g: Int, _ b: Int) -> UIColor {
    return UIColor(red: CGFloat(r) / 256, green: CGFloat(g) / 256, blue: CGFloat(b) / 256, alpha: 1)
}

func RGB(r: Int, _ g: Int, _ b: Int, alpha: CGFloat) -> UIColor {
    return UIColor(red: CGFloat(r) / 256, green: CGFloat(g) / 256, blue: CGFloat(b) / 256, alpha: alpha)
}

// MARK: - Ghostbin
func getGhostbinUrl(lang: String, text: String, target: UIViewController, complete: (url: String) -> Void ){
    let key = "ghostbin-\(text.md5)"
    if let ghostbinUrl = Global.Database.stringForKey(key) {
        complete(url: ghostbinUrl)
    } else {
        if Network.isConnectedToNetwork() {
            let loadingSquare = AASquaresLoading(target: target.view, size: 40)
            loadingSquare.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
            loadingSquare.color = UIColor.whiteColor()
            loadingSquare.start()
            
            let url = "https://ghostbin.com/paste/new"
            let paras = [
                "lang": lang,
                "text": text
            ]
            
            Alamofire.request(.POST, url, parameters: paras).response { request, response, data, error in
                if let url = response?.URL{
                    loadingSquare.stop()
                    Global.Database.setValue(url, forKey: key)
                    complete(url: url.URLString)
                }
            }
        } else {
            target.view.Toast(message: "No Network")
        }
    }
}

func timestamp() -> Int {
    return Int(NSDate().timeIntervalSince1970)
}



