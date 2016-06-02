//
//  SSHTerminalViewController.swift
//  Sublime
//
//  Created by Eular on 3/28/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import UIKit
import NMSSH

class SSHTerminalViewController: UIViewController, UITextViewDelegate {
    
    var server = ["host": "localhost", "port": "22", "username": "sublime", "password": "sublime"]
    
    let terminalTextView = UITextView()
    var sshSession: NMSSHSession!
    var shellPrompt: String!
    let promptView = UIView()
    var promptViewBottom: NSLayoutConstraint!
    var promptViewHeight: NSLayoutConstraint!
    let promptLines = 3
    let promptLineHeight: CGFloat = 14
    let promptViewTopMargin: CGFloat = 5
    let promptViewBottomOffset: CGFloat = 5

    override func viewDidLoad() {
        super.viewDidLoad()
        title = server["host"]
        view.backgroundColor = Constant.CapeCod
        shellPrompt = "[\(server["username"]!)@\(server["host"]!) ~] >"
        
        Global.Notifi.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        Global.Notifi.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIKeyboardDidShowNotification, object: nil)
        Global.Notifi.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        view.addSubview(terminalTextView)
        view.addSubview(promptView)
        setTerminalTextView()
        setPromptView(">", lineHeight: promptLineHeight, maxLines: promptLines)
        
        SSHLog("[sublime@localhost ~] > ssh \(server["username"]!)@\(server["host"]!):\(server["port"]!)")
    }
    
    deinit {
        sshSession.disconnect()
    }
    
    func keyboardWillShow(noti: NSNotification) {
        let info = noti.userInfo!
        let value = info[UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let value2 = info[UIKeyboardAnimationDurationUserInfoKey] as! NSValue
        let keyboardSize = value.CGRectValue()
        let height = keyboardSize.height
        var time: NSTimeInterval = 0
        value2.getValue(&time)

        promptViewBottom.constant = -height - promptViewBottomOffset
        UIView.animateWithDuration(time, animations: { 
            self.view.layoutIfNeeded()
        }) { (_) in
            self.updateTerminalTextView()
        }
    }
    
    func keyboardDidShow() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ssh_keyboard"), style: .Plain, target: self, action: #selector(self.dismissKeyboard))
    }
    
    func keyboardWillHide(noti: NSNotification) {
        navigationItem.rightBarButtonItem = nil
        
        let info = noti.userInfo!
        let value2 = info[UIKeyboardAnimationDurationUserInfoKey] as! NSValue
        var time: NSTimeInterval = 0
        value2.getValue(&time)
        promptViewBottom.constant = -promptViewBottomOffset
        UIView.animateWithDuration(time) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func setTerminalTextView() {
        // terminalTextView.frame = view.frame
        terminalTextView.backgroundColor = Constant.CapeCod
        terminalTextView.textColor = UIColor.whiteColor()
        terminalTextView.textContainerInset.top = 0
        terminalTextView.textContainerInset.bottom = 0
        terminalTextView.editable = false
        terminalTextView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: terminalTextView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: terminalTextView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: terminalTextView, attribute: .Bottom, relatedBy: .Equal, toItem: promptView, attribute: .Top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: terminalTextView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: view.width))
    }
    
    func setPromptView(promptText: String, lineHeight: CGFloat, maxLines: Int){
        promptView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add constraints
        promptViewBottom = NSLayoutConstraint(item: promptView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: -promptViewBottomOffset)
        promptViewHeight = NSLayoutConstraint(item: promptView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: lineHeight)
        view.addConstraint(promptViewBottom)
        view.addConstraint(NSLayoutConstraint(item: promptView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: promptView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: view.width))
        view.addConstraint(promptViewHeight)
        
        let prompt = UILabel()
        prompt.text = promptText
        prompt.textColor = UIColor.whiteColor()
        prompt.font = terminalTextView.font
        prompt.frame = CGRectMake(5, 0, prompt.intrinsicContentSize().width, lineHeight)
        promptView.addSubview(prompt)
        
        let input = UITextView()
        input.frame = CGRectMake(0, 0, view.width, lineHeight * maxLines)
        input.backgroundColor = UIColor.clearColor()
        input.font = terminalTextView.font
        input.textContainer.maximumNumberOfLines = maxLines
        input.textContainerInset.top = 0
        input.textContainerInset.bottom = 0
        input.autocorrectionType = .No
        input.autocapitalizationType = .None
        input.keyboardType = .ASCIICapable
        input.keyboardAppearance = .Dark
        input.spellCheckingType = .No
        input.delegate = self
        input.tintColor = UIColor.whiteColor()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByCharWrapping
        paragraphStyle.firstLineHeadIndent = prompt.frame.width + prompt.frame.origin.x
        let attrs = [
            NSParagraphStyleAttributeName: paragraphStyle,
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        input.attributedText = NSAttributedString(string: " ", attributes: attrs)
        input.text = nil
        promptView.addSubview(input)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {

            let cmd = textView.text.trim()
            if cmd.isEmpty {
                SSHLog(shellPrompt)
            } else {
                SSHLog("\(shellPrompt) \(cmd)")
                textView.text = nil
                
                if promptViewHeight.constant != promptLineHeight {
                    promptViewHeight.constant = promptLineHeight
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.view.layoutIfNeeded()
                    })
                }
                
                if sshSession.authorized {
                    do {
                        let response = try sshSession.channel.execute(cmd)
                        if !response.isEmpty {
                            SSHLog(response[nil,-1])
                        }
                    } catch {}
                }
            }
            
            return false
        }
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        promptViewHeight.constant = textView.contentSize.height
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        let user = server["username"]!
        let host = server["host"]!
        let port = server["port"]!
        let passwd = server["password"]!
        sshSession = NMSSHSession(host: "\(host):\(port)", andUsername: user)
        
        if Network.isConnectedToNetwork() {
            if sshSession.connect() {
                SSHLog("Password: ******")
                if sshSession.authenticateByPassword(passwd) {
                    SSHLog("Connect: Successful!")
                    SSHLog("=============================")
                } else {
                    SSHLog("Error: Password is wrong!")
                }
            } else {
                SSHLog("Error: Connect fialed!")
            }
        } else {
            SSHLog("Error: No network!")
        }
    }
    
    func SSHLog(msg: String) {
        terminalTextView.text = terminalTextView.text + "\(msg)\n"
        terminalTextView.setLineBreakMode(.ByCharWrapping)
        terminalTextView.scrollToBottom()
    }
    
    func updateTerminalTextView() {
        terminalTextView.attributedText = terminalTextView.attributedText.copy() as! NSAttributedString
        terminalTextView.scrollToBottom()
    }

}
