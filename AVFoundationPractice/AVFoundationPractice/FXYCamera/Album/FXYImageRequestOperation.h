//
//  FXYImageRequestOperation.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/20.
//  Copyright © 2019 styf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN

@interface FXYImageRequestOperation : NSOperation
typedef void(^FXYImageRequestCompletedBlock)(UIImage *photo, NSDictionary *info, BOOL isDegraded);
typedef void(^FXYImageRequestProgressBlock)(double progress, NSError *error, BOOL *stop, NSDictionary *info);

@property (nonatomic, copy, nullable) FXYImageRequestCompletedBlock completedBlock;
@property (nonatomic, copy, nullable) FXYImageRequestProgressBlock progressBlock;
@property (nonatomic, strong, nullable) PHAsset *asset;

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;

- (instancetype)initWithAsset:(PHAsset *)asset completion:(FXYImageRequestCompletedBlock)completionBlock progressHandler:(FXYImageRequestProgressBlock)progressHandler;
- (void)done;
@end

NS_ASSUME_NONNULL_END
