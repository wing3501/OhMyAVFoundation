//
//  FXYPushAnimator.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/21.
//  Copyright © 2019 styf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FXYPushAnimator : NSObject<UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign) UINavigationControllerOperation operation;
@end

NS_ASSUME_NONNULL_END
