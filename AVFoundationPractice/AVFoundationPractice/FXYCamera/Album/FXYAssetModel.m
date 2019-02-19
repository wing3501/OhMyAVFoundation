//
//  FXYAssetModel.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/19.
//  Copyright © 2019 styf. All rights reserved.
//

#import "FXYAssetModel.h"

@implementation FXYAssetModel
+ (instancetype)modelWithAsset:(PHAsset *)asset type:(FXYAssetModelMediaType)type{
    FXYAssetModel *model = [[FXYAssetModel alloc] init];
    model.asset = asset;
    model.isSelected = NO;
    model.type = type;
    return model;
}

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(FXYAssetModelMediaType)type timeLength:(NSString *)timeLength {
    FXYAssetModel *model = [self modelWithAsset:asset type:type];
    model.timeLength = timeLength;
    return model;
}
@end
