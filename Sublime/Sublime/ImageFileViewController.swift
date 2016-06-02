//
//  ImageFileViewController.swift
//  Sublime
//
//  Created by Eular on 2/15/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import UIKit
import Gifu

class ImageFileViewController: UIViewController {
    
    var curFile: File!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constant.CapeCod
        
        let imgView: UIImageView
        let imgData = NSData(contentsOfURL: curFile.url)!
        
        if curFile.ext == "gif" {
            imgView = AnimatableImageView()
            (imgView as! AnimatableImageView).animateWithImageData(imgData)
            (imgView as! AnimatableImageView).startAnimatingGIF()
        } else {
            imgView = UIImageView(image: UIImage(data: imgData))
            imgView.recognizeQRCodeEnabled = true
        }
        
        imgView.frame = CGRectMake(0, 10, view.width, view.height - 140 )
        imgView.contentMode = .ScaleAspectFit
        view.addSubview(imgView)
        
    }

}
