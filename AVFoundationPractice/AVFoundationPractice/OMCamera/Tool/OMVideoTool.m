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
 
 @param inputURL 读入地址
 @param outputURL 写入地址
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

@end
