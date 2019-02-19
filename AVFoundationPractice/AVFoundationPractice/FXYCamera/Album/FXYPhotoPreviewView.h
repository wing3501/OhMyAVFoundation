//
//  FXYPhotoPreviewView.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/19.
//  Copyright © 2019 styf. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FXYProgressView,FXYAssetModel;

@interface FXYPhotoPreviewView : UIView
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, strong) FXYProgressView *progressView;

@property (nonatomic, assign) BOOL allowCrop;
@property (nonatomic, assign) CGRect cropRect;

@property (nonatomic, strong) FXYAssetModel *model;
@property (nonatomic, strong) id asset;
@property (nonatomic, copy) void (^singleTapGestureBlock)(void);
@property (nonatomic, copy) void (^imageProgressUpdateBlock)(double progress);

@property (nonatomic, assign) int32_t imageRequestID;

- (void)recoverSubviews;
@end

/// 该分类的代码来自SDWebImage:https://github.com/rs/SDWebImage
/// 为了防止冲突，我将分类名字和方法名字做了修改
@interface UIImage (FXYGif)
+ (UIImage *)sd_fxy_animatedGIFWithData:(NSData *)data;
@end

