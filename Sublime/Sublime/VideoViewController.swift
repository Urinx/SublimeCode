//
//  VideoViewController.swift
//  Sublime
//
//  Created by Eular on 2/19/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VideoViewController: UIViewController {
    
    let popupMenu = PopupMenu()
    
    var curFile: File!
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var isPlay: Bool {
        return player?.rate == 1.0
    }
    var isFullScreen: Bool = false {
        didSet {
            navigationController?.setNavigationBarHidden(isFullScreen, animated: true)
            tabBarController?.tabBar.hidden = isFullScreen
            playerTimeView.show = isFullScreen && !isPlay
        }
    }
    
    let pauseView = UIView()
    var pauseViewFrame: CGRect {
        if isFullScreen {
            return CGRectMake((view.width - 200) / 2, (view.height - 200) / 2, 200, 200)
        } else {
            return CGRectMake(0, (view.height - 200) / 2, view.width, 200)
        }
    }
    
    var playerTimeView: VideoPlayerTimeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constant.CapeCod
        title = curFile.name
        
        // 设置分享菜单
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: popupMenu, action: #selector(popupMenu.showUp))
        popupMenu.controller = self
        popupMenu.itemsToShare = [curFile.url]
        
        player = AVPlayer(URL: curFile.url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.frame
        playerLayer.frame.size.height -= Constant.NavigationBarOffset
        self.view.layer.addSublayer(playerLayer)
        
        let oneTap = UITapGestureRecognizer(target: self, action: #selector(self.handleOneTapGesture(_:)))
        pauseView.frame = pauseViewFrame
        pauseView.frame.size.height -= Constant.NavigationBarOffset
        pauseView.addGestureRecognizer(oneTap)
        view.addSubview(pauseView)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTapGesture(_:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
        playerTimeView = VideoPlayerTimeView(frame: CGRectMake( 0, view.width, view.height, 30))
        view.addSubview(playerTimeView)
        
        let lastPlayTime = Global.Database.doubleForKey("video-\(curFile.name.md5)")
        player.seekToTime(CMTimeMakeWithSeconds(lastPlayTime, 600))
        player.play()
    }
    
    func handleOneTapGesture(sender: UITapGestureRecognizer) {
        if isPlay {
            player.pause()
        } else {
            player.play()
        }
        
        let playerItem = player.currentItem!
        playerTimeView.setTime(playerItem.currentTime().seconds, totalTime: playerItem.duration.seconds)
        playerTimeView.show = isFullScreen && !isPlay

    }
    
    func handleDoubleTapGesture(sender: UITapGestureRecognizer) {
        isFullScreen = !isFullScreen
        if isFullScreen {
            UIDevice.currentDevice().setValue(UIInterfaceOrientation.LandscapeLeft.rawValue, forKey: "orientation")
        } else {
            UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
            tabBarController?.tabBar.hidden = true
        }
        playerLayer.frame = self.view.bounds
        pauseView.frame = pauseViewFrame
    }
    
    override func viewWillDisappear(animated: Bool) {
        player.pause()
        let key = "video-\(curFile.name.md5)"
        let playerItem = player.currentItem!
        if CMTimeGetSeconds(playerItem.duration - playerItem.currentTime()) < 0.1 {
            Global.Database.setDouble(0, forKey: key)
        } else {
            Global.Database.setDouble(playerItem.currentTime().seconds, forKey: key)
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
}

//        let player = AVPlayer(URL: curFile.url)
//        let playerController = AVPlayerViewController()
//        playerController.player = player
//        self.addChildViewController(playerController)
//        self.view.addSubview(playerController.view)
//        playerController.view.frame = CGRectMake(0, 200, 320, 200)
//        player.play()