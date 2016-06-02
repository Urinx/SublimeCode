//
//  GoBoard.swift
//  Sublime
//
//  Created by Eular on 4/14/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import UIKit

class GoBoardView: UIView {
    
    let padding: CGFloat = 10
    var dimension: Int
    var gridWidth: CGFloat
    var stoneWidth: CGFloat = 9
    var isEnd: Bool = false
    let board: GoBoardModel
    
    init(board: GoBoardModel, gridWidth: CGFloat) {
        self.gridWidth = gridWidth
        self.board = board
        self.dimension = board.dimension
        
        let width = gridWidth * (dimension - 1) + 2 * padding
        super.init(frame: CGRectMake(0, 0, width, width))
        self.backgroundColor = UIColor.clearColor()
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.grayColor().CGColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        let d = dimension
        for i in 0..<d {
            drawLine((i, 0), (i, d - 1)) // col
            drawLine((0, i), (d - 1, i)) // row
        }
        
        for i in 0..<d {
            for j in 0..<d {
                let s = board[i,j]
                if s.type != .Void { drawStone(i, j, CGFloat(s.value - 1)) }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        if !isEnd {
            if let touch = touches.first {
                let location = touch.locationInView(self)
                let x = Int(round((location.x - padding) / gridWidth))
                let y = Int(round((location.y - padding) / gridWidth))
                onStoneDropDown(x, y)
            }
        }
    }
    
    func onStoneDropDown(x: Int, _ y: Int) {
        print("Stone: [\(x), \(y)]")
    }
    
    private func drawStone(x: Int, _ y: Int, _ c: CGFloat) {
        let g = gridWidth
        let r = stoneWidth
        let pos = (g * x + padding, g * y + padding)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextAddArc(context, pos.0, pos.1, r - c / 2, 0, 3.1415926*2, 0)
        CGContextSetRGBFillColor(context, c, c, c, 1)
        CGContextFillPath(context)
    }
    
    private func drawLine(p1: (Int, Int), _ p2: (Int, Int)) {
        let g = gridWidth
        let context = UIGraphicsGetCurrentContext()
        CGContextMoveToPoint(context, g * p1.0 + padding, g * p1.1 + padding)
        CGContextAddLineToPoint(context, g * p2.0 + padding, g * p2.1 + padding)
        CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 1)
        CGContextStrokePath(context)
    }
    
    func reset() {
        isEnd = false
        board.reset()
        setNeedsDisplay()
    }
}

class GomokuBoardView: GoBoardView {
    let depth = 1 // 目前只能用 1 层，2 的计算量太大，耗时太长，有待后续优化
    let AI: GomokuAI
    var onWin: (() -> Void)?
    var onLose: (() -> Void)?
    
    init() {
        let gomokuBoard = GomokuBoardModel()
        self.AI = GomokuAI(board: gomokuBoard)
        super.init(board: gomokuBoard, gridWidth: 20)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func onStoneDropDown(x: Int, _ y: Int) {
        if board[x,y].type == .Void {
            // 黑棋落子
            board[x,y].type = .Black
            setNeedsDisplay()
            
            // 检查输赢
            let r = board.check()
            if r == .Win {
                isEnd = true
                onWin?()
            } else {
                let queue = dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)
                
                dispatch_async(queue) {
                    
                    let AIMove = self.AI.search(2, depth: self.depth)
                    self.board[AIMove[1], AIMove[2]].type = .White
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.setNeedsDisplay()
                        // 再次检查输赢
                        if self.board.check() == .Lose {
                            self.isEnd = true
                            self.onLose?()
                        }
                    }
                }
                
            }
        }
    }
}