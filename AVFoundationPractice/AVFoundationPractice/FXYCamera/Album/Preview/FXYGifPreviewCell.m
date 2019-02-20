//
//  FXYGifPreviewCell.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/20.
//  Copyright © 2019 styf. All rights reserved.
//

#import "FXYGifPreviewCell.h"
#import "FXYPhotoPreviewView.h"
@implementation FXYGifPreviewCell

- (void)configSubviews {
    [self configPreviewView];
}

- (void)configPreviewView {
    _previewView = [[FXYPhotoPreviewView alloc] initWithFrame:CGRectZero];
    __weak typeof(self) weakSelf = self;
    [_previewView setSingleTapGestureBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf signleTapAction];
    }];
    [self addSubview:_previewView];
}

- (void)setModel:(FXYAssetModel *)model {
    [super setModel:model];
    _previewView.model = self.model;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _previewView.frame = self.bounds;
}

#pragma mark - Click Event

- (void)signleTapAction {
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock();
    }
}
@end
