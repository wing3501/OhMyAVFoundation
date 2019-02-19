//
//  FXYAlbumModel.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/19.
//  Copyright © 2019 styf. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PHFetchResult;

@interface FXYAlbumModel : NSObject
@property (nonatomic, strong) NSString *name;        ///< The album name
@property (nonatomic, assign) NSInteger count;       ///< Count of photos the album contain
@property (nonatomic, strong) PHFetchResult *result;
/// 相册中所有模型
@property (nonatomic, strong) NSArray *models;
/// 选中的模型
@property (nonatomic, strong) NSArray *selectedModels;
/// 选中的数量
@property (nonatomic, assign) NSUInteger selectedCount;

@property (nonatomic, assign) BOOL isCameraRoll;

- (void)setResult:(PHFetchResult *)result needFetchAssets:(BOOL)needFetchAssets;
@end

