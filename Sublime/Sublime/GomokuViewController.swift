//
//  GameOfGoViewController.swift
//  Sublime
//
//  Created by Eular on 4/14/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import UIKit

class GomokuViewController: UIViewController {
    
    let board = GomokuBoardView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constant.CapeCod
        
        board.onWin = {
            self.view.Toast(message: "黑棋赢")
        }
        board.onLose = {
            self.view.Toast(message: "白棋赢")
        }
        view.addSubview(board)
        board.atCenter()
        
        addCloseBtn()
        addNewBtn()
    }
    
    func close() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addCloseBtn() {
        let closeBtn = UIButton()
        closeBtn.setTitle("<-", forState: .Normal)
        closeBtn.setTitleColor(UIColor.grayColor(), forState: .Normal)
        closeBtn.frame = CGRectMake(10, view.height - 20, 20, 10)
        closeBtn.addTarget(self, action: #selector(self.close), forControlEvents: .TouchUpInside)
        view.addSubview(closeBtn)
    }
    
    func addNewBtn() {
        let newBtn = UIButton()
        newBtn.setTitle("new", forState: .Normal)
        newBtn.setTitleColor(UIColor.grayColor(), forState: .Normal)
        newBtn.titleLabel?.font = newBtn.titleLabel?.font.fontWithSize(13)
        newBtn.frame = CGRectMake(view.width - 40, view.height - 22, 30, 15)
        newBtn.addTarget(self, action: #selector(board.reset), forControlEvents: .TouchUpInside)
        view.addSubview(newBtn)
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}
