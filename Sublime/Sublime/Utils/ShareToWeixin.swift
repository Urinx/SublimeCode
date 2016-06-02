//
//  ShareToWeixin.swift
//  Sublime
//
//  Created by Eular on 2/18/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import UIKit
import Foundation

// MARK: - 微信分享
extension UIViewController {
    // MARK: - 分享链接
    func WXShareLink(title: String, desc: String, img: String, link: String, isTimeline: Bool = false) {
        if WXApi.isWXAppInstalled() {
            let message = WXMediaMessage()
            message.title = title
            message.description = desc
            message.setThumbImage(UIImage(named: img))
            let ext = WXWebpageObject()
            ext.webpageUrl = link
            message.mediaObject = ext
            let req =  SendMessageToWXReq()
            req.bText = false
            req.message = message
            req.scene = isTimeline ? Int32(WXSceneTimeline.rawValue) : Int32(WXSceneSession.rawValue)
            WXApi.sendReq(req)
        } else {
            _WXIsNotInstallAlert()
        }
    }
    
    // MARK: - 分享图片
    func WXShareImage(image: UIImage, isTimeline: Bool = false) {
        if WXApi.isWXAppInstalled() {
            let message = WXMediaMessage()
            
            let imageObject = WXImageObject()
            imageObject.imageData = UIImagePNGRepresentation(image)
            message.mediaObject = imageObject
            
            //图片缩略图
            let width: CGFloat = 240
            let height = width * image.size.height / image.size.width
            UIGraphicsBeginImageContext(CGSizeMake(width, height))
            image.drawInRect(CGRectMake(0, 0, width, height))
            message.setThumbImage(UIGraphicsGetImageFromCurrentImageContext())
            UIGraphicsEndImageContext()
            
            let req = SendMessageToWXReq()
            req.bText = false
            req.message = message
            req.scene = isTimeline ? Int32(WXSceneTimeline.rawValue) : Int32(WXSceneSession.rawValue)
            WXApi.sendReq(req)
        } else {
            _WXIsNotInstallAlert()
        }
    }
    
    // MARK: - 分享文字
    func WXShareText(text: String, isTimeline: Bool = false) {
        if WXApi.isWXAppInstalled() {
            let req = SendMessageToWXReq()
            req.bText = true
            req.text = text
            req.scene = isTimeline ? Int32(WXSceneTimeline.rawValue) : Int32(WXSceneSession.rawValue)
            WXApi.sendReq(req)
        } else {
            _WXIsNotInstallAlert()
        }
    }
    
    // MARK: - 分享音乐
    func WXShareMusic(name: String, singer: String, img: String, url: String, isTimeline: Bool = false) {
        if WXApi.isWXAppInstalled() {
            let message = WXMediaMessage()
            message.title = name
            message.description = singer
            message.setThumbImage(UIImage(named: img))
            
            let music = WXMusicObject()
            music.musicUrl = url
            music.musicDataUrl = url
            message.mediaObject = music
            
            let req = SendMessageToWXReq()
            req.bText = false
            req.message = message
            req.scene = isTimeline ? Int32(WXSceneTimeline.rawValue) : Int32(WXSceneSession.rawValue)
            WXApi.sendReq(req)
        } else {
            _WXIsNotInstallAlert()
        }
    }
    
    // MARK: - 分享视频
    func WXShareVideo(title: String, desc: String, img: String, url: String, isTimeline: Bool = false) {
        if WXApi.isWXAppInstalled() {
            let message = WXMediaMessage()
            message.title = title
            message.description = desc
            message.setThumbImage(UIImage(named: img))
            
            let video = WXVideoObject()
            video.videoUrl = url
            message.mediaObject = video
            
            let req = SendMessageToWXReq()
            req.bText = false
            req.message = message
            req.scene = isTimeline ? Int32(WXSceneTimeline.rawValue) : Int32(WXSceneSession.rawValue)
            WXApi.sendReq(req)
        } else {
            _WXIsNotInstallAlert()
        }
    }
    
    // MARK: - 分享表情，包括gif
    func WXShareEmoticon(emotPath: String, isTimeline: Bool = false) {
        if WXApi.isWXAppInstalled() {
            let message = WXMediaMessage()
            message.setThumbImage(UIImage(contentsOfFile: emotPath))
            
            let emot = WXEmoticonObject()
            emot.emoticonData = NSData(contentsOfFile: emotPath)
            message.mediaObject = emot
            
            let req = SendMessageToWXReq()
            req.bText = false
            req.message = message
            req.scene = isTimeline ? Int32(WXSceneTimeline.rawValue) : Int32(WXSceneSession.rawValue)
            WXApi.sendReq(req)
        } else {
            _WXIsNotInstallAlert()
        }
    }
    
    // MARK: - 分享文件
    func WXShareFile(title: String, desc: String, file: File, isTimeline: Bool = false) {
        if WXApi.isWXAppInstalled() {
            let message = WXMediaMessage()
            message.title = title
            message.description = desc
            message.setThumbImage(UIImage(named: file.img))
            
            let fobj = WXFileObject()
            fobj.fileExtension = file.ext
            fobj.fileData = file.data
            message.mediaObject = fobj
            
            let req = SendMessageToWXReq()
            req.bText = false
            req.message = message
            req.scene = isTimeline ? Int32(WXSceneTimeline.rawValue) : Int32(WXSceneSession.rawValue)
            WXApi.sendReq(req)
        } else {
            _WXIsNotInstallAlert()
        }
    }
    
    func WXLogin() {
        let req: SendAuthReq = SendAuthReq()
        req.scope = "snsapi_userinfo,snsapi_base"
        WXApi.sendReq(req)
    }
    
    // MARK: - 私有方法
    private func _WXIsNotInstallAlert() {
        let alert = UIAlertController(title: "Share Fail", message: "Wechat app is not installed!", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
}