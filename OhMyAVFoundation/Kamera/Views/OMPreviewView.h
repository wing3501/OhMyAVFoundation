//
//  OMPreviewView.h
//  OhMyAVFoundation
//
//  Created by 申屠云飞 on 2018/9/10.
//  Copyright © 2018年 styf. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OMPreviewViewDelegate <NSObject>
- (void)tappedToFocusAtPoint:(CGPoint)point;
- (void)tappedToExposeAtPoint:(CGPoint)point;
- (void)tappedToResetFocusAndExposure;
@end

@interface OMPreviewView : UIView

@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,weak) id<OMPreviewViewDelegate> delegate;

@property (nonatomic,assign) BOOL tapToFocusEnabled;
@property (nonatomic,assign) BOOL tapToExposeEnabled;
@end
