//
//  ConfigTableViewController.swift
//  Sublime
//
//  Created by Eular on 4/7/16.
//  Copyright © 2016 Eular. All rights reserved.
//

class ConfigTableViewController: UITableViewController {
    
    @IBOutlet weak var cycriptLabel: UILabel!
    @IBOutlet weak var cycriptSwitch: UISwitch!
    @IBOutlet weak var codeReadingSwitch: UISwitch!
    @IBOutlet weak var showHiddenFilesSwitch: UISwitch!
    
    let secTitle = ["   Debug", "   System"]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
        
        if Network.isConnectedToNetwork() {
            let ip = Network.getIFAddresses()[0]
            cycriptLabel.text = "\(ip):8888"
        }
        
        cycriptSwitch.on = Config.CycriptStartListen
        codeReadingSwitch.on = Config.FullScreenCodeReadingMode
        showHiddenFilesSwitch.on = Config.ShowHiddenFiles
        
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = UILabel(frame: CGRectMake(0, 0, view.width, Constant.FilesTableSectionHight))
        title.backgroundColor = Constant.CapeCod
        title.text = secTitle[section]
        title.textColor = UIColor.whiteColor()
        title.font = title.font.fontWithSize(12)
        title.textAlignment = .Natural
        let headerView = UIView()
        headerView.addSubview(title)
        return headerView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constant.FilesTableSectionHight
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    @IBAction func cycriptChangeStatus(sender: UISwitch) {
        Config.CycriptStartListen = sender.on
        if sender.on {
            CYListenServer(8888)
        } else {
            view.Toast(message: "Restart the app to stop Cycript")
        }
    }
    
    @IBAction func codeReadingChangeStatus(sender: UISwitch) {
        Config.FullScreenCodeReadingMode = sender.on
    }
    
    @IBAction func showHiddenChangeStatus(sender: UISwitch) {
        Config.ShowHiddenFiles = sender.on
    }
    
}
