//
//  FXYAssetCell.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/20.
//  Copyright © 2019 styf. All rights reserved.
//

#import "FXYAssetCell.h"
#import "FXYProgressView.h"
#import "FXYAssetModel.h"
#import "FXYImageManager.h"
#import "UIView+FXYLayout.h"
#import "FXYImagePickerController.h"
#import "UIImage+FXYBundle.h"
@interface FXYAssetCell()
@property (nonatomic, weak) UIImageView *imageView;       // The photo / 照片
@property (nonatomic, weak) UIImageView *selectImageView;
@property (nonatomic, weak) UILabel *indexLabel;
@property (nonatomic, weak) UIView *bottomView;
@property (nonatomic, weak) UILabel *timeLength;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, weak) UIImageView *videoImgView;
@property (nonatomic, strong) FXYProgressView *progressView;
/// 大图的请求标识
@property (nonatomic, assign) int32_t bigImageRequestID;
@end
@implementation FXYAssetCell

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload:) name:@"FXY_PHOTO_PICKER_RELOAD_NOTIFICATION" object:nil];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - overwrite

- (void)layoutSubviews {
    [super layoutSubviews];
    _cannotSelectLayerButton.frame = self.bounds;
    if (self.allowPreview) {
        _selectPhotoButton.frame = CGRectMake(self.fxy_width - 44, 0, 44, 44);
    } else {
        _selectPhotoButton.frame = self.bounds;
    }
    _selectImageView.frame = CGRectMake(self.fxy_width - 27, 3, 24, 24);
    if (_selectImageView.image.size.width <= 27) {
        _selectImageView.contentMode = UIViewContentModeCenter;
    } else {
        _selectImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    _indexLabel.frame = _selectImageView.frame;
    _imageView.frame = CGRectMake(0, 0, self.fxy_width, self.fxy_height);
    
    static CGFloat progressWH = 20;
    CGFloat progressXY = (self.fxy_width - progressWH) / 2;
    _progressView.frame = CGRectMake(progressXY, progressXY, progressWH, progressWH);
    
    _bottomView.frame = CGRectMake(0, self.fxy_height - 17, self.fxy_width, 17);
    _videoImgView.frame = CGRectMake(8, 0, 17, 17);
    _timeLength.frame = CGRectMake(self.videoImgView.fxy_right, 0, self.fxy_width - self.videoImgView.fxy_right - 5, 17);
    
    self.type = (NSInteger)self.model.type;
    self.showSelectBtn = self.showSelectBtn;
    
    [self.contentView bringSubviewToFront:_bottomView];
    [self.contentView bringSubviewToFront:_cannotSelectLayerButton];
    [self.contentView bringSubviewToFront:_selectPhotoButton];
    [self.contentView bringSubviewToFront:_selectImageView];
    [self.contentView bringSubviewToFront:_indexLabel];
}

#pragma mark - notification

/**
 刷新序号和不可选的遮罩

 @param noti 通知
 */
- (void)reload:(NSNotification *)noti {
    FXYImagePickerController *tzImagePickerVc = (FXYImagePickerController *)noti.object;
    if (self.model.isSelected && tzImagePickerVc.showSelectedIndex) {
        self.index = [tzImagePickerVc.selectedAssetIds indexOfObject:self.model.asset.localIdentifier] + 1;
    }
    self.indexLabel.hidden = !self.selectPhotoButton.isSelected;
    if (tzImagePickerVc.selectedModels.count >= tzImagePickerVc.maxImagesCount && tzImagePickerVc.showPhotoCannotSelectLayer && !self.model.isSelected) {
        self.cannotSelectLayerButton.backgroundColor = tzImagePickerVc.cannotSelectLayerColor;
        self.cannotSelectLayerButton.hidden = NO;
    } else {
        self.cannotSelectLayerButton.hidden = YES;
    }
}

#pragma mark - event response

/**
 选中、取消选中图片

 @param sender 选中按钮
 */
- (void)selectPhotoButtonClick:(UIButton *)sender {
    if (self.didSelectPhotoBlock) {
        self.didSelectPhotoBlock(sender.isSelected);
    }
    self.selectImageView.image = sender.isSelected ? self.photoSelImage : self.photoDefImage;
    if (sender.isSelected) {
        [UIView showOscillatoryAnimationWithLayer:_selectImageView.layer type:FXYOscillatoryAnimationToBigger];
        // 用户选中了该图片，提前获取一下大图
        [self requestBigImage];
    } else { // 取消选中，取消大图的获取
        [self cancelBigImageRequest];
    }
}

/// 只在单选状态且allowPreview为NO时会有该事件
- (void)didTapImageView {
    if (self.didSelectPhotoBlock) {
        self.didSelectPhotoBlock(NO);
    }
}

#pragma mark - private

- (void)hideProgressView {
    if (_progressView) {
        self.progressView.hidden = YES;
        self.imageView.alpha = 1.0;
    }
}

/**
 请求大图
 */
- (void)requestBigImage {
    if (_bigImageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:_bigImageRequestID];
    }
    
    _bigImageRequestID = [[FXYImageManager manager] requestImageDataForAsset:_model.asset completion:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        [self hideProgressView];
    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        if (self.model.isSelected) {
            progress = progress > 0.02 ? progress : 0.02;;
            self.progressView.progress = progress;
            self.progressView.hidden = NO;
            self.imageView.alpha = 0.4;
            if (progress >= 1) {
                [self hideProgressView];
            }
        } else {
            // 快速连续点几次，会EXC_BAD_ACCESS...
            // *stop = YES;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [self cancelBigImageRequest];
        }
    }];
}

/**
 取消大图请求
 */
- (void)cancelBigImageRequest {
    if (_bigImageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:_bigImageRequestID];
    }
    [self hideProgressView];
}

#pragma mark - getter and setter

- (void)setModel:(FXYAssetModel *)model {
    _model = model;
    self.representedAssetIdentifier = model.asset.localIdentifier;
    int32_t imageRequestID = [[FXYImageManager manager] getPhotoWithAsset:model.asset photoWidth:self.fxy_width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        // Set the cell's thumbnail image if it's still showing the same asset.
        if ([self.representedAssetIdentifier isEqualToString:model.asset.localIdentifier]) {
            self.imageView.image = photo;
        } else {
            // NSLog(@"this cell is showing other asset");
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        }
        if (!isDegraded) {
            [self hideProgressView];
            self.imageRequestID = 0;
        }
    } progressHandler:nil networkAccessAllowed:NO];
    if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        // NSLog(@"cancelImageRequest %d",self.imageRequestID);
    }
    self.imageRequestID = imageRequestID;
    self.selectPhotoButton.selected = model.isSelected;
    self.selectImageView.image = self.selectPhotoButton.isSelected ? self.photoSelImage : self.photoDefImage;
    self.indexLabel.hidden = !self.selectPhotoButton.isSelected;
    
    self.type = (NSInteger)model.type;
    // 让宽度/高度小于 最小可选照片尺寸 的图片不能选中
    if (![[FXYImageManager manager] isPhotoSelectableWithAsset:model.asset]) {
        if (_selectImageView.hidden == NO) {
            self.selectPhotoButton.hidden = YES;
            _selectImageView.hidden = YES;
        }
    }
    // 如果用户选中了该图片，提前获取一下大图
    if (model.isSelected) {
        [self requestBigImage];
    } else {
        [self cancelBigImageRequest];
    }
    [self setNeedsLayout];
    
}

- (void)setIndex:(NSInteger)index {
    _index = index;
    self.indexLabel.text = [NSString stringWithFormat:@"%zd", index];
    [self.contentView bringSubviewToFront:self.indexLabel];
}

- (void)setShowSelectBtn:(BOOL)showSelectBtn {
    _showSelectBtn = showSelectBtn;
    BOOL selectable = [[FXYImageManager manager] isPhotoSelectableWithAsset:self.model.asset];
    if (!self.selectPhotoButton.hidden) {
        self.selectPhotoButton.hidden = !showSelectBtn || !selectable;
    }
    if (!self.selectImageView.hidden) {
        self.selectImageView.hidden = !showSelectBtn || !selectable;
    }
}

- (void)setType:(FXYAssetCellType)type {
    _type = type;
    if (type == FXYAssetCellTypePhoto || type == FXYAssetCellTypeLivePhoto || (type == FXYAssetCellTypePhotoGif && !self.allowPickingGif) || self.allowPickingMultipleVideo) {
        _selectImageView.hidden = NO;
        _selectPhotoButton.hidden = NO;
        _bottomView.hidden = YES;
    } else { // Video of Gif
        _selectImageView.hidden = YES;
        _selectPhotoButton.hidden = YES;
    }
    
    if (type == FXYAssetCellTypeVideo) {
        self.bottomView.hidden = NO;
        self.timeLength.text = _model.timeLength;
        self.videoImgView.hidden = NO;
        _timeLength.fxy_left = self.videoImgView.fxy_right;
        _timeLength.textAlignment = NSTextAlignmentRight;
    } else if (type == FXYAssetCellTypePhotoGif && self.allowPickingGif) {
        self.bottomView.hidden = NO;
        self.timeLength.text = @"GIF";
        self.videoImgView.hidden = YES;
        _timeLength.fxy_left = 5;
        _timeLength.textAlignment = NSTextAlignmentLeft;
    }
}

- (void)setAllowPreview:(BOOL)allowPreview {
    _allowPreview = allowPreview;
    if (allowPreview) {
        _imageView.userInteractionEnabled = NO;
        _tapGesture.enabled = NO;
    } else {
        _imageView.userInteractionEnabled = YES;
        _tapGesture.enabled = YES;
    }
}

- (UIButton *)selectPhotoButton {
    if (_selectPhotoButton == nil) {
        UIButton *selectPhotoButton = [[UIButton alloc] init];
        [selectPhotoButton addTarget:self action:@selector(selectPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:selectPhotoButton];
        _selectPhotoButton = selectPhotoButton;
    }
    return _selectPhotoButton;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        _imageView = imageView;
        
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImageView)];
        [_imageView addGestureRecognizer:_tapGesture];
    }
    return _imageView;
}

- (UIImageView *)selectImageView {
    if (_selectImageView == nil) {
        UIImageView *selectImageView = [[UIImageView alloc] init];
        selectImageView.contentMode = UIViewContentModeCenter;
        selectImageView.clipsToBounds = YES;
        [self.contentView addSubview:selectImageView];
        _selectImageView = selectImageView;
    }
    return _selectImageView;
}

- (UIView *)bottomView {
    if (_bottomView == nil) {
        UIView *bottomView = [[UIView alloc] init];
        static NSInteger rgb = 0;
        bottomView.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.8];
        [self.contentView addSubview:bottomView];
        _bottomView = bottomView;
    }
    return _bottomView;
}

- (UIButton *)cannotSelectLayerButton {
    if (_cannotSelectLayerButton == nil) {
        UIButton *cannotSelectLayerButton = [[UIButton alloc] init];
        [self.contentView addSubview:cannotSelectLayerButton];
        _cannotSelectLayerButton = cannotSelectLayerButton;
    }
    return _cannotSelectLayerButton;
}

- (UIImageView *)videoImgView {
    if (_videoImgView == nil) {
        UIImageView *videoImgView = [[UIImageView alloc] init];
        [videoImgView setImage:[UIImage fxy_imageNamedFromMyBundle:@"VideoSendIcon"]];
        [self.bottomView addSubview:videoImgView];
        _videoImgView = videoImgView;
    }
    return _videoImgView;
}

- (UILabel *)timeLength {
    if (_timeLength == nil) {
        UILabel *timeLength = [[UILabel alloc] init];
        timeLength.font = [UIFont boldSystemFontOfSize:11];
        timeLength.textColor = [UIColor whiteColor];
        timeLength.textAlignment = NSTextAlignmentRight;
        [self.bottomView addSubview:timeLength];
        _timeLength = timeLength;
    }
    return _timeLength;
}

- (UILabel *)indexLabel {
    if (_indexLabel == nil) {
        UILabel *indexLabel = [[UILabel alloc] init];
        indexLabel.font = [UIFont systemFontOfSize:14];
        indexLabel.textColor = [UIColor whiteColor];
        indexLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:indexLabel];
        _indexLabel = indexLabel;
    }
    return _indexLabel;
}

- (FXYProgressView *)progressView {
    if (_progressView == nil) {
        _progressView = [[FXYProgressView alloc] init];
        _progressView.hidden = YES;
        [self addSubview:_progressView];
    }
    return _progressView;
}

@end
