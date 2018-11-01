//
//  OMVideoTool.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2018/10/18.
//  Copyright © 2018年 styf. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^WriteCompletionHandler)(NSURL * _Nullable URL, NSError * _Nullable error);
typedef void(^LoadCompletionHandler)(AVAsset * _Nullable asset, NSError * _Nullable error);
typedef void(^CutCompletionHandler)(NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface OMAssetsTrackModel : NSObject
/// 资源
@property (nonatomic,strong) AVAsset *asset;
/// 需要使用的范围
@property (nonatomic,assign) CMTimeRange timeRange;

- (instancetype)initWithAsset:(AVAsset *)asset timeRange:(CMTimeRange)timeRange;

+ (instancetype)assetsTrackModelWithAsset:(AVAsset *)asset timeRange:(CMTimeRange)timeRange;

@end

@interface OMVideoTool : NSObject
SingletonH(OMVideoTool)

/**
 加载本地视频资源
 
 @param URL 视频URL
 @param completionHandler 回调
 */
+ (void)loadAsset:(NSURL *)URL withCompletionHandler:(LoadCompletionHandler)completionHandler;

/**
 按顺序组合视频、音频

 @param videoTrackModelArray 视频轨道数组
 @param audioTrackModelArray 音频轨道数组
 @return 组合后的视频
 */
+ (AVMutableComposition *)composeVideoWithVideoTrackModelArray:(NSArray<OMAssetsTrackModel *> *)videoTrackModelArray andAudioTrackModelArray:(NSArray<OMAssetsTrackModel *> *)audioTrackModelArray;

/**
 把视频从一个地址写到另一个地址(quicktime格式)

 @param inputURL 视频输入URL
 @param outputURL 视频输出URL
 @param completionHandler 回调
 */
- (void)writeVideoFrom:(NSURL *)inputURL to:(NSURL *)outputURL withCompletionHandler:(WriteCompletionHandler)completionHandler;

/**
 裁剪视频
 
 @param asset 本地视频
 @param outputURL 输出URL
 @param timeRange 裁剪时间
 @param preset 视频质量
 @param outputFileType 输出格式
 @param completionHandler 回调
 */
- (void)cutVideoAsset:(AVAsset *)asset to:(NSURL *)outputURL by:(CMTimeRange)timeRange withPreset:(NSString * _Nullable)preset outputFileType:(AVFileType _Nullable)outputFileType completionHandler:(CutCompletionHandler)completionHandler;

/**
 裁剪视频

 @param URL 本地视频URL
 @param outputURL 输出URL
 @param timeRange 裁剪时间
 @param completionHandler 回调
 */
- (void)cutVideo:(NSURL *)URL to:(NSURL *)outputURL by:(CMTimeRange)timeRange withCompletionHandler:(CutCompletionHandler)completionHandler;

/**
 裁剪视频

 @param URL 本地视频URL
 @param outputURL 输出URL
 @param timeRange 裁剪时间
 @param preset 视频质量
 @param outputFileType 输出格式
 @param completionHandler 回调
 */
- (void)cutVideo:(NSURL *)URL to:(NSURL *)outputURL by:(CMTimeRange)timeRange withPreset:(NSString * _Nullable)preset outputFileType:(AVFileType _Nullable)outputFileType completionHandler:(CutCompletionHandler)completionHandler;

/**
 导出视频
 
 @param asset 本地视频
 @param outputURL 输出URL
 @param completionHandler 回调
 */
- (void)exportVideo:(AVAsset *)asset to:(NSURL *)outputURL withCompletionHandler:(CutCompletionHandler)completionHandler;

/**
 导出视频

 @param asset 本地视频
 @param outputURL 输出URL
 @param preset 视频质量
 @param outputFileType 输出格式
 @param completionHandler 回调
 */
- (void)exportVideo:(AVAsset *)asset to:(NSURL *)outputURL withPreset:(NSString * _Nullable)preset outputFileType:(AVFileType _Nullable)outputFileType completionHandler:(CutCompletionHandler)completionHandler;
@end

NS_ASSUME_NONNULL_END
