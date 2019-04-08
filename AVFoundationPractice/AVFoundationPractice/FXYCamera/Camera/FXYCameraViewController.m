//
//  FXYCameraViewController.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/15.
//  Copyright © 2019 styf. All rights reserved.
//

#import "FXYCameraViewController.h"
#import "FXYCameraManager.h"
#import "FXYCircleProgressView.h"
#import "OMAssetsLibraryTool.h"
#import "FXYPhotoCell.h"
#import "FXYImagePickerController.h"
#import "UIView+FXYLayout.h"
@interface FXYCameraViewController ()<FXYCameraManagerDelegate,UICollectionViewDelegate,UICollectionViewDataSource> {
    NSMutableArray *_dataArray;
}
/// 相机管理器
@property (nonatomic,strong) FXYCameraManager *cameraManager;
/// 预览图层
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
/// 底部视图
@property (nonatomic, strong) UIView *bottomView;
/// 拍摄按钮
@property (nonatomic,strong) FXYCircleProgressView *progressView;
/// 图片数量上限文案
@property (nonatomic, strong) UILabel *imageLimitLabel;
/// 关闭按钮
@property (nonatomic,strong) UIButton *closeButton;
/// 切换摄像头按钮
@property (nonatomic,strong) UIButton *switchCameraButton;
/// 手电筒按钮
@property (nonatomic,strong) UIButton *torchButton;
/// 闪光灯按钮
@property (nonatomic,strong) UIButton *flashButton;
/// 比例按钮
@property (nonatomic, strong) UIButton *rateButton;

// 对焦和曝光
/// 对焦动画视图
@property (nonatomic,strong) UIView *focusBox;
/// 曝光动画视图
@property (nonatomic,strong) UIView *exposureBox;
/// 单击对焦
@property (nonatomic,strong) UITapGestureRecognizer *singleTapRecognizer;
/// 双击曝光
@property (nonatomic,strong) UITapGestureRecognizer *doubleTapRecognizer;
/// 双指双击复原
@property (nonatomic,strong) UITapGestureRecognizer *doubleDoubleTapRecognizer;

/// 拍摄的照片列表
@property (nonatomic, strong) UICollectionView *collectionView;
/// 图片剩余可拍的数量
@property (nonatomic, assign) NSInteger maxImagesCount;
@end

@implementation FXYCameraViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

/**
 初始化
 */
- (void)commonInit {
    _dataArray = @[].mutableCopy;
    NSError *error;
    if ([self.cameraManager setupSession:&error]) {
        [self.view.layer addSublayer:self.videoPreviewLayer];
        [self setupRate:NO];
        [self.cameraManager startSession];
    } else {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    [self setupUI];
    self.progressView.needAnimation = YES;
    FXYImagePickerController *nav = (FXYImagePickerController *)self.navigationController;
    self.maxImagesCount = nav.maxImagesCount;
    self.progressView.numberText = [NSString stringWithFormat:@"%ld",(long)self.maxImagesCount];
}

- (void)dealloc {
    NSLog(@"%@ dealloc",NSStringFromClass(self.class));
    [self.cameraManager stopSession];
}

/**
 设置视图
 */
- (void)setupUI {
    [self.navigationController setNavigationBarHidden:YES];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.bottomView];
    [self.bottomView addSubview:self.progressView];
    [self.bottomView addSubview:self.closeButton];
    [self.bottomView addSubview:self.imageLimitLabel];
    [self.view addSubview:self.switchCameraButton];
    [self.view addSubview:self.torchButton];
    [self.view addSubview:self.flashButton];
    [self.view addSubview:self.rateButton];
    [self.view addSubview:self.collectionView];
    
    [self.view addGestureRecognizer:self.singleTapRecognizer];
    [self.view addGestureRecognizer:self.doubleTapRecognizer];
    [self.view addGestureRecognizer:self.doubleDoubleTapRecognizer];
    [self.view addSubview:self.focusBox];
    [self.view addSubview:self.exposureBox];
}

#pragma mark - overwrite

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - public

#pragma mark - notification

#pragma mark - event response

/**
 关闭页面
 */
- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 切换摄像头
 */
- (void)switchCamera {
    [self.cameraManager switchCameras];
}

/**
 切换手电筒
 */
- (void)switchTorchMode {
    self.cameraManager.torchMode = (self.cameraManager.torchMode != AVCaptureTorchModeOn);
    [_torchButton setTitle:[self torchStatus] forState:UIControlStateNormal];
}

/**
 切换闪光灯
 */
- (void)switchFlashMode {
    self.cameraManager.flashMode = (self.cameraManager.flashMode != AVCaptureFlashModeOn);
    [_flashButton setTitle:[self flashStatus] forState:UIControlStateNormal];
}

/**
 单击对焦
 */
- (void)handleSingleTap:(UIGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self.view];
    [self runBoxAnimationOnView:self.focusBox point:point];
    [self.cameraManager focusAtPoint:[self.videoPreviewLayer captureDevicePointOfInterestForPoint:point]];
}

/**
 双击曝光
 */
- (void)handleDoubleTap:(UIGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self.view];
    [self runBoxAnimationOnView:self.exposureBox point:point];
    [self.cameraManager exposeAtPoint:[self.videoPreviewLayer captureDevicePointOfInterestForPoint:point]];
}

/**
 双指双击复原
 */
- (void)handleDoubleDoubleTap:(UIGestureRecognizer *)recognizer {
    [self runResetAnimation];
    [self.cameraManager resetFocusAndExposureModes];
}

/**
 改变比例
 */
- (void)changeRate:(UIButton *)button {
    button.selected = !button.selected;
    [self setupRate:button.selected];
}

#pragma mark - private

/**
 设置拍摄比例

 @param isSquare 是否正方形
 */
- (void)setupRate:(BOOL)isSquare {
    CGFloat height43 = floor(ScreenWidth * 4 / 3.0);
    CGFloat bottomHeight = ScreenHeight - height43;
    CGRect rect43 = CGRectMake(0, 0, ScreenWidth, height43);
    CGRect rect11 = CGRectMake(0, ScreenHeight - bottomHeight - ScreenWidth, ScreenWidth, ScreenWidth);
    _videoPreviewLayer.frame = isSquare ? rect11 : rect43;
}

- (NSString *)torchStatus {
    switch (self.cameraManager.torchMode) {
        case AVCaptureTorchModeOff:
            return @"手电筒:Off";
        case AVCaptureTorchModeOn:
            return @"手电筒:On";
        default:
            return @"手电筒:Auto";
    }
}

- (NSString *)flashStatus {
    switch (self.cameraManager.flashMode) {
        case AVCaptureFlashModeOff:
            return @"闪光灯:Off";
        case AVCaptureFlashModeOn:
            return @"闪光灯:On";
        default:
            return @"闪光灯:Auto";
    }
}

/**
 对焦、曝光动画
 */
- (void)runBoxAnimationOnView:(UIView *)view point:(CGPoint)point {
    view.center = point;
    view.hidden = NO;
    [UIView animateWithDuration:0.15f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
                     }
                     completion:^(BOOL complete) {
                         double delayInSeconds = 0.5f;
                         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                             view.hidden = YES;
                             view.transform = CGAffineTransformIdentity;
                         });
                     }];
}

/**
 重置对焦、曝光动画
 */
- (void)runResetAnimation {
    
    CGPoint centerPoint = [self.videoPreviewLayer pointForCaptureDevicePointOfInterest:CGPointMake(0.5f, 0.5f)];
    self.focusBox.center = centerPoint;
    self.exposureBox.center = centerPoint;
    self.exposureBox.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    self.focusBox.hidden = NO;
    self.exposureBox.hidden = NO;
    [UIView animateWithDuration:0.15f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.focusBox.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
                         self.exposureBox.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1.0);
                     }
                     completion:^(BOOL complete) {
                         double delayInSeconds = 0.5f;
                         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                             self.focusBox.hidden = YES;
                             self.exposureBox.hidden = YES;
                             self.focusBox.transform = CGAffineTransformIdentity;
                             self.exposureBox.transform = CGAffineTransformIdentity;
                         });
                     }];
}

/**
 创建一个方形图层
 */
- (CAShapeLayer *)makeBoundsLayer {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = [UIColor colorWithRed:0.95f green:0.75f blue:0.06f alpha:1.0f].CGColor;
    shapeLayer.fillColor = nil;
    shapeLayer.lineWidth = 4.0f;
    return shapeLayer;
}

- (CAShapeLayer *)makeCornersLayer {
    CAShapeLayer *cornersLayer = [CAShapeLayer layer];
    cornersLayer.lineWidth = 2.0f;
    cornersLayer.strokeColor = [UIColor colorWithRed:0.172 green:0.671 blue:0.428 alpha:1.000].CGColor;
    cornersLayer.fillColor = [UIColor colorWithRed:0.190 green:0.753 blue:0.489 alpha:0.500].CGColor;
    return cornersLayer;
}

- (UIBezierPath *)bezierPathForBounds:(CGRect)bounds {
    return [UIBezierPath bezierPathWithRect:bounds];
}

- (UIBezierPath *)bezierPathForCorners:(NSArray *)corners {
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (int i = 0; i < corners.count; i++) {
        CGPoint point = [self pointForCorner:corners[i]];
        if (i == 0) {
            [path moveToPoint:point];
        } else {
            [path addLineToPoint:point];
        }
    }
    [path closePath];
    return path;
}

/**
 字典转点
 */
- (CGPoint)pointForCorner:(NSDictionary *)corner {
    NSLog(@"%@", corner);
    CGPoint point;
    CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)corner, &point);
    return point;
}

/**
 裁剪图片

 @param image 原图
 @param rect 裁剪大小
 @return 裁剪后的图
 */
- (UIImage *)imageByCropImage:(UIImage *)image toRect:(CGRect)rect {
    rect.origin.x *= image.scale;
    rect.origin.y *= image.scale;
    rect.size.width *= image.scale;
    rect.size.height *= image.scale;
    if (rect.size.width <= 0 || rect.size.height <= 0) return nil;
    
    CGFloat (^rad)(CGFloat) = ^CGFloat(CGFloat deg) {
        return deg / 180.0f * (CGFloat) M_PI;
    };
    
    // determine the orientation of the image and apply a transformation to the crop rectangle to shift it to the correct position
    CGAffineTransform rectTransform;
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(90)), 0, -image.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-90)), -image.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-180)), -image.size.width, -image.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    
    // adjust the transformation scale based on the image scale
    rectTransform = CGAffineTransformScale(rectTransform, image.scale, image.scale);
    
    // apply the transformation to the rect to create a new, shifted rect
    CGRect transformedCropSquare = CGRectApplyAffineTransform(rect, rectTransform);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, transformedCropSquare);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    return newImage;
}
#pragma mark - FXYCameraManagerDelegate
/**
 拍照
 */
- (void)captureStillImage:(UIImage *)image {
    CGFloat imageWidth = image.size.width * image.scale;
    CGFloat imageHeight = image.size.height * image.scale;
    CGFloat heighScale = imageHeight / [UIScreen mainScreen].bounds.size.height;
    CGRect cropFrame = CGRectMake(0, ([UIScreen mainScreen].bounds.size.height - self.videoPreviewLayer.frame.size.height) * 0.5 * heighScale, imageWidth, imageWidth * self.videoPreviewLayer.frame.size.height / self.videoPreviewLayer.frame.size.width);
//    NSLog(@"=============>%f %f %f %@ %@",image.size.width,image.size.height,image.scale,NSStringFromCGRect(self.videoPreviewLayer.frame),NSStringFromCGRect(cropFrame));
    UIImage *cropImage = [self imageByCropImage:image toRect:cropFrame];
//    [OMAssetsLibraryTool writeImageToAssetsLibrary:cropImage withCompletionHandler:^(id  _Nullable obj, NSError * _Nullable error) {
//        NSLog(@"拍照结束!");
        [self->_dataArray addObject:cropImage];
        [self.collectionView reloadData];
//    }];
    
    //拍照成功，显示剩余可拍的数量
    self.progressView.numberText = [NSString stringWithFormat:@"%ld",(long)(--self.maxImagesCount)];
    self.imageLimitLabel.hidden = (self.maxImagesCount > 0);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FXYPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FXYPhotoCell" forIndexPath:indexPath];
    cell.image = _dataArray[indexPath.row];
    return cell;
}

#pragma mark - getter and setter

- (FXYCameraManager *)cameraManager {
    if (!_cameraManager) {
        _cameraManager = [[FXYCameraManager alloc]init];
        _cameraManager.delegate = self;
    }
    return _cameraManager;
}

- (AVCaptureVideoPreviewLayer *)videoPreviewLayer {
    if (!_videoPreviewLayer) {
        _videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.cameraManager.captureSession];
        [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    }
    return _videoPreviewLayer;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        CGFloat height43 = floor(ScreenWidth * 4 / 3.0);
        CGFloat bottomHeight = ScreenHeight - height43;
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight - bottomHeight, ScreenWidth, bottomHeight)];
        _bottomView.backgroundColor = [UIColor whiteColor];
    }
    return _bottomView;
}

- (FXYCircleProgressView *)progressView {
    if (!_progressView) {
        CGFloat height43 = floor(ScreenWidth * 4 / 3.0);
        CGFloat bottomHeight = ScreenHeight - height43;
        _progressView = [[FXYCircleProgressView alloc]initWithFrame:CGRectMake(ScreenWidth * 0.5 - 40, bottomHeight * 0.5 - 40, 80, 80)];
        WEAKSELF
        _progressView.clickBlock = ^(void) {
            STRONGSELF
            if (strongSelf.maxImagesCount > 0) {
                [strongSelf.cameraManager captureStillImage];//拍照
            }
        };
        _progressView.startBlock = ^{
            STRONGSELF
            [strongSelf.cameraManager startRecording];
        };
        _progressView.endBlock = ^{
            STRONGSELF
            [strongSelf.cameraManager stopRecording];
        };
    }
    return _progressView;
}

- (UILabel *)imageLimitLabel {
    if (!_imageLimitLabel) {
        _imageLimitLabel = [[UILabel alloc]init];
        _imageLimitLabel.textColor = [UIColor blackColor];
        _imageLimitLabel.text = @"图片数量已达上限";
        [_imageLimitLabel sizeToFit];
        _imageLimitLabel.fxy_centerX = self.progressView.fxy_centerX;
        _imageLimitLabel.fxy_top = self.progressView.fxy_bottom + 10;
        _imageLimitLabel.hidden = YES;
    }
    return _imageLimitLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"close_arrow"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        _closeButton.frame = CGRectMake(70, 0, 30, 30);
        _closeButton.centerY = self.progressView.centerY;
    }
    return _closeButton;
}

- (UIButton *)switchCameraButton {
    if (!_switchCameraButton) {
        _switchCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchCameraButton setImage:[UIImage imageNamed:@"camera_icon"] forState:UIControlStateNormal];
        [_switchCameraButton addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
        _switchCameraButton.frame = CGRectMake(ScreenWidth - 50, 30, 28, 21);
    }
    return _switchCameraButton;
}

- (UIButton *)torchButton {
    if (!_torchButton) {
        _torchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_torchButton setTitle:[self torchStatus] forState:UIControlStateNormal];
        [_torchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_torchButton addTarget:self action:@selector(switchTorchMode) forControlEvents:UIControlEventTouchUpInside];
        _torchButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _torchButton.frame = CGRectMake(30, 30, 80, 30);
    }
    return _torchButton;
}

- (UIButton *)flashButton {
    if (!_flashButton) {
        _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flashButton setTitle:[self flashStatus] forState:UIControlStateNormal];
        [_flashButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_flashButton addTarget:self action:@selector(switchFlashMode) forControlEvents:UIControlEventTouchUpInside];
        _flashButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _flashButton.frame = CGRectMake(110, 30, 80, 30);
    }
    return _flashButton;
}

- (UITapGestureRecognizer *)singleTapRecognizer {
    if (!_singleTapRecognizer) {
        _singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [_singleTapRecognizer requireGestureRecognizerToFail:self.doubleTapRecognizer];
        _singleTapRecognizer.enabled = self.cameraManager.cameraSupportsTapToFocus;
    }
    return _singleTapRecognizer;
}

- (UITapGestureRecognizer *)doubleTapRecognizer {
    if (!_doubleTapRecognizer) {
#warning 手势target不对，可能要加一个手势层，或者判断点是否在预览图层上
        _doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        _doubleTapRecognizer.numberOfTapsRequired = 2;
        _doubleTapRecognizer.enabled = self.cameraManager.cameraSupportsTapToExpose;
    }
    return _doubleTapRecognizer;
}

- (UITapGestureRecognizer *)doubleDoubleTapRecognizer {
    if (!_doubleDoubleTapRecognizer) {
        _doubleDoubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleDoubleTap:)];
        _doubleDoubleTapRecognizer.numberOfTapsRequired = 2;
        _doubleDoubleTapRecognizer.numberOfTouchesRequired = 2;
        _doubleDoubleTapRecognizer.enabled = self.singleTapRecognizer.enabled || self.doubleTapRecognizer.enabled;
    }
    return _doubleDoubleTapRecognizer;
}

- (UIView *)focusBox {
    if (!_focusBox) {
        _focusBox = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 150, 150.0f)];
        _focusBox.backgroundColor = [UIColor clearColor];
        _focusBox.layer.borderColor = [UIColor colorWithRed:0.102 green:0.636 blue:1.000 alpha:1.000].CGColor;
        _focusBox.layer.borderWidth = 5.0f;
        _focusBox.hidden = YES;
    }
    return _focusBox;
}

- (UIView *)exposureBox {
    if (!_exposureBox) {
        _exposureBox = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 150, 150.0f)];
        _exposureBox.backgroundColor = [UIColor clearColor];
        _exposureBox.layer.borderColor = [UIColor colorWithRed:1.000 green:0.421 blue:0.054 alpha:1.000].CGColor;
        _exposureBox.layer.borderWidth = 5.0f;
        _exposureBox.hidden = YES;
    }
    return _exposureBox;
}

- (UIButton *)rateButton {
    if (!_rateButton) {
        _rateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_rateButton setTitle:@"3 : 4" forState:UIControlStateNormal];
        [_rateButton setTitle:@"1 : 1" forState:UIControlStateSelected];
        [_rateButton addTarget:self action:@selector(changeRate:) forControlEvents:UIControlEventTouchUpInside];
        _rateButton.backgroundColor = [UIColor whiteColor];
        _rateButton.frame = CGRectMake(ScreenWidth - 90 - 50, 30, 50, 21);
    }
    return _rateButton;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat sectionMargin = 5;
        CGFloat itemMargin = 5;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(0, sectionMargin, 0, sectionMargin);
        layout.minimumInteritemSpacing = itemMargin;
        layout.itemSize = CGSizeMake(40,40);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[FXYPhotoCell class] forCellWithReuseIdentifier:@"FXYPhotoCell"];
        CGFloat height43 = floor(ScreenWidth * 4 / 3.0);
        CGFloat bottomHeight = ScreenHeight - height43;
        CGFloat height = 50;
        _collectionView.frame = CGRectMake(0, ScreenHeight - bottomHeight - height, ScreenWidth, height);
    }
    return _collectionView;
}
@end
