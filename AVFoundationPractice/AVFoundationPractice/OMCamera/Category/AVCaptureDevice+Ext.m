//
//  AVCaptureDevice+Ext.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2018/10/17.
//  Copyright © 2018年 styf. All rights reserved.
//

#import "AVCaptureDevice+Ext.h"

@interface OMQualityOfService : NSObject

@property(strong, nonatomic, readonly) AVCaptureDeviceFormat *format;
@property(strong, nonatomic, readonly) AVFrameRateRange *frameRateRange;
@property(nonatomic, readonly) BOOL isHighFrameRate;

+ (instancetype)qosWithFormat:(AVCaptureDeviceFormat *)format
               frameRateRange:(AVFrameRateRange *)frameRateRange;

- (BOOL)isHighFrameRate;

@end

@implementation OMQualityOfService

+ (instancetype)qosWithFormat:(AVCaptureDeviceFormat *)format
               frameRateRange:(AVFrameRateRange *)frameRateRange {
    
    return [[self alloc] initWithFormat:format frameRateRange:frameRateRange];
}

- (instancetype)initWithFormat:(AVCaptureDeviceFormat *)format
                frameRateRange:(AVFrameRateRange *)frameRateRange {
    self = [super init];
    if (self) {
        _format = format;
        _frameRateRange = frameRateRange;
    }
    return self;
}

- (BOOL)isHighFrameRate {
    return self.frameRateRange.maxFrameRate > 30.0f;
}

@end

@implementation AVCaptureDevice (Ext)

/**
 是否支持高帧率捕捉
 */
- (BOOL)supportsHighFrameRateCapture {
    if (![self hasMediaType:AVMediaTypeVideo]) {//是不是视频设备
        return NO;
    }
    return [self findHighestQualityOfService].isHighFrameRate;//是否支持高帧率捕捉
}

/**
 打开高帧率捕捉
 */
- (BOOL)enableMaxFrameRateCapture:(NSError **)error {
    OMQualityOfService *qos = [self findHighestQualityOfService];
    
    if (!qos.isHighFrameRate) {
        if (error) {
            NSString *message = @"Device does not support high FPS capture";
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : message};
            *error = [NSError errorWithDomain:@""
                                         code:9999
                                     userInfo:userInfo];
        }
        return NO;
    }
    if ([self lockForConfiguration:error]) {
        
        CMTime minFrameDuration = qos.frameRateRange.minFrameDuration;
        
        self.activeFormat = qos.format;
        self.activeVideoMinFrameDuration = minFrameDuration;
        self.activeVideoMaxFrameDuration = minFrameDuration;
        
        [self unlockForConfiguration];
        return YES;
    }
    return NO;
}

/**
 查找最高的format和帧率
 */
- (OMQualityOfService *)findHighestQualityOfService {
    AVCaptureDeviceFormat *maxFormat = nil;
    AVFrameRateRange *maxFrameRateRange = nil;
    for (AVCaptureDeviceFormat *format in self.formats) {//找到摄像头所提供的最高format和帧率
        FourCharCode codecType = CMVideoFormatDescriptionGetCodecType(format.formatDescription);
        if (codecType == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {//筛选出视频格式
            NSArray *frameRateRanges = format.videoSupportedFrameRateRanges;
            for (AVFrameRateRange *range in frameRateRanges) {
                if (range.maxFrameRate > maxFrameRateRange.maxFrameRate) {
                    maxFormat = format;
                    maxFrameRateRange = range;
                }
            }
        }
    }
    
    return [OMQualityOfService qosWithFormat:maxFormat frameRateRange:maxFrameRateRange];
}

@end
