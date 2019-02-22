//
//  FXYPhotoCell.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/22.
//  Copyright © 2019 styf. All rights reserved.
//

#import "FXYPhotoCell.h"
@interface FXYPhotoCell()
/// 图片
@property (nonatomic, strong) UIImageView *imageView;
@end
@implementation FXYPhotoCell

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

/**
 初始化
 */
- (void)commonInit {
    [self setupUI];
}

/**
 设置视图
 */
- (void)setupUI {
    [self.contentView addSubview:self.imageView];
}

#pragma mark - overwrite

#pragma mark - request

#pragma mark - public

#pragma mark - notification

#pragma mark - event response

#pragma mark - private

#pragma mark - getter and setter

- (void)setImage:(UIImage *)image {
    _image = image;
    self.imageView.image = image;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc]initWithFrame:self.bounds];
    }
    return _imageView;
}
@end
