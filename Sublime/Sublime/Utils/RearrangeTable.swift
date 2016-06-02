//
//  RearrangeTable.swift
//  Sublime
//
//  Created by Eular on 5/3/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation

protocol RearrangeTableViewDelegate {
    func rearrangeTableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath)
//    override func rearrangeTableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
//        let temp = fileList[toIndexPath.row]
//        fileList[toIndexPath.row] = fileList[fromIndexPath.row]
//        fileList[fromIndexPath.row] = temp
//        tableView.moveRowAtIndexPath(fromIndexPath, toIndexPath: toIndexPath)
//    }
}

class RearrangeTableViewController: UITableViewController {
    
    private var sourceIndexPath: NSIndexPath?
    private var snapView: UIView?
    var delegate: RearrangeTableViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:))))
    }
    
    private func snapView(view: UIView) -> UIImageView {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let snapShot = UIImageView(image: image)
        snapShot.layer.masksToBounds = false;
        snapShot.layer.cornerRadius = 0;
        snapShot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
        snapShot.layer.shadowOpacity = 0.4;
        snapShot.layer.shadowRadius = 5;
        snapShot.frame = view.frame
        return snapShot
    }
    
    func handleLongPress(longPress: UILongPressGestureRecognizer) {
        let point = longPress.locationInView(tableView)
        
        if let indexPath = tableView.indexPathForRowAtPoint(point) {
            switch longPress.state {
            case .Began:
                if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                    sourceIndexPath = indexPath
                    let snapView = self.snapView(cell)
                    snapView.alpha = 0
                    self.snapView = snapView
                    tableView.addSubview(snapView)
                    
                    UIView.animateWithDuration(0.25, animations: {
                        // 选中Cell跳出放大效果
                        snapView.alpha = 0.95
                        snapView.center = CGPointMake(cell.center.x, point.y)
                        snapView.transform = CGAffineTransformMakeScale(1.05, 1.05)
                        
                        cell.alpha = 0
                        }, completion: { (_) -> Void in
                            cell.hidden = true
                            cell.alpha = 1
                    })
                } else {
                    sourceIndexPath = nil
                    snapView = nil
                }
            case .Changed:
                if let snapView = snapView {
                    // 截图随手指上下移动
                    snapView.center = CGPointMake(snapView.center.x, point.y)
                }
                
                // 如果手指移动到一个新的Cell上面，隐藏Cell跟此Cell交换位置
                if let fromIndexPath = sourceIndexPath {
                    if fromIndexPath != indexPath {
                        tableView.beginUpdates()
                        
                        delegate?.rearrangeTableView(tableView, moveRowAtIndexPath: fromIndexPath, toIndexPath: indexPath)
                        
                        tableView.endUpdates()
                        sourceIndexPath = indexPath
                    }
                }
                
                // 手指移动到屏幕顶端或底部，UITableView自动滚动
                let step: CGFloat = 64
                if let parentView = tableView.superview {
                    let parentPos = tableView.convertPoint(point, toView: parentView)
                    if parentPos.y > parentView.bounds.height - step {
                        var offset = tableView.contentOffset
                        offset.y += (parentPos.y - parentView.bounds.height + step)
                        if offset.y > tableView.contentSize.height - tableView.bounds.height {
                            offset.y = tableView.contentSize.height - tableView.bounds.height
                        }
                        tableView.setContentOffset(offset, animated: false)
                    } else if parentPos.y <= step {
                        var offset = tableView.contentOffset
                        offset.y -= (step - parentPos.y)
                        if offset.y < 0 {
                            offset.y = 0
                        }
                        tableView.setContentOffset(offset, animated: false)
                    }
                }
            default:
                if let snapView = snapView, let fromIndexPath = sourceIndexPath, let cell = tableView.cellForRowAtIndexPath(fromIndexPath) {
                    cell.alpha = 0
                    cell.hidden = false
                    
                    // 长按移动结束，隐藏的Cell恢复显示，删除截图
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        snapView.center = cell.center
                        snapView.alpha = 0
                        cell.alpha = 1
                        }, completion: { [unowned self] (_) -> Void in
                            snapView.removeFromSuperview()
                            self.snapView = nil
                            self.sourceIndexPath = nil
                            self.tableView.performSelector(#selector(UITableView.reloadData), withObject: nil, afterDelay: 0.5)
                        })
                }
            }
        }
    }

}