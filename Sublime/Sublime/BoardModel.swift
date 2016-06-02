//
//  GoBoardModel.swift
//  Sublime
//
//  Created by Eular on 4/15/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation

struct Stone {
    enum StoneType: Int {
        case White = 2
        case Black = 1
        case Void = 0
    }
    
    var type: StoneType
    var value: Int {
        get {
            return type.rawValue
        }
        set {
            switch newValue {
            case 2:
                type = .White
            case 1:
                type = .Black
            default:
                type = .Void
            }
        }
    }
    
    init() {
        self.type = .Void
    }
    
    init(type: StoneType) {
        self.type = type
    }
}


class GoBoardModel {
    
    enum GameResult {
        case Win
        case Lose
        case None
    }
    
    let dimension: Int
    var winStone: [(Int, Int)] = []
    
    private var board: Array<Array<Stone>>
    
    init(dimension d: Int) {
        dimension = d
        board = Array(count: d, repeatedValue: Array(count: d, repeatedValue: Stone()))
        reset()
    }
    
    // 清空棋盘
    func reset() {
        for i in range(dimension) {
            for j in range(dimension) {
                board[i][j] = Stone()
            }
        }
    }
    
    // 判断输赢
    func check() -> GameResult {
        // 四个方向遍历: 右，右上，右下，下
        let dirs = [(1, 0), (1, -1), (1, 1), (0, 1)]
        
        for i in range(dimension) {
            for j in range(dimension) {
                
                let t = self[i,j].type
                if t == .Void { continue }
                
                for d in dirs {
                    var x = i
                    var y = j
                    var count = 0
                    
                    for _ in range(5) {
                        if self[x,y].type != t {
                            winStone = []
                            break
                        }
                        winStone.append((x,y))
                        x += d.0
                        y += d.1
                        count += 1
                    }
                    
                    if count == 5 {
                        if t == .Black {
                            return .Win
                        }
                        if t == .White {
                            return .Lose
                        }
                    }
                }
                
            }
        }
        
        return .None
    }
    
    // 输出棋盘
    func log() {
        print("-" * (2 * dimension + 3))
        for i in range(dimension) {
            let symbol = [".", "x", "o"]
            var row = [String]()
            for j in range(dimension) {
                row.append(symbol[board[j][i].value])
            }
            print("| " + " ".join(row) + " |")
        }
        print("-" * (2 * dimension + 3))
    }
    
    // 索引
    subscript(row: Int, column: Int) -> Stone {
        get {
            if row < 0 || row >= 15 || column < 0 || column >= 15 {
                return Stone()
            }
            return board[row][column]
        }
        set {
            board[row][column] = newValue
        }
    }
    
    subscript(row: Int) -> Array<Stone> {
        get {
            return board[row]
        }
        set {
            board[row] = newValue
        }
    }
}

class GomokuBoardModel: GoBoardModel {
    init() {
        super.init(dimension: 15)
    }
}
