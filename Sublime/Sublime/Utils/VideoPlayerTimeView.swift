//
//  VideoPlayerTimeView.swift
//  Sublime
//
//  Created by Eular on 5/3/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation

class VideoPlayerTimeView: UIView {
    
    private let curTimeLabel = UILabel()
    private let totalTimeLabel = UILabel()
    private let curTimeLine = UILabel()
    private let totalTimeLine = UILabel()
    private var originY: CGFloat!
    
    var show: Bool = false {
        didSet {
            hidden = !show
            if show {
                UIView.animateWithDuration(0.5, animations: {
                    self.frame.origin.y -= self.frame.height
                    }, completion: { (_) -> Void in
                        UIView.animateWithDuration(5) {
                            self.alpha = 0
                        }
                })
            } else {
                self.frame.origin.y = originY
                self.alpha = 0.5
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.blackColor()
        alpha = 0.5
        hidden = true
        originY = frame.origin.y
        
        curTimeLabel.text = "00:00:00"
        totalTimeLabel.text = "00:00:00"
        
        curTimeLabel.frame = CGRectMake(0, 0, 100, frame.height)
        totalTimeLabel.frame = CGRectMake(frame.width - 100, 0, 100, frame.height)
        curTimeLine.frame = CGRectMake(100, 14, 0, 2)
        totalTimeLine.frame = CGRectMake(100, 14, frame.width - 200, 2)
        
        curTimeLabel.textAlignment = .Center
        totalTimeLabel.textAlignment = .Center
        
        curTimeLabel.textColor = UIColor.whiteColor()
        totalTimeLabel.textColor = UIColor.whiteColor()
        curTimeLine.backgroundColor = RGB(0, 175, 244)
        totalTimeLine.backgroundColor = UIColor.whiteColor()
        
        addSubview(curTimeLabel)
        addSubview(totalTimeLabel)
        addSubview(totalTimeLine)
        addSubview(curTimeLine)
    }
    
    func setTime(curTime: Double, totalTime: Double) {
        curTimeLabel.text = curTime.formatedTime("HH:mm:ss")
        totalTimeLabel.text = totalTime.formatedTime("HH:mm:ss")
        curTimeLine.frame.size.width = totalTimeLine.frame.width * CGFloat( curTime / totalTime )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}