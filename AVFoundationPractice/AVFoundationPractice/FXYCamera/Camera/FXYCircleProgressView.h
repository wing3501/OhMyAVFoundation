//
//  FXYCircleProgressView.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/15.
//  Copyright © 2019 styf. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FXYCircleProgressView : UIView
/// 是否需要进度动画
@property (nonatomic, assign) BOOL needAnimation;
/// 数字文本
@property (nonatomic, copy) NSString *numberText;
/// 点击回调
@property (nonatomic, copy) void(^clickBlock)(void);
/// 开始回调
@property (nonatomic, copy) void(^startBlock)(void);
/// 结束回调
@property (nonatomic, copy) void(^endBlock)(void);
@end

NS_ASSUME_NONNULL_END
