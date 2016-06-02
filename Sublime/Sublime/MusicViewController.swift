//
//  MusicViewController.swift
//  Sublime
//
//  Created by Eular on 2/21/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import UIKit
import AVFoundation

class MusicViewController: MusicWave {
    
    let popupMenu = PopupMenu()
    var curFile: File!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = curFile.name
        
        // 设置分享菜单
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: popupMenu, action: #selector(popupMenu.showUp))
        popupMenu.controller = self
        popupMenu.itemsToShare = [curFile.url]
        
        self.audioUrl = curFile.url
        self.start()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.audioPlayer.stop()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.audioPlayer.isPlaying() {
            self.audioPlayer.pause()
        } else {
            self.audioPlayer.play()
        }
    }

}
