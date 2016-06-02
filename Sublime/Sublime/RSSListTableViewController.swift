//
//  RSSListTableViewController.swift
//  Sublime
//
//  Created by Eular on 4/7/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import UIKit

class RSSListTableViewController: UITableViewController {
    
    let RSSPlist = Plist(path: Constant.SublimeRoot+"/etc/rss_list.plist")
    var RSSList: [[String: String]] = [] {
        didSet {
            do {
                try RSSPlist.saveToPlistFile(RSSList)
            } catch {
                view.Toast(message: "Save failed!", hasNavigationBar: true)
            }
            
            if RSSList.count > oldValue.count {
                tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "RSS"
        tableView.backgroundColor = Constant.CapeCod
        tableView.separatorColor = Constant.TableCellSeparatorColor
        tableView.tableFooterView = UIView()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(self.addNewRSS))
    }
    
    override func viewWillAppear(animated: Bool) {
        if let arr = RSSPlist.getArrayInPlistFile() {
            RSSList = arr as! [[String : String]]
            tableView.reloadData()
        }
    }
    
    func addNewRSS() {
        let alertController = UIAlertController(title: "New RSS", message: "Enter RSS info below", preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "RSS Title"
            textField.borderStyle = .None
            textField.textAlignment = .Center
        })
        alertController.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "RSS URL"
            textField.borderStyle = .None
            textField.textAlignment = .Center
        })
        
        let addAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.Default, handler: {
            (paramAction: UIAlertAction!) in
            if let textFields = alertController.textFields {
                let theTextFields = textFields as [UITextField]
                if let title = theTextFields[0].text, let url = theTextFields[1].text {
                    if !title.isEmpty && !url.isEmpty {
                        self.RSSList.append(["title": title, "rss": url])
                    } else {
                        self.view.Toast(message: "RSS title or url can't be empty!", hasNavigationBar: true)
                    }
                }
            }
        })
        
        alertController.addAction(addAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RSSList.count
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            RSSList.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        cell.backgroundColor = Constant.NavigationBarAndTabBarColor
        cell.selectedBackgroundView = UIView(frame: cell.frame)
        cell.selectedBackgroundView?.backgroundColor = Constant.TableCellSelectedColor
        cell.accessoryType = .DisclosureIndicator
        
        cell.textLabel?.text = RSSList[indexPath.row]["title"]
        cell.detailTextLabel?.text = RSSList[indexPath.row]["rss"]
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.textColor = UIColor.grayColor()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let rssItemList = RSSItemListTableViewController()
        rssItemList.title = RSSList[indexPath.row]["title"]
        rssItemList.rssUrl = RSSList[indexPath.row]["rss"]!
        navigationController?.pushViewController(rssItemList, animated: true)
    }

}
