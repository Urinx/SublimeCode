//
//  MusicWave.m
//  Sublime
//
//  Created by Eular on 2/21/16.
//  Copyright © 2016 Eular. All rights reserved.
//

#import "MusicWave.h"

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]

@interface MusicWave ()
@property (nonatomic,strong) ZLMusicFlowWaveView *audioPlot;
@end

@implementation MusicWave

#pragma mark - Initialization
-(id)init {
    self = [super init];
    if(self){
        [self initializeViewController];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initializeViewController];
    }
    return self;
}

#pragma mark - Initialize View Controller Here
-(void)initializeViewController {
    // Create an instance of the microphone and tell it to use this view controller instance as the delegate
}

#pragma mark - Customize the Audio Plot
-(void)viewDidLoad {
    [super viewDidLoad];
    // 1. 设置并激活音频会话类别
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error) {
        NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
    }
    [session setActive:YES error:&error];
    if (error) {
        NSLog(@"Error setting up audio session active: %@", error.localizedDescription);
    }
    // 2. 允许应用程序接收远程控制
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    // 3. 设置后台任务ID
    UIBackgroundTaskIdentifier newTaskId = UIBackgroundTaskInvalid;
    newTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
    
    if (![self isHeadsetPluggedIn]) {
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:NULL];
        if(error){
            NSLog(@"There was an error sending the audio to the speakers");
        }
    }
    
    // set plot
    self.audioPlot = [[ZLMusicFlowWaveView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64)];
    self.audioPlot.backgroundColor = RGB(81, 81, 81);
    self.audioPlot.color = RGB(255, 255, 255);
    [self.view addSubview:self.audioPlot];
}

- (BOOL)isHeadsetPluggedIn {
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
}

-(void)start {
    self.audioPlayer = [[EZAudioPlayer alloc] initWithURL:self.audioUrl withDelegate:self];
    self.audioPlayer.shouldLoop = YES;
    [self.audioPlayer play];
}

-(void)audioPlayer:(EZAudioPlayer *)audioPlayer readAudio:(float **)buffer withBufferSize:(UInt32)bufferSize withNumberOfChannels:(UInt32)numberOfChannels inAudioFile:(EZAudioFile *)audioFile {
    dispatch_async(dispatch_get_main_queue(),^{
        // All the audio plot needs is the buffer data (float*) and the size. Internally the audio plot will handle all the drawing related code, history management, and freeing its own resources. Hence, one badass line of code gets you a pretty plot :)
        [self.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
    });
}

@end
