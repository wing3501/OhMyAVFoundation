//
//  AVPlayerDemoViewController.m
//  OhMyAVFoundation
//
//  Created by 申屠云飞 on 2018/9/5.
//  Copyright © 2018年 styf. All rights reserved.
//

static const NSString *PlayerItemStatusContext;

#import "AVPlayerDemoViewController.h"

@interface AVPlayerDemoViewController ()
/// 播放器
@property (nonatomic,strong) AVPlayer *player;
@end

@implementation AVPlayerDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSURL *assetURL = [[NSBundle mainBundle]URLForResource:@"Charlie The Unicorn" withExtension:@"m4v"];
    AVAsset *asset = [AVAsset assetWithURL:assetURL];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    [playerItem addObserver:self forKeyPath:@"status" options:0 context:&PlayerItemStatusContext];
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame = self.view.frame;
    [self.view.layer addSublayer:playerLayer];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    //观察视频播放状态
    if (context == &PlayerItemStatusContext) {
        AVPlayerItem *playerItem = (AVPlayerItem *)object;
        NSLog(@"=========>%ld",playerItem.status);
        if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
            [self.player play];
        }
    }
}
@end
