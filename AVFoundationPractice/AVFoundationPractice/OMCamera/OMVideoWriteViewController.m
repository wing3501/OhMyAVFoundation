//
//  OMVideoWriteViewController.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2018/10/18.
//  Copyright © 2018年 styf. All rights reserved.
//

#import "OMVideoWriteViewController.h"
#import "OMVideoTool.h"
#import <AVKit/AVKit.h>
@interface OMVideoWriteViewController ()
/// 写入按钮
@property (nonatomic,strong) UIButton *writeButton;
/// 播放按钮
@property (nonatomic,strong) UIButton *playButton;
/// 播放地址
@property (nonatomic,strong) NSURL *outputURL;
@end

@implementation OMVideoWriteViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

/**
 初始化
 */
- (void)commonInit {
    [self setupUI];
    
}

/**
 设置视图
 */
- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.writeButton];
    [self.view addSubview:self.playButton];
}
#pragma mark - overwrite

#pragma mark - public

#pragma mark - notification

#pragma mark - event response

- (void)write {
    NSURL *inputURL = [[NSBundle mainBundle]URLForResource:@"20180920094712" withExtension:@"mp4"];
    NSArray<NSString *> *myPathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSURL *outputURL = [NSURL fileURLWithPath:[myPathList.firstObject stringByAppendingPathComponent:[NSString stringWithFormat:@"%0f.mov",[NSDate date].timeIntervalSince1970]]];
    NSLog(@"=====>%@",inputURL);
    NSLog(@"=====>%@",outputURL);

    WEAKSELF
    [[OMVideoTool sharedOMVideoTool]writeVideoFrom:inputURL to:outputURL withCompletionHandler:^(NSURL * _Nonnull URL, NSError * _Nonnull error) {
        STRONGSELF
        strongSelf.outputURL = URL;
    }];
    
}

- (void)play {
    if (_outputURL) {
        AVPlayerViewController *controller = [[AVPlayerViewController alloc]init];
        controller.player = [AVPlayer playerWithURL:_outputURL];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - private

#pragma mark - getter and setter

- (UIButton *)writeButton {
    if (!_writeButton) {
        _writeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_writeButton setTitle:@"写入到沙盒" forState:UIControlStateNormal];
        [_writeButton addTarget:self action:@selector(write) forControlEvents:UIControlEventTouchUpInside];
        _writeButton.frame = CGRectMake(50, 80, 150, 40);
        _writeButton.backgroundColor = [UIColor cyanColor];
    }
    return _writeButton;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setTitle:@"播放" forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
        _playButton.frame = CGRectMake(50, 150, 150, 40);
        _playButton.backgroundColor = [UIColor blueColor];
    }
    return _playButton;
}

@end
