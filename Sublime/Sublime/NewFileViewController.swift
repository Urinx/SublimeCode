//
//  NewFileViewController.swift
//  Sublime
//
//  Created by Eular on 2/14/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import UIKit

class NewFileViewController: UIViewController {

    var fileImg: UIImageView!
    var filenameText: UITextField!
    var warningLabel: UILabel!
    
    let keywords = [
        ["file_unknown", "New File", "File Name"],
        ["folder", "New Folder", "Folder Name"]
    ]
    var tag = 0
    var curFolder: Folder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constant.CapeCod
        title = keywords[tag][1]
        
        let inputView = UIView()
        inputView.frame = CGRectMake(0, Constant.NavigationBarOffset + 43, view.width, 44)
        inputView.backgroundColor = RGB(140, 140, 140, alpha: 0.4)
        view.addSubview(inputView)
        
        fileImg = UIImageView()
        fileImg.frame = CGRectMake(10, 8, 28, 28)
        fileImg.image = UIImage(named: keywords[tag][0])
        inputView.addSubview(fileImg)
        
        filenameText = UITextField()
        filenameText.frame = CGRectMake(48, 0, view.width - 52, 44)
        filenameText.textColor = UIColor.whiteColor()
        filenameText.placeholder = keywords[tag][2]
        filenameText.autocorrectionType = .No
        filenameText.autocapitalizationType = .None
        filenameText.keyboardType = .ASCIICapable
        filenameText.spellCheckingType = .No
        filenameText.becomeFirstResponder()
        inputView.addSubview(filenameText)
        
        warningLabel = UILabel()
        warningLabel.frame = CGRectMake(0, inputView.y + inputView.height + 12, view.width, 18)
        warningLabel.font = warningLabel.font.fontWithSize(12)
        warningLabel.textAlignment = .Center
        warningLabel.textColor = UIColor.whiteColor()
        warningLabel.alpha = 0
        view.insertSubview(warningLabel, belowSubview: inputView)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(self.createNew))
    }
    
    func createNew() {
        let text = filenameText.text!.strip()
        if text.isEmpty {
            showWarningMsg("Name can't be empty")
        } else if curFolder.checkFileExist(text) {
            showWarningMsg("The file already existed")
        } else {
            switch tag {
            case 0:
                if curFolder.newFile(text) {
                    navigationController?.popViewControllerAnimated(true)
                } else {
                    showWarningMsg("New file failed")
                }
            case 1:
                if curFolder.newFolder(text) {
                    navigationController?.popViewControllerAnimated(true)
                } else {
                    showWarningMsg("New folder failed")
                }
            default: return
            }
        }
    }
    
    func showWarningMsg(word: String) {
        warningLabel.text = word
        UIView.animateWithDuration(0.5,
            animations: { () -> Void in
                self.warningLabel.alpha = 1
            },
            completion: { (_) -> Void in
                UIView.animateWithDuration(3) {
                    self.warningLabel.alpha = 0
                }
            })
    }

}
