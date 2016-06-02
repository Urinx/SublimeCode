//
//  LicenseTableViewController.swift
//  Sublime
//
//  Created by Eular on 2/24/16.
//  Copyright © 2016 Eular. All rights reserved.
//

class LicenseTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "License"
        tableView.backgroundColor = Constant.CapeCod
        tableView.separatorColor = Constant.CapeCod
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constant.License.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        cell.backgroundColor = Constant.TableCellColor
        cell.selectedBackgroundView = UIView(frame: cell.frame)
        cell.selectedBackgroundView?.backgroundColor = Constant.TableCellSelectedColor
        cell.accessoryType = .DisclosureIndicator
        
        cell.textLabel?.text = Constant.License[indexPath.row]
        cell.textLabel?.textColor = UIColor.whiteColor()

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let vc = UIViewController()
        vc.title = Constant.License[indexPath.row]
        vc.view.backgroundColor = Constant.CapeCod
        vc.automaticallyAdjustsScrollViewInsets = false
        let tv = UITextView()
        tv.frame = CGRectMake(0, 0, vc.view.width, vc.view.height - Constant.NavigationBarOffset)
        vc.view.addSubview(tv)
        tv.backgroundColor = Constant.CapeCod
        tv.textColor = UIColor.whiteColor()
        tv.editable = false
        tv.text = File(path: NSBundle.mainBundle().pathForResource(Constant.License[indexPath.row], ofType: "LICENSE")!).read()
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
