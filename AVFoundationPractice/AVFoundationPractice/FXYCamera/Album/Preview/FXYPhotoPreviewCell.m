//
//  FXYPhotoPreviewCell.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/20.
//  Copyright © 2019 styf. All rights reserved.
//

#import "FXYPhotoPreviewCell.h"
@implementation FXYPhotoPreviewCell

- (void)configSubviews {
    self.previewView = [[FXYPhotoPreviewView alloc] initWithFrame:CGRectZero];
    __weak typeof(self) weakSelf = self;
    [self.previewView setSingleTapGestureBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.singleTapGestureBlock) {
            strongSelf.singleTapGestureBlock();
        }
    }];
    [self.previewView setImageProgressUpdateBlock:^(double progress) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.imageProgressUpdateBlock) {
            strongSelf.imageProgressUpdateBlock(progress);
        }
    }];
    [self addSubview:self.previewView];
}

- (void)setModel:(FXYAssetModel *)model {
    [super setModel:model];
    _previewView.asset = model.asset;
}

- (void)recoverSubviews {
    [_previewView recoverSubviews];
}

- (void)setAllowCrop:(BOOL)allowCrop {
    _allowCrop = allowCrop;
    _previewView.allowCrop = allowCrop;
}

- (void)setCropRect:(CGRect)cropRect {
    _cropRect = cropRect;
    _previewView.cropRect = cropRect;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.previewView.frame = self.bounds;
}
@end
