//
//  FXYAssetModel.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/19.
//  Copyright © 2019 styf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    FXYAssetModelMediaTypePhoto = 0,
    FXYAssetModelMediaTypeLivePhoto,
    FXYAssetModelMediaTypePhotoGif,
    FXYAssetModelMediaTypeVideo,
    FXYAssetModelMediaTypeAudio
} FXYAssetModelMediaType;

@class PHAsset;

@interface FXYAssetModel : NSObject
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign) BOOL isSelected;      ///< The select status of a photo, default is No
@property (nonatomic, assign) FXYAssetModelMediaType type;
@property (nonatomic, copy) NSString *timeLength;

/// Init a photo dataModel With a PHAsset
/// 用一个PHAsset实例，初始化一个照片模型
+ (instancetype)modelWithAsset:(PHAsset *)asset type:(FXYAssetModelMediaType)type;
+ (instancetype)modelWithAsset:(PHAsset *)asset type:(FXYAssetModelMediaType)type timeLength:(NSString *)timeLength;
@end

