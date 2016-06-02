//
//  FolderTableViewController.swift
//  Sublime
//
//  Created by Eular on 2/14/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import UIKit

class FolderTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ActionSheetDelegate {
    
    var curFolder: Folder = Folder(path: NSHomeDirectory()+"/Documents")
    var mainViewFlag: Int = 1
    var fileList: [File] = []
    var actionSheet: ActionSheet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = curFolder.name
        tableView.backgroundColor = Constant.CapeCod
        tableView.separatorColor = Constant.TableCellSeparatorColor
        
        self.clearsSelectionOnViewWillAppear = true
        tableView.tintColor = UIColor.whiteColor()

        // Dropdown Menu
        actionSheet = ActionSheet(rowWidth: view.width, rowHight: 50)
        actionSheet.items = ["File", "Folder", "Image"]
        actionSheet.controller = self
        actionSheet.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: actionSheet, action: #selector(actionSheet.showUp))
    }
    
    override func viewWillAppear(animated: Bool) {
        updateFileListData()
    }
    
    override func viewDidAppear(animated: Bool) {
        updateFileListData()
    }
    
    func updateFileListData() {
        fileList = curFolder.listFiles()
        
        // 隐藏文件
        if !Config.ShowHiddenFiles {
            fileList = fileList.filter { !$0.name.hasPrefix(".") }
        }
        
        // 按目录在最上面规则排序
        fileList.sortInPlace {
            if $0.0.isDir && $0.1.isDir {
                return false
            } else {
                return $0.0.isDir
            }
        }
        
        tableView.reloadData()
    }
    
    func tapOnActionSheetItem(itemAtRow row: Int) {
        switch row {
        case 0, 1:
            let nvc = NewFileViewController()
            nvc.tag = row
            nvc.curFolder = curFolder
            navigationController?.pushViewController(nvc, animated: true)
        case 2:
            let imgPicker = UIImagePickerController()
            imgPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imgPicker.delegate = self
            self.presentViewController(imgPicker, animated: true, completion: nil)
        default: return
        }
    }
    
    // 保存图片
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info["UIImagePickerControllerOriginalImage"] as! UIImage
        let url = info["UIImagePickerControllerReferenceURL"] as! NSURL
        curFolder.saveImage(image, name: "IMG_\(random(1000)).\(url.pathExtension!.lower)", url: url)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        let f = fileList[indexPath.row]
        setFileTableCell(cell, name: f.name, imgname: f.img, isDir: f.isDir)
        return cell
    }
    
    func setFileTableCell(cell: UITableViewCell, name: String, imgname: String, isDir: Bool) {
        cell.backgroundColor = Constant.TableCellColor
        cell.selectedBackgroundView = UIView(frame: cell.frame)
        cell.selectedBackgroundView?.backgroundColor = Constant.TableCellSelectedColor
        
        cell.accessoryType = isDir ? .DisclosureIndicator : .None
        cell.textLabel?.text = name
        cell.textLabel?.textColor = UIColor.whiteColor()
        
        let img = UIImageView()
        img.frame = CGRectMake(14, 8, 28, 28)
        img.image = UIImage(named: imgname)
        cell.imageView?.contentMode = .ScaleAspectFit
        cell.addSubview(img)
        
        // 占位用
        cell.imageView?.image = UIImage(named: "tab_icon_files")
        cell.imageView?.hidden = true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.section + mainViewFlag {
            case 0:
                let gvc = GithubTableViewController()
                gvc.tag = indexPath.row
                gvc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(gvc, animated: true)
            case 1:
                let file = fileList[indexPath.row]
                if file.isDir {
                    let fvc = FolderTableViewController()
                    fvc.hidesBottomBarWhenPushed = true
                    fvc.curFolder = file as! Folder
                    navigationController?.pushViewController(fvc, animated: true)
                } else if file.isImg {
                    let ivc = ImagePageViewController()
                    let imgList = fileList.filter { $0.isImg }
                    ivc.index = (imgList as NSArray).indexOfObject(file)
                    ivc.imgList = imgList
                    ivc.hidesBottomBarWhenPushed = true
                    navigationController?.pushViewController(ivc, animated: true)
                } else if file.isAudio {
                    let mvc = MusicViewController()
                    mvc.curFile = file
                    mvc.hidesBottomBarWhenPushed = true
                    navigationController?.pushViewController(mvc, animated: true)
                } else if file.isVideo {
                    let vvc = VideoViewController()
                    vvc.curFile = file
                    vvc.hidesBottomBarWhenPushed = true
                    navigationController?.pushViewController(vvc, animated: true)
                } else if file.ext == "pdf" {
                    let pvc = PDFViewController()
                    pvc.curFile = file
                    pvc.hidesBottomBarWhenPushed = true
                    navigationController?.pushViewController(pvc, animated: true)
                } else if file.ext == "zip" {
                    //...
                } else {
                    let fvc = CodeViewController()
                    fvc.curFile = Code(path: file.path, language: file.codeLang)
                    fvc.hidesBottomBarWhenPushed = true
                    navigationController?.pushViewController(fvc, animated: true)
                }
            default: return
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section + mainViewFlag == 1
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let f = fileList.removeAtIndex(indexPath.row)
            f.delete()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }

}
