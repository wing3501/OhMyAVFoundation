//
//  OMVideoTool.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2018/10/18.
//  Copyright © 2018年 styf. All rights reserved.
//

#import "OMVideoTool.h"
@interface OMVideoTool()
/// 样本读取
@property (nonatomic,strong) AVAssetReader *assetReader;
/// 样本写入
@property (nonatomic,strong) AVAssetWriter *assetWriter;
/// 写队列
@property (nonatomic,strong) dispatch_queue_t dispatchQueue;
/// 导出会话
@property (nonatomic,strong) AVAssetExportSession *exportSession;
@end

@implementation OMVideoTool
SingletonM(OMVideoTool)

- (instancetype)init {
    self = [super init];
    if (self) {
        _dispatchQueue = dispatch_queue_create("com.styf.writerQueue", NULL);
    }
    return self;
}

/**
 把视频从一个地址写到另一个地址(quicktime格式)
 
 @param inputURL 视频输入URL
 @param outputURL 视频输出URL
 @param completionHandler 回调
 */
- (void)writeVideoFrom:(NSURL *)inputURL to:(NSURL *)outputURL withCompletionHandler:(WriteCompletionHandler)completionHandler {
    //配置AVAssetReader
    AVAsset *asset = [AVAsset assetWithURL:inputURL];
    AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    NSDictionary *readerOutputSetting = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    AVAssetReaderTrackOutput *trackOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:track outputSettings:readerOutputSetting];

    self.assetReader = [[AVAssetReader alloc]initWithAsset:asset error:nil];
    [self.assetReader addOutput:trackOutput];
    [self.assetReader startReading];

    //配置AVAssetWriter
    self.assetWriter = [[AVAssetWriter alloc]initWithURL:outputURL fileType:AVFileTypeQuickTimeMovie error:nil];
    NSDictionary *writerOutputSettings = @{
                                           AVVideoCodecKey:AVVideoCodecH264,
                                           AVVideoWidthKey:@(track.naturalSize.width),
                                           AVVideoHeightKey:@(track.naturalSize.height),
                                           AVVideoCompressionPropertiesKey:@{
                                                   AVVideoMaxKeyFrameIntervalKey:@1,
                                                   AVVideoAverageBitRateKey:@10500000,
                                                   AVVideoProfileLevelKey:AVVideoProfileLevelH264Main31
                                                   }
                                           };
    AVAssetWriterInput *writerInput = [[AVAssetWriterInput alloc]initWithMediaType:AVMediaTypeVideo outputSettings:writerOutputSettings];
    [self.assetWriter addInput:writerInput];
    [self.assetWriter startWriting];

    //创建会话
    [self.assetWriter startSessionAtSourceTime:kCMTimeZero];
    [writerInput requestMediaDataWhenReadyOnQueue:self.dispatchQueue usingBlock:^{
        BOOL complete = NO;
        while ([writerInput isReadyForMoreMediaData] && !complete) {
            CMSampleBufferRef sampleBuffer = [trackOutput copyNextSampleBuffer];
            if (sampleBuffer) {
                BOOL result = [writerInput appendSampleBuffer:sampleBuffer];
                CFRelease(sampleBuffer);
                complete = !result;
            }else{
                [writerInput markAsFinished];
                complete = YES;
            }

            if (complete) {
                [self.assetWriter finishWritingWithCompletionHandler:^{
                    AVAssetWriterStatus status = self.assetWriter.status;
                    if (status == AVAssetWriterStatusCompleted) {
                        NSLog(@"写入成功");
                        completionHandler ? completionHandler(outputURL,nil):nil;
                    }else{
                        NSLog(@"写入失败");
                        completionHandler ? completionHandler(outputURL,[NSError errorWithDomain:@"com.styf.writer" code:888 userInfo:nil]):nil;
                    }
                }];
            }
        }
    }];
}

/**
 加载本地视频资源
 
 @param URL 视频URL
 @param completionHandler 回调
 */
+ (void)loadAsset:(NSURL *)URL withCompletionHandler:(LoadCompletionHandler)completionHandler {
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@YES};//可以计算出时长和时间信息
    AVAsset *asset = [AVURLAsset URLAssetWithURL:URL options:options];
    NSArray *keys = @[@"tracks",@"duration",@"commonMetadata"];
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        NSError *error = nil;
        AVKeyValueStatus status = [asset statusOfValueForKey:@"tracks" error:&error];
        switch (status) {
            case AVKeyValueStatusLoaded:
                completionHandler?completionHandler(asset,nil):nil;
                break;
            case AVKeyValueStatusFailed:
                completionHandler?completionHandler(nil,error):nil;
                break;
            case AVKeyValueStatusCancelled:
                break;
            default:
                break;
        }
    }];
}

/**
 裁剪视频
 
 @param URL 本地视频URL
 @param outputURL 输出URL
 @param timeRange 裁剪时间
 @param preset 视频质量
 @param outputFileType 输出格式
 @param completionHandler 回调
 */
- (void)cutVideo:(NSURL *)URL to:(NSURL *)outputURL by:(CMTimeRange)timeRange withPreset:(NSString * _Nullable)preset outputFileType:(AVFileType _Nullable)outputFileType completionHandler:(CutCompletionHandler)completionHandler {
    WEAKSELF
    [OMVideoTool loadAsset:URL withCompletionHandler:^(AVAsset * _Nullable asset, NSError * _Nullable error) {
        STRONGSELF
        if (error) {
            completionHandler?completionHandler(error):nil;
        }else{
            CMTimeRange assetTimeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
            CMTimeRange intersectionRange = CMTimeRangeGetIntersection(assetTimeRange, timeRange);
            if (CMTIMERANGE_IS_VALID(intersectionRange) && CMTimeGetSeconds(intersectionRange.duration) > 0) {
                NSString *videoPreset = preset.length ? preset : AVAssetExportPreset1280x720;
                AVFileType videoFileType = outputFileType.length ? outputFileType : AVFileTypeQuickTimeMovie;
                strongSelf.exportSession = [[AVAssetExportSession alloc]initWithAsset:asset presetName:videoPreset];
                strongSelf.exportSession.outputFileType = videoFileType;
                strongSelf.exportSession.outputURL = outputURL;
                strongSelf.exportSession.timeRange = intersectionRange;
                [strongSelf.exportSession exportAsynchronouslyWithCompletionHandler:^{
                    STRONGSELF
                    AVAssetExportSessionStatus status = strongSelf.exportSession.status;
                    if (status == AVAssetExportSessionStatusFailed) {
                        NSLog(@"error:%@",strongSelf.exportSession.error);
                        completionHandler ? completionHandler(strongSelf.exportSession.error):nil;
                    }else if (status == AVAssetExportSessionStatusCompleted) {
                        completionHandler ? completionHandler(nil):nil;
                    }
                }];
            }else{
                completionHandler?completionHandler([NSError errorWithDomain:@"omvideo" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"裁剪区域有误." }]):nil;
            }
        }
    }];
}

/**
 裁剪视频
 
 @param URL 本地视频URL
 @param outputURL 输出URL
 @param timeRange 裁剪时间
 @param completionHandler 回调
 */
- (void)cutVideo:(NSURL *)URL to:(NSURL *)outputURL by:(CMTimeRange)timeRange withCompletionHandler:(CutCompletionHandler)completionHandler {
    [self cutVideo:URL to:outputURL by:timeRange withPreset:nil outputFileType:nil completionHandler:completionHandler];
}
@end
