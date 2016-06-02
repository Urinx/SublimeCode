//
//  UIImageView.swift
//  Sublime
//
//  Created by Eular on 4/20/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation

// MARK: - UIImageView
extension UIImageView {
    
    // ---------------------------------
    // MARK: - 长按识别二维码
    var recognizeQRCodeEnabled: Bool {
        get {
            return self.userInteractionEnabled
        }
        set {
            self.userInteractionEnabled = newValue
            
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self._handleLongPress(_:)))
            if newValue { self.addGestureRecognizer(longPress) }
            else { self.removeGestureRecognizer(longPress) }
        }
    }
    
    override public func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override public func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == #selector(self.recognizeQrcode) {
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    @objc private func _handleLongPress(longPress: UILongPressGestureRecognizer) {
        if longPress.state == .Began {
            guard let img = self.image else { return }
            if QRCode().hasQRCode(img) {
                self.becomeFirstResponder()
                let qrcodeItem = UIMenuItem(title: NSLocalizedString("RECOGNIZE_QRCODE", comment: "Recognize QRCode"), action: #selector(self.recognizeQrcode))
                let menu = UIMenuController.sharedMenuController()
                menu.menuItems = [qrcodeItem]
                menu.setTargetRect(self.bounds, inView: self)
                menu.setMenuVisible(true, animated: true)
            }
        }
    }
    
    func recognizeQrcode() {
        guard let img = self.image else { return }
        guard let topController = UIApplication.topViewController() else { return }
        let str = QRCode().read(img)!
        if let url = NSURL(string: str) {
            let backItem = UIBarButtonItem()
            backItem.title = "back"
            topController.navigationItem.backBarButtonItem = backItem
            
            let svc = SublimeSafari(URL: url)
            topController.navigationController?.pushViewController(svc, animated: true)
        } else {
            topController.view.Toast(message: str)
        }
    }
    
    // ---------------------------------
    // 请求网络图片并简单缓存
    public func imageFromUrl(urlString: String) {
        if !urlString.isEmpty {
            let fileMgr = NSFileManager.defaultManager()
            let filePath = Constant.CachePath + urlString.md5 + ".png"
            
            if fileMgr.fileExistsAtPath(filePath) {
                let imgData = fileMgr.contentsAtPath(filePath)
                self.image = UIImage(data: imgData!)
            } else {
                if Network.isConnectedToNetwork() {
                    if let url = NSURL(string: urlString) {
                        let request = NSURLRequest(URL: url)
                        let session = NSURLSession.sharedSession()
                        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                            guard let d = data else { return }
                            let img = UIImage(data: d)
                            let imgData = UIImagePNGRepresentation(img!)
                            imgData?.writeToFile(filePath, atomically: true)
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                self.image = img
                            }
                        })
                        task.resume()
                    }
                }
            }
        }
    }
}
