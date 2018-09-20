//
//  AudioLooperController.m
//  OhMyAVFoundation
//
//  Created by 申屠云飞 on 2018/8/29.
//  Copyright © 2018年 styf. All rights reserved.
//

#import "AudioLooperController.h"

@interface AudioLooperController ()
@property (weak, nonatomic) IBOutlet UIButton *playButton;
/// 播放器数组
@property (nonatomic,strong) NSArray<AVAudioPlayer *> *players;
/// 是否正在播放
@property (nonatomic,assign) BOOL playing;
@end

@implementation AudioLooperController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        AVAudioPlayer *guitarPlayer = [self playerForFile:@"guitar"];
        AVAudioPlayer *bassPlayer = [self playerForFile:@"bass"];
        AVAudioPlayer *drumsPlayer = [self playerForFile:@"drums"];
        _players = @[guitarPlayer,bassPlayer,drumsPlayer];
        
        //中断通知
        NSNotificationCenter *nsnc = [NSNotificationCenter defaultCenter];
        [nsnc addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
        
        //线路切换通知
        [nsnc addObserver:self selector:@selector(handleRouteChange:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    }
    return self;
}

- (void)viewDidLoad {
    self.title = @"Audio Looper";
    [super viewDidLoad];
}

- (IBAction)play:(id)sender {
    if (!_playing) {
        NSTimeInterval delayTime = [self.players[0] deviceCurrentTime] + 0.01;
        for (AVAudioPlayer *player in self.players) {
            [player playAtTime:delayTime];//保证播放器在播放时始终保持紧密同步
        }
        _playing = YES;
        [_playButton setTitle:@"Stop" forState:UIControlStateNormal];
    }else{
        for (AVAudioPlayer *player in self.players) {
            [player stop];
            player.currentTime = 0.0f;
        }
        _playing = NO;
        [_playButton setTitle:@"Play" forState:UIControlStateNormal];
    }
}

/**
 改变播放速度 0.5-2.0
 */
- (IBAction)rate:(UISlider *)sender {
    for (AVAudioPlayer *player in self.players) {
        player.rate = sender.value;
    }
}

/**
 立体声声道 -1.0-1.0
 */
- (IBAction)guitarPan:(UISlider *)sender {
    _players[0].pan = sender.value;
}

/**
 音量 0.0-1.0
 */
- (IBAction)guitarVolume:(UISlider *)sender {
    _players[0].volume = sender.value;
}
- (IBAction)bassPan:(UISlider *)sender {
    _players[1].pan = sender.value;
}
- (IBAction)bassVolume:(UISlider *)sender {
    _players[1].volume = sender.value;
}
- (IBAction)drumsPan:(UISlider *)sender {
    _players[2].pan = sender.value;
}
- (IBAction)drumsVolume:(UISlider *)sender {
    _players[2].volume = sender.value;
}

- (AVAudioPlayer *)playerForFile:(NSString *)name {
    NSURL *fileUrl = [[NSBundle mainBundle]URLForResource:name withExtension:@"caf"];
    NSError *error;
    AVAudioPlayer *player = [[AVAudioPlayer alloc]initWithContentsOfURL:fileUrl error:&error];
    player.numberOfLoops = -1;//无限循环
    player.enableRate = YES;
    [player prepareToPlay];
    return player;
}

//中断通知
- (void)handleInterruption:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    AVAudioSessionInterruptionType type = [info[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        //停止播放
    }else{
//        AVAudioSessionInterruptionTypeEnded
        AVAudioSessionInterruptionOptions options = [info[AVAudioSessionInterruptionOptionKey]unsignedIntegerValue];
        if (options == AVAudioSessionInterruptionOptionShouldResume) {
            //继续播放
        }
    }
}

//线路切换通知
- (void)handleRouteChange:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    AVAudioSessionRouteChangeReason reason = [info[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
    if (reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {//耳机断开
        AVAudioSessionRouteDescription *previousRoute = info[AVAudioSessionRouteChangePreviousRouteKey];//上一个设备的信息
        AVAudioSessionPortDescription *previousOutput = previousRoute.outputs[0];//第一个输出口接口信息
        NSString *portType = previousOutput.portType;
        if ([portType isEqualToString:AVAudioSessionPortHeadphones]) {//耳机
            //停止播放
        }
    }
}

@end
