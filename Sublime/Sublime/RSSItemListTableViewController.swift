//
//  RSSItemListTableViewController.swift
//  Sublime
//
//  Created by Eular on 4/7/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireRSSParser
import AASquaresLoading

class RSSItemListTableViewController: UITableViewController {
    
    var rssUrl = ""
    var itemList: [RSSItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = Constant.CapeCod
        tableView.separatorColor = Constant.TableCellSeparatorColor
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableViewAutomaticDimension
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "0", style: .Plain, target: self, action: nil)
        
        if Network.isConnectedToNetwork() {
            let loadingSquare = AASquaresLoading(target: self.view, size: 40)
            loadingSquare.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
            loadingSquare.color = UIColor.whiteColor()
            loadingSquare.start()
            tableView.scrollEnabled = false
            
            Alamofire.request(.GET, rssUrl).responseRSS() { (response) -> Void in
                if let feed: RSSFeed = response.result.value {
                    self.itemList = feed.items
                    self.navigationItem.rightBarButtonItem?.title = "\(feed.items.count)"
                    loadingSquare.stop()
                    self.tableView.scrollEnabled = true
                    self.tableView.reloadData()
                }
            }
        } else {
            view.Toast(message: "No network", hasNavigationBar: true)
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        cell.backgroundColor = Constant.NavigationBarAndTabBarColor
        cell.selectedBackgroundView = UIView(frame: cell.frame)
        cell.selectedBackgroundView?.backgroundColor = Constant.TableCellSelectedColor
        cell.accessoryType = .DisclosureIndicator
        
        cell.textLabel?.text = itemList[indexPath.row].title
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .ByWordWrapping
        cell.detailTextLabel?.text = itemList[indexPath.row].itemDescription?.trim(charSet: .whitespaceAndNewlineCharacterSet())
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.textColor = UIColor.grayColor()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let backItem = UIBarButtonItem()
        backItem.title = "back"
        navigationItem.backBarButtonItem = backItem
        
        let svc = SublimeSafari(URL: NSURL(string: itemList[indexPath.row].link!)!)
        svc.title = title
        navigationController?.pushViewController(svc, animated: true)
    }

}
