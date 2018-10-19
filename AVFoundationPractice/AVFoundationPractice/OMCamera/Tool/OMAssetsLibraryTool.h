//
//  OMAssetsLibraryTool.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2018/10/16.
//  Copyright © 2018年 styf. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^AssetsLibraryCompletionHandler)(_Nullable id obj,NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface OMAssetsLibraryTool : NSObject
/**
 保存图片到相册
 
 @param image 图片
 @param completionHandler 回调
 */
+ (void)writeImageToAssetsLibrary:(UIImage *)image withCompletionHandler:(AssetsLibraryCompletionHandler)completionHandler;

/**
 保存视频到相册

 @param videoURL 本地视频URL
 @param completionHandler 回调
 */
+ (void)writeVideoToAssetsLibrary:(NSURL *)videoURL withCompletionHandler:(AssetsLibraryCompletionHandler)completionHandler;

/**
 生成一张视频封面

 @param videoURL 本地视频URL
 @param width 图片宽度
 @param completionHandler 回调
 */
+ (void)generateThumbnailForVideoAtURL:(NSURL *)videoURL width:(CGFloat)width withCompletionHandler:(AssetsLibraryCompletionHandler)completionHandler;
@end

NS_ASSUME_NONNULL_END
