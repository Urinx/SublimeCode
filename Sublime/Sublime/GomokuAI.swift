//
//  GoAI.swift
//  Sublime
//
//  Created by Eular on 4/15/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation

/*
 The origin gomoku AI algorithm codes is writen by Linwei in python,
 here is the project: https://github.com/skywind3000/gobang .
 And I rewrite in Swift for my game ^_^
*/

// 棋盘评估类，给当前棋盘打分用
class GomokuEvaluation {
    let Dimension = 15
    let STWO = 1		// 冲二
    let STHREE = 2		// 冲三
    let SFOUR = 3		// 冲四
    let TWO = 4         // 活二
    let THREE = 5		// 活三
    let FOUR = 6		// 活四
    let FIVE = 7        // 活五
    let DFOUR = 8		// 双四
    let FOURT = 9		// 四三
    let DTHREE = 10     // 双三
    let NOTYPE = 11
    let ANALYSED = 255	// 已经分析过
    let TODO = 0		// 没有分析过
    let POS = [
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
        [0, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 0],
        [0, 1, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 1, 0],
        [0, 1, 2, 3, 4, 4, 4, 4, 4, 4, 4, 3, 2, 1, 0],
        [0, 1, 2, 3, 4, 5, 5, 5, 5, 5, 4, 3, 2, 1, 0],
        [0, 1, 2, 3, 4, 5, 6, 6, 6, 5, 4, 3, 2, 1, 0],
        [0, 1, 2, 3, 4, 5, 6, 7, 6, 5, 4, 3, 2, 1, 0],
        [0, 1, 2, 3, 4, 5, 6, 6, 6, 5, 4, 3, 2, 1, 0],
        [0, 1, 2, 3, 4, 5, 5, 5, 5, 5, 4, 3, 2, 1, 0],
        [0, 1, 2, 3, 4, 4, 4, 4, 4, 4, 4, 3, 2, 1, 0],
        [0, 1, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 1, 0],
        [0, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 0],
        [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    ]
    var RESULT = Array(count: 30, repeatedValue: 0) // 保存当前直线分析值
    var LINE = Array(count: 30, repeatedValue: 0) // 当前直线数据
    // 全盘分析结果 [row][col][方向]
    var RECORD = Array(count: 15, repeatedValue: Array(count: 15, repeatedValue: Array(count: 4, repeatedValue: 0)))
    // 每种棋局的个数：count[黑棋/白棋][模式]
    var COUNT = Array(count: 3, repeatedValue: Array(count: 20, repeatedValue: 0))
    
    init() {
        reset()
    }
    
    // 复位数据
    func reset() {
        RECORD = Array(count: Dimension, repeatedValue: Array(count: Dimension, repeatedValue: Array(count: 4, repeatedValue: TODO)))
        COUNT = Array(count: 3, repeatedValue: Array(count: 20, repeatedValue: 0))
    }
    
    // 四个方向（水平，垂直，左斜，右斜）分析评估棋盘，然后根据分析结果打分
    func evaluate(board: GomokuBoardModel, _ turn: Int) -> Int {
        var score = _evaluate(board, turn)
        if score < -9000 {
            for i in range(20) {
                let stone = turn == 1 ? 2:1
                if COUNT[stone][i] > 0 {
                    score -= i
                }
            }
        } else if score > 9000 {
            for i in range(20) {
                if COUNT[turn][i] > 0 {
                    score += i
                }
            }
        }
        return score
    }
    
    // 四个方向（水平，垂直，左斜，右斜）分析评估棋盘，然后根据分析结果打分
    private func _evaluate(board: GomokuBoardModel, _ turn: Int) -> Int {
        reset()
        // 四个方向分析
        for i in range(Dimension) {
            for j in range(Dimension) {
                if board[i,j].type != .Void {
                    if RECORD[i][j][0] == TODO { // 水平没有分析过?
                        _analysis_horizon(board, i, j)
                    }
                    
                    if RECORD[i][j][1] == TODO { // 垂直没有分析过?
                        _analysis_vertical(board, i, j)
                    }
                    
                    if RECORD[i][j][2] == TODO { // 左斜没有分析过?
                        _analysis_left(board, i, j)
                    }
                    
                    if RECORD[i][j][3] == TODO { // 右斜没有分析过?
                        _analysis_right(board, i, j)
                    }
                }
            }
        }
        
        // 分别对白棋黑棋计算：FIVE, FOUR, THREE, TWO等出现的次数
        let check = [FIVE, FOUR, SFOUR, THREE, STHREE, TWO, STWO]
        for i in range(Dimension) {
            for j in range(Dimension) {
                let stone = board[i,j]
                if stone.type != .Void {
                    for k in range(4) {
                        let ch = RECORD[i][j][k]
                        if check.indexOf(ch) != nil {
                            COUNT[stone.value][ch] += 1
                        }
                    }
                }
            }
        }
        
        // 如果有五连则马上返回分数
        let BLACK = 1
        let WHITE = 2
        if turn == WHITE { // 当前是白棋
            if COUNT[BLACK][FIVE] > 0 { return -9999 }
            if COUNT[WHITE][FIVE] > 0 { return 9999 }
        } else { // 当前是黑棋
            if COUNT[WHITE][FIVE] > 0 { return -9999 }
            if COUNT[BLACK][FIVE] > 0 { return 9999 }
        }
        
        // 如果存在两个冲四，则相当于有一个活四
        if COUNT[WHITE][SFOUR] >= 2 {
            COUNT[WHITE][FOUR] += 1
        }
        if COUNT[BLACK][SFOUR] >= 2 {
            COUNT[BLACK][FOUR] += 1
        }
        
        // 具体打分
        var wvalue = 0
        var bvalue = 0
        if turn == WHITE {
            if COUNT[WHITE][FOUR] > 0 { return 9990 }
            if COUNT[WHITE][SFOUR] > 0 { return 9980 }
            if COUNT[BLACK][FOUR] > 0 { return -9970 }
            if COUNT[BLACK][SFOUR] > 0 && COUNT[BLACK][THREE] > 0 { return -9960 }
            if COUNT[WHITE][THREE] > 0 && COUNT[BLACK][SFOUR] == 0 { return 9950 }
            if	COUNT[BLACK][THREE] > 1 && COUNT[WHITE][SFOUR] == 0 && COUNT[WHITE][THREE] == 0 && COUNT[WHITE][STHREE] == 0 { return -9940 }
            
            if COUNT[WHITE][THREE] > 1 { wvalue += 2000 }
            else if COUNT[WHITE][THREE] > 0 { wvalue += 200 }
            if COUNT[BLACK][THREE] > 1 { bvalue += 500 }
            else if COUNT[BLACK][THREE] > 0 { bvalue += 100 }
            
            if COUNT[WHITE][STHREE] > 0 { wvalue += COUNT[WHITE][STHREE] * 10 }
            if COUNT[BLACK][STHREE] > 0 { bvalue += COUNT[BLACK][STHREE] * 10 }
            if COUNT[WHITE][TWO] > 0 { wvalue += COUNT[WHITE][TWO] * 4 }
            if COUNT[BLACK][TWO] > 0 { bvalue += COUNT[BLACK][TWO] * 4 }
            if COUNT[WHITE][STWO] > 0 { wvalue += COUNT[WHITE][STWO] }
            if COUNT[BLACK][STWO] > 0 { bvalue += COUNT[BLACK][STWO] }
        } else {
            if COUNT[BLACK][FOUR] > 0 { return 9990 }
            if COUNT[BLACK][SFOUR] > 0 { return 9980 }
            if COUNT[WHITE][FOUR] > 0 { return -9970 }
            if COUNT[WHITE][SFOUR] > 0 && COUNT[WHITE][THREE] > 0 { return -9960 }
            if COUNT[BLACK][THREE] > 0 && COUNT[WHITE][SFOUR] == 0 { return 9950 }
            if	COUNT[WHITE][THREE] > 1 && COUNT[BLACK][SFOUR] == 0 && COUNT[BLACK][THREE] == 0 && COUNT[BLACK][STHREE] == 0 { return -9940 }
            
            if COUNT[BLACK][THREE] > 1 { bvalue += 2000 }
            else if COUNT[BLACK][THREE] > 0 { bvalue += 200 }
            if COUNT[WHITE][THREE] > 1 { wvalue += 500 }
            else if COUNT[WHITE][THREE] > 0 { wvalue += 100 }
            
            if COUNT[BLACK][STHREE] > 0 { bvalue += COUNT[BLACK][STHREE] * 10 }
            if COUNT[WHITE][STHREE] > 0 { wvalue += COUNT[WHITE][STHREE] * 10 }
            if COUNT[BLACK][TWO] > 0 { bvalue += COUNT[BLACK][TWO] * 4 }
            if COUNT[WHITE][TWO] > 0 { wvalue += COUNT[WHITE][TWO] * 4 }
            if COUNT[BLACK][STWO] > 0 { bvalue += COUNT[BLACK][STWO] }
            if COUNT[WHITE][STWO] > 0 { wvalue += COUNT[WHITE][STWO] }
        }
        
        // 加上位置权值，棋盘最中心点权值是7，往外一格-1，最外圈是0
        var wc = 0
        var bc = 0
        for i in  range(Dimension) {
            for j in range(Dimension) {
                let stone = board[i,j]
                if stone.type != .Void {
                    if stone.type == .White {
                        wc += POS[i][j]
                    } else {
                        bc += POS[i][j]
                    }
                }
            }
        }
        wvalue += wc
        bvalue += bc
        
        if turn == WHITE {
            return wvalue - bvalue
        }
        return bvalue - wvalue
    }
    
    // 分析横向
    private func _analysis_horizon(board: GomokuBoardModel, _ i: Int, _ j: Int) -> Int {
        for x in range(Dimension) {
            LINE[x] = board[i,x].value
        }
        analysis_line(Dimension, j)
        for x in range(Dimension) {
            if RESULT[x] != TODO {
                RECORD[i][x][0] = RESULT[x]
            }
        }
        return RECORD[i][j][0]
    }
    
    // 分析纵向
    private func _analysis_vertical(board: GomokuBoardModel, _ i: Int, _ j: Int) -> Int {
        for x in range(Dimension) {
            LINE[x] = board[x,j].value
        }
        analysis_line(Dimension, i)
        for x in range(Dimension) {
            if RESULT[x] != TODO {
                RECORD[x][j][1] = RESULT[x]
            }
        }
        return RECORD[i][j][1]
    }
    
    // 分析左斜
    private func _analysis_left(board: GomokuBoardModel, _ i: Int, _ j: Int) -> Int {
        var x: Int
        var y: Int
        if i < j {
            x = j - i
            y = 0
        } else {
            x = 0
            y = i - j
        }
        var k = 0
        while k < 15 {
            if x + k > 14 || y + k > 14 { break }
            LINE[k] = board[y+k, x+k].value
            k += 1
        }
        analysis_line(k, j - x)
        for s in range(k) {
            if RESULT[s] != TODO {
                RECORD[y + s][x + s][2] = RESULT[s]
            }
        }
        return RECORD[i][j][2]
    }
    
    // 分析右斜
    private func _analysis_right(board: GomokuBoardModel, _ i: Int, _ j: Int) -> Int {
        var x: Int
        var y: Int
        if 14 - i < j {
            x = j - 14 + i
            y = 14
        } else {
            x = 0
            y = i + j
        }
        var k = 0
        while k < 15 {
            if x + k > 14 || y - k < 0 { break }
            LINE[k] = board[y - k, x + k].value
            k += 1
        }
        analysis_line(k, j - x)
        for s in  range(k) {
            if RESULT[s] != TODO {
                RECORD[y - s][x + s][3] = RESULT[s]
            }
        }
        return RECORD[i][j][3]
    }
    
    // 分析一条线：五四三二等棋型
    private func analysis_line(num: Int, _ pos: Int) -> Int{
        for i in range(num, 30) {
            LINE[i] = 0xf
        }
        for i in range(num) {
            RESULT[i] = TODO
        }
        
        if num < 5 {
            for i in range(num) {
                RESULT[i] = ANALYSED
            }
            return 0
        }
        
        let stone = LINE[pos] <= 2 ? LINE[pos]:0
        let inverse = [0, 2, 1][stone]
        
        var xl = pos
        var xr = pos
        while xl > 0 { // 探索左边界
            if LINE[xl - 1] != stone { break }
            xl -= 1
        }
        
        while xr < num - 1 { // 探索右边界
            if LINE[xr + 1] != stone { break }
            xr += 1
        }
        
        var left_range = xl
        var right_range = xr
        while left_range > 0 { // 探索左边范围（非对方棋子的格子坐标）
            if LINE[left_range - 1] == inverse { break }
            left_range -= 1
        }
        while right_range < num - 1 { // 探索右边范围（非对方棋子的格子坐标）
            if LINE[right_range + 1] == inverse { break }
            right_range += 1
        }
        
        // 如果该直线范围小于 5，则直接返回
        if right_range - left_range < 4 {
            for k in range(left_range, right_range + 1) {
                RESULT[k] = ANALYSED
            }
            return 0
        }
        
        // 设置已经分析过
        for k in range(xl, xr + 1) {
            RESULT[k] = ANALYSED
        }
        
        let srange = xr - xl
        // 如果是 5连
        if srange >= 4 {
            RESULT[pos] = FIVE
            return FIVE
        }
        // 如果是 4连
        if srange == 3 {
            var leftfour = false	// 是否左边是空格
            if xl > 0 {
                if LINE[xl - 1] == 0 {		// 活四
                    leftfour = true
                }
            }
            if xr < num - 1 {
                if LINE[xr + 1] == 0 {
                    if leftfour {
                        RESULT[pos] = FOUR	// 活四
                    } else {
                        RESULT[pos] = SFOUR	// 冲四
                    }
                } else {
                    if leftfour {
                        RESULT[pos] = SFOUR	// 冲四
                    }
                }
            } else {
                if leftfour {
                    RESULT[pos] = SFOUR     // 冲四
                }
            }
            return RESULT[pos]
        }
        // 如果是 3连
        if srange == 2 { // 三连
            var left3 = false	// 是否左边是空格
            if xl > 0 {
                if LINE[xl - 1] == 0 {	// 左边有气
                    if xl > 1 && LINE[xl - 2] == stone {
                        RESULT[xl] = SFOUR
                        RESULT[xl - 2] = ANALYSED
                    } else {
                        left3 = true
                    }
                } else if xr == num - 1 || LINE[xr + 1] != 0 {
                    return 0
                }
            }
            if xr < num - 1 {
                if LINE[xr + 1] == 0 {	// 右边有气
                    if xr < num - 2 && LINE[xr + 2] == stone {
                        RESULT[xr] = SFOUR	// XXX-X 相当于冲四
                        RESULT[xr + 2] = ANALYSED
                    } else if left3 {
                        RESULT[xr] = THREE
                    } else {
                        RESULT[xr] = STHREE
                    }
                }
            }
            else {
                if RESULT[xl] == SFOUR {
                    return RESULT[xl]
                }
                if left3 {
                    RESULT[pos] = STHREE
                }
            }
            return RESULT[pos]
        }
        // 如果是 2连
        if srange == 1 {
            var left2 = false
            if xl > 2 {
                if LINE[xl - 1] == 0 {		// 左边有气
                    if LINE[xl - 2] == stone {
                        if LINE[xl - 3] == stone {
                            RESULT[xl - 3] = ANALYSED
                            RESULT[xl - 2] = ANALYSED
                            RESULT[xl] = SFOUR
                        } else if LINE[xl - 3] == 0 {
                            RESULT[xl - 2] = ANALYSED
                            RESULT[xl] = STHREE
                        }
                    } else {
                        left2 = true
                    }
                }
            }
            if xr < num - 1 {
                if LINE[xr + 1] == 0 {	// 左边有气
                    if xr < num - 3 && LINE[xr + 2] == stone {
                        if LINE[xr + 3] == stone {
                            RESULT[xr + 3] = ANALYSED
                            RESULT[xr + 2] = ANALYSED
                            RESULT[xr] = SFOUR
                        } else if LINE[xr + 3] == 0 {
                            RESULT[xr + 2] = ANALYSED
                            RESULT[xr] = left2 ? THREE : STHREE
                        }
                    } else {
                        if RESULT[xl] == SFOUR {
                            return RESULT[xl]
                        }
                        if RESULT[xl] == STHREE {
                            RESULT[xl] = THREE
                            return RESULT[xl]
                        }
                        if left2 {
                            RESULT[pos] = TWO
                        }
                        else {
                            RESULT[pos] = STWO
                        }
                    }
                } else {
                    if RESULT[xl] == SFOUR {
                        return RESULT[xl]
                    }
                    if left2 {
                        RESULT[pos] = STWO
                    }
                }
            }
            return RESULT[pos]
        }
        return 0
    }
    
}

// DFS: 博弈树搜索
class GomokuAI {
    let evaluator = GomokuEvaluation()
    var maxdepth = 3
    var bestMove = [Int]()
    var dimension = 15
    private var board: GomokuBoardModel
    
    init(board: GomokuBoardModel) {
        self.board = board
        self.dimension = board.dimension
    }
    
    // 产生当前棋局的走法
    private func genmove(turn: Int) -> Array<Array<Int>> {
        var moves = Array<Array<Int>>()
        let POSES = evaluator.POS
        for i in range(dimension) {
            for j in range(dimension) {
                if board[i,j].type == .Void {
                    let score = POSES[i][j]
                    moves.append([score, i, j])
                }
            }
        }
        moves = moves.sort() { $0[0] > $1[0] }
        return moves
    }
    
    // 递归搜索：返回最佳分数
    private func _search (turn: Int, _ depth: Int, _ alpha: Int = -0x7fffffff, _ beta: Int = 0x7fffffff) -> Int {
        // 深度为零则评估棋盘并返回
        if depth <= 0 {
            let score = evaluator.evaluate(board, turn)
            return score
        }
        
        // 如果游戏结束则立马返回
        let s = evaluator.evaluate(board, turn)
        if abs(s) >= 9999 && depth < maxdepth {
            return s
        }
        
        // 产生新的走法
        let moves = genmove(turn)
        var bestmove = [Int]()
        
        // 枚举当前所有走法
        var a = alpha
        for m in moves {
            let row = m[1]
            let col = m[2]
        
            // 标记当前走法到棋盘
            board[row, col].value = turn
        
            // 计算下一回合该谁走
            let nturn = turn == 1 ? 2:1
            
            // 深度优先搜索，返回评分，走的行和走的列
            let score = -self._search(nturn, depth - 1, -beta, -alpha)
            
            // 棋盘上清除当前走法
            board[row, col].value = 0
            
            // 计算最好分值的走法
            // alpha/beta 剪枝
            if score > a {
                a = score
                bestmove = [row, col]
                if a >= beta { break }
            }
        }
        
        // 如果是第一层则记录最好的走法
        if depth == maxdepth && bestmove.count != 0 { self.bestMove = bestmove }
        
        // 返回当前最好的分数，和该分数的对应走法
        return a
    }
    
    // 具体搜索：传入当前是该谁走(turn=1黑/2白)，以及搜索深度(depth)
    func search(turn: Int, depth: Int = 3) -> [Int] {
        maxdepth = depth
        bestMove = []
        var score = _search(turn, depth)
        if abs(score) > 8000 {
            maxdepth = depth
            score = _search(turn, 1)
        }
        let row = bestMove[0]
        let col = bestMove[1]
        return [score, row, col]
    }
}
