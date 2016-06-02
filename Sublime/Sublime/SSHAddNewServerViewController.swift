//
//  SSHAddNewServerViewController.swift
//  Sublime
//
//  Created by Eular on 3/28/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import UIKit
import Gifu

class SSHAddNewServerViewController: UITableViewController, UITextFieldDelegate {
    
    let settingList = [
        ["ssh_server", "host"],
        ["ssh_port", "port"],
        ["ssh_user", "username"],
        ["ssh_password", "password"]
    ]
    var textFieldList = [UITextField]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Server"
        tableView.backgroundColor = Constant.CapeCod
        tableView.separatorColor = Constant.TableCellSeparatorColor
        tableView.tableFooterView = UIView()
        
        Global.Notifi.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIKeyboardDidShowNotification, object: nil)
        Global.Notifi.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIKeyboardDidHideNotification, object: nil)
        
        let header = UIView(frame: CGRectMake(0, 0, view.width, 80))
        let gif = AnimatableImageView()
        gif.frame = CGRectMake(0, 20, view.width, 60)
        gif.contentMode = .ScaleAspectFit
        gif.animateWithImageData(NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("animation", ofType: "gif")!)!)
        gif.startAnimatingGIF()
        header.addSubview(gif)
        tableView.tableHeaderView = header
    }
    
    func keyboardDidShow() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ssh_keyboard"), style: .Plain, target: self, action: #selector(self.dismissKeyboard))
    }
    
    func keyboardWillHide() {
        navigationItem.rightBarButtonItem = nil
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [settingList.count, 1][section]
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 0 }
        return Constant.FilesTableSectionHight
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { return nil }
        let headerView = UIView()
        headerView.frame = CGRectMake(0, 0, view.width, Constant.FilesTableSectionHight)
        headerView.backgroundColor = Constant.CapeCod
        return headerView
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        cell.backgroundColor = Constant.NavigationBarAndTabBarColor
        cell.selectedBackgroundView = UIView(frame: cell.frame)
        cell.selectedBackgroundView?.backgroundColor = Constant.NavigationBarAndTabBarColor
        
        if indexPath.section == 0 {
            let tf = UITextField()
            tf.frame = CGRectMake(70, 3, cell.frame.width - 80, cell.frame.height)
            tf.attributedPlaceholder = NSAttributedString(string: settingList[indexPath.row][1], attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
            tf.textColor = UIColor.whiteColor()
            tf.delegate = self
            if tf.placeholder == "port" {
                tf.keyboardType = .NumberPad
            } else if tf.placeholder == "host" {
                tf.keyboardType = .URL
            }
            tf.autocorrectionType = .No
            tf.autocapitalizationType = .None
            cell.addSubview(tf)
            cell.imageView?.image = UIImage(named: settingList[indexPath.row][0])
            
            textFieldList.append(tf)
        } else {
            let doneImg = UIImageView()
            doneImg.frame = CGRectMake(0, 0, 40, 40)
            doneImg.image = UIImage(named: "ssh_done")
            cell.addSubview(doneImg)
            doneImg.atCenter()
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 1 {
            var serverInfo = [String:String]()
            for tf in textFieldList {
                if tf.text!.isEmpty {
                    view.Toast(message: "\(tf.placeholder!) can't be empty", hasNavigationBar: true)
                    return
                } else {
                    serverInfo[tf.placeholder!] = tf.text
                }
            }
            
            let serverPlist = Plist(path: Constant.SublimeRoot+"/etc/ssh_list.plist")
            do {
                try serverPlist.appendToPlistFile(serverInfo)
                navigationController?.popViewControllerAnimated(true)
            } catch {
                view.Toast(message: "Save failed!", hasNavigationBar: true)
            }
            
        }
    }
}
