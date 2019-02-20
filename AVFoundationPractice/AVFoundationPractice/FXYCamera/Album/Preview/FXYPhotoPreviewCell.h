//
//  FXYPhotoPreviewCell.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/20.
//  Copyright © 2019 styf. All rights reserved.
//

#import "FXYAssetPreviewCell.h"
#import "FXYPhotoPreviewView.h"
@interface FXYPhotoPreviewCell : FXYAssetPreviewCell
@property (nonatomic, copy) void (^imageProgressUpdateBlock)(double progress);

@property (nonatomic, strong) FXYPhotoPreviewView *previewView;

@property (nonatomic, assign) BOOL allowCrop;
@property (nonatomic, assign) CGRect cropRect;

- (void)recoverSubviews;
@end

