//
//  ImagePageViewController.swift
//  Sublime
//
//  Created by Eular on 2/15/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import UIKit

class ImagePageViewController: UIPageViewController, UIPageViewControllerDataSource, PopupMenuDelegate {

    let popupMenu = PopupMenu()
    var index: Int = 0
    var imgList: [File]!
    var curImage: UIImage?
    
    override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : AnyObject]?) {
        super.init(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: options)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        view.backgroundColor = Constant.CapeCod
        
        if let startingViewController = self.viewControllerByOffset(0) {
            setViewControllers([startingViewController], direction: .Forward, animated: true, completion: nil)
        }
        
        // 设置分享菜单
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: popupMenu, action: #selector(popupMenu.showUp))
        popupMenu.controller = self
        popupMenu.delegate = self
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        return viewControllerByOffset(1)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        return viewControllerByOffset(-1)
    }
    
    /* Page Control*/
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return imgList.count
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return index
    }
    
    func viewControllerByOffset(offset: Int) -> ImageFileViewController? {
        index += offset
        if index < 0 || index >= imgList.count {
            index -= offset
            return nil
        }
        title = imgList[index].name
        self.curImage = UIImage(contentsOfFile: imgList[index].path)
        popupMenu.itemsToShare = [self.curImage!]
        
        let imageView = ImageFileViewController()
        imageView.curFile = imgList[index]
        return imageView
    }
    
    func tapOnPopupMenuItem(itemIndex i: Int) {
        let curFile = imgList[index]
        switch i {
        case 2:
            if curFile.ext == "gif" {
                WXShareEmoticon(curFile.path)
            } else {
                WXShareImage(self.curImage!)
            }
        case 3:
            WXShareImage(self.curImage!, isTimeline: true)
        default: return
        }
    }

}
