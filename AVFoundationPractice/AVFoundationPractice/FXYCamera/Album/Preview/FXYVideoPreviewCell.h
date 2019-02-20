//
//  FXYVideoPreviewCell.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/20.
//  Copyright © 2019 styf. All rights reserved.
//

#import "FXYAssetPreviewCell.h"

@class AVPlayer, AVPlayerLayer;
@interface FXYVideoPreviewCell : FXYAssetPreviewCell
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UIImage *cover;
@property (nonatomic, strong) NSURL *videoURL;
- (void)pausePlayerAndShowNaviBar;
@end
