//
//  SettingTableViewController.swift
//  Sublime
//
//  Created by Eular on 2/23/16.
//  Copyright © 2016 Eular. All rights reserved.
//

class SettingTableViewController: UITableViewController {
    
    let secTitle = ["   General", "   Other", "   About"]

    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        switch (indexPath.section, indexPath.row) {
        case (1,0):
            let rvc = ReadingViewController()
            rvc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(rvc, animated: true)
        case (1,1):
            let svc = StorageViewController()
            svc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(svc, animated: true)
        case (2,0):
            let avc = AppInfoViewController()
            avc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(avc, animated: true)
        case (2,1):
            let dvc = DonateViewController()
            dvc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(dvc, animated: true)
        case (2,2):
            let lvc = LicenseTableViewController()
            lvc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(lvc, animated: true)
        default: return
        }
    }
}
