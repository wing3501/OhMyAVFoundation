//
//  OMCircleProgressView.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2018/10/15.
//  Copyright © 2018年 styf. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OMCircleProgressView;
@protocol OMCircleProgressViewDelegate<NSObject>
@optional
- (void)progressViewDidSingleTap:(OMCircleProgressView *)progressView;
- (void)progressViewBeganLongPress:(OMCircleProgressView *)progressView;
- (void)progressViewStopCountDown:(OMCircleProgressView *)progressView;
@end

@interface OMCircleProgressView : UIView
/// 代理
@property (nonatomic,weak) id<OMCircleProgressViewDelegate>delegate;
@end
