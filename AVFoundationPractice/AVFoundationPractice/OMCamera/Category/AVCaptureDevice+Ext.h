//
//  AVCaptureDevice+Ext.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2018/10/17.
//  Copyright © 2018年 styf. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVCaptureDevice (Ext)

/**
 是否支持高帧率捕捉
 */
- (BOOL)supportsHighFrameRateCapture;

/**
 打开高帧率捕捉
 */
- (BOOL)enableMaxFrameRateCapture:(NSError **)error;
@end

NS_ASSUME_NONNULL_END
