//
//  MusicWave.h
//  Sublime
//
//  Created by Eular on 2/21/16.
//  Copyright © 2016 Eular. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EZAudio/EZAudio.h>
#import <ZLMusicFlowWaveView/ZLMusicFlowWaveView.h>
#import <AVFoundation/AVFoundation.h>

@interface MusicWave : UIViewController <EZAudioPlayerDelegate>
@property (nonatomic,strong) EZAudioPlayer *audioPlayer;
@property (nonatomic,strong) NSURL *audioUrl;
-(void) start;
@end
