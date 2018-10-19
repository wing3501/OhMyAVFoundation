//
//  OMPreviewView.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2018/10/19.
//  Copyright © 2018年 styf. All rights reserved.
//

#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const OMFilterSelectionChangedNotification;//滤镜切换通知

@interface OMPreviewView : GLKView
/// 滤镜
@property (nonatomic,strong) CIFilter *filter;
/// 
@property (nonatomic,strong) CIContext *coreImageContext;

- (void)setImage:(CIImage *)sourceImage;
@end

NS_ASSUME_NONNULL_END
