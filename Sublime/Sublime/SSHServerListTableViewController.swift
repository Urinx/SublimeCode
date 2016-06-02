//
//  SSHServerListTableViewController.swift
//  Sublime
//
//  Created by Eular on 3/28/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import UIKit

class SSHServerListTableViewController: UITableViewController {
    
    let serverPlist = Plist(path: Constant.SublimeRoot+"/etc/ssh_list.plist")
    var serverList: [[String: String]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Servers"
        tableView.backgroundColor = Constant.CapeCod
        tableView.separatorColor = Constant.NavigationBarAndTabBarColor
        tableView.tableFooterView = UIView()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(self.addNewServer))
        
    }
    
    override func viewWillAppear(animated: Bool) {
        if let arr = serverPlist.getArrayInPlistFile() {
            serverList = arr as! [[String : String]]
            tableView.reloadData()
        }
    }
    
    func addNewServer() {
        let addnew = SSHAddNewServerViewController()
        navigationController?.pushViewController(addnew, animated: true)
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverList.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Constant.SSHServerListCellHeight
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        cell.backgroundColor = Constant.NavigationBarAndTabBarColor
        cell.selectedBackgroundView = UIView(frame: cell.frame)
        cell.selectedBackgroundView?.backgroundColor = Constant.TableCellSelectedColor
        cell.accessoryType = .DisclosureIndicator
        
        cell.textLabel?.text = serverList[indexPath.row]["host"]
        cell.textLabel?.textColor = UIColor.whiteColor()
        
        cell.detailTextLabel?.text = serverList[indexPath.row]["username"]
        cell.detailTextLabel?.textColor = RGB(190, 190, 190)
        
        cell.imageView?.image = UIImage(named: "ssh_server")
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            serverList.removeAtIndex(indexPath.row)
            do {
                try serverPlist.saveToPlistFile(serverList)
            } catch {}
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let terminal = SSHTerminalViewController()
        terminal.server = serverList[indexPath.row]
        navigationController?.pushViewController(terminal, animated: true)
    }
}
