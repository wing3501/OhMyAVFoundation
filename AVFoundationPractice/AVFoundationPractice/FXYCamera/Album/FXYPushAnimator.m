//
//  FXYPushAnimator.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/21.
//  Copyright © 2019 styf. All rights reserved.
//

#import "FXYPushAnimator.h"

@implementation FXYPushAnimator
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.35;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    [[transitionContext containerView] addSubview:toView];
    CGRect toViewFinalFrame = [transitionContext finalFrameForViewController:toVC];
    
    CGRect fromViewFinalFrame = CGRectZero;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if (_operation == UINavigationControllerOperationPush) {
        toView.frame = CGRectMake(screenWidth, 0, screenWidth, screenHeight);
        fromViewFinalFrame = CGRectMake(-screenWidth, 0, screenWidth, screenHeight);
    }else if(_operation == UINavigationControllerOperationPop) {
        toView.frame = CGRectMake(-screenWidth, 0, screenWidth, screenHeight);
        fromViewFinalFrame = CGRectMake(screenWidth, 0, screenWidth, screenHeight);
    }
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                     animations:^{
                         fromView.frame = fromViewFinalFrame;
                         toView.frame = toViewFinalFrame;
                     }
                     completion:^(BOOL finished) {
                         if (![transitionContext transitionWasCancelled]) {
                             [fromView removeFromSuperview];
                             [transitionContext completeTransition:YES];
                         }
                         else {
                             [toView removeFromSuperview];
                             [transitionContext completeTransition:NO];
                         }
                     }];
}
@end
