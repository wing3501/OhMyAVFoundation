//
//  OMAssetsLibraryTool.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2018/10/16.
//  Copyright © 2018年 styf. All rights reserved.
//

#import "OMAssetsLibraryTool.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation OMAssetsLibraryTool
/**
 保存图片到相册
 
 @param image 图片
 @param completionHandler 回调
 */
+ (void)writeImageToAssetsLibrary:(UIImage *)image withCompletionHandler:(AssetsLibraryCompletionHandler)completionHandler {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:image.CGImage
                              orientation:(NSInteger)image.imageOrientation
                          completionBlock:^(NSURL *assetURL, NSError *error) {
                              completionHandler ? completionHandler(assetURL,error) : nil;
                          }];
}
/**
 保存视频到相册
 
 @param videoURL 视频URL
 @param completionHandler 回调
 */
+ (void)writeVideoToAssetsLibrary:(NSURL *)videoURL withCompletionHandler:(AssetsLibraryCompletionHandler)completionHandler {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:videoURL]) {//检查视频是否可被写入
        [library writeVideoAtPathToSavedPhotosAlbum:videoURL completionBlock:^(NSURL *assetURL, NSError *error) {
            completionHandler ? completionHandler(assetURL,error) : nil;
        }];
    }
}

/**
 生成一张视频封面
 
 @param videoURL 本地视频URL
 @param width 图片宽度
 @param completionHandler 回调
 */
+ (void)generateThumbnailForVideoAtURL:(NSURL *)videoURL width:(CGFloat)width withCompletionHandler:(AssetsLibraryCompletionHandler)completionHandler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVAsset *asset = [AVAsset assetWithURL:videoURL];
        AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        imageGenerator.maximumSize = CGSizeMake(width, 0.0f);//高度设置为0会自动根据宽高比来设置高度
        imageGenerator.appliesPreferredTrackTransform = YES;//生成缩略图时考虑视频变化，比如方向
        NSError *error;
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:&error];//这是一个同步方法
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler ? completionHandler(image,error) : nil;
        });
    });
}
@end
