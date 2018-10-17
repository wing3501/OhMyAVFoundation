//
//  OMCameraViewController.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2018/10/12.
//  Copyright © 2018年 styf. All rights reserved.
//

#import "OMCameraViewController.h"
#import "OMCameraManager.h"
#import "OMCircleProgressView.h"
@interface OMCameraViewController ()<OMCircleProgressViewDelegate,OMCameraManagerDelegate>
/// 相机管理器
@property (nonatomic,strong) OMCameraManager *cameraManager;
/// 预览图层
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
/// 拍摄按钮
@property (nonatomic,strong) OMCircleProgressView *progressView;
/// 关闭按钮
@property (nonatomic,strong) UIButton *closeButton;
/// 切换摄像头按钮
@property (nonatomic,strong) UIButton *switchCameraButton;
/// 手电筒按钮
@property (nonatomic,strong) UIButton *torchButton;
/// 闪光灯按钮
@property (nonatomic,strong) UIButton *flashButton;

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

// 缩放
/// 缩放手势
@property (strong, nonatomic) UIPinchGestureRecognizer *pinchGestureRecognizer;
/// 缩放变大
@property (nonatomic,strong) UIButton *zoomMaxButton;
/// 缩放变小
@property (nonatomic,strong) UIButton *zoomMinButton;
@end

@implementation OMCameraViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

/**
 初始化
 */
- (void)commonInit {
    NSError *error;
    if ([self.cameraManager setupSession:&error]) {
        [self.cameraManager startSession];
        [self.view.layer addSublayer:self.videoPreviewLayer];
    } else {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    [self setupUI];
}

/**
 设置视图
 */
- (void)setupUI {
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.progressView];
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.switchCameraButton];
    [self.view addSubview:self.torchButton];
    [self.view addSubview:self.flashButton];
    
    [self.view addGestureRecognizer:self.singleTapRecognizer];
    [self.view addGestureRecognizer:self.doubleTapRecognizer];
    [self.view addGestureRecognizer:self.doubleDoubleTapRecognizer];
    [self.view addSubview:self.focusBox];
    [self.view addSubview:self.exposureBox];
    
    [self.view addGestureRecognizer:self.pinchGestureRecognizer];
    [self.view addSubview:self.zoomMaxButton];
    [self.view addSubview:self.zoomMinButton];
}

#pragma mark - overwrite

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
 缩放
 */
static float currentScale = 1;
- (void)handlepinch:(UIPinchGestureRecognizer *)pinchGesture {
    if (UIGestureRecognizerStateBegan == pinchGesture.state ||
        UIGestureRecognizerStateChanged == pinchGesture.state) {
        
        // Use the x or y scale, they should be the same for typical zooming (non-skewing)
        // Variables to adjust the max/min values of zoom
        float minScale = 1.0;
        float maxScale = kMaxZoomFactor;
        float zoomSpeed = .5;
        
        float deltaScale = pinchGesture.scale;
        
        // You need to translate the zoom to 0 (origin) so that you
        // can multiply a speed factor and then translate back to "zoomSpace" around 1
        deltaScale = ((deltaScale - 1) * zoomSpeed) + 1;
        
        // Limit to min/max size (i.e maxScale = 2, current scale = 2, 2/2 = 1.0)
        //  A deltaScale is ~0.99 for decreasing or ~1.01 for increasing
        //  A deltaScale of 1.0 will maintain the zoom size
        deltaScale = MIN(deltaScale, maxScale / currentScale);
        deltaScale = MAX(deltaScale, minScale / currentScale);
        
        float scale = currentScale * deltaScale;
        if (scale != currentScale) {
            currentScale = scale;
            //缩放
            [self.cameraManager setZoomValue:currentScale];
        }
        
        // Reset to 1 for scale delta's
        //  Note: not 0, or we won't see a size: 0 * width = 0
        pinchGesture.scale = 1;
    }
}

/**
 缩放变大
 */
- (void)zoomMax {
    [self.cameraManager rampZoomToValue:1];
}

/**
 缩放变小
 */
- (void)zoomMin {
    [self.cameraManager rampZoomToValue:0];
}

/**
 停止缩放
 */
- (void)cancelZoom {
    [self.cameraManager cancelZoom];
}
#pragma mark - private

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

#pragma mark - OMCircleProgressViewDelegate

- (void)progressViewDidSingleTap:(OMCircleProgressView *)progressView {
    [self.cameraManager captureStillImage];//拍照
}

- (void)progressViewBeganLongPress:(OMCircleProgressView *)progressView {
    [self.cameraManager startRecording];//开始录制视频
}

- (void)progressViewStopCountDown:(OMCircleProgressView *)progressView {
    [self.cameraManager stopRecording];//停止录制视频
}

#pragma mark - OMCameraManagerDelegate

/**
 缩放回调
 
 @param value 0-1
 */
- (void)rampedZoomToValue:(CGFloat)value {
    
    NSLog(@"delegate rampedZoomToValue:%f",value);
}

#pragma mark - getter and setter

- (OMCameraManager *)cameraManager {
    if (!_cameraManager) {
        _cameraManager = [[OMCameraManager alloc]init];
        _cameraManager.delegate = self;
    }
    return _cameraManager;
}

- (AVCaptureVideoPreviewLayer *)videoPreviewLayer {
    if (!_videoPreviewLayer) {
        _videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.cameraManager.captureSession];
        _videoPreviewLayer.frame = self.view.bounds;
        [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    }
    return _videoPreviewLayer;
}

- (OMCircleProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[OMCircleProgressView alloc]initWithFrame:CGRectMake(ScreenWidth * 0.5 - 40, ScreenHeight - 120, 80, 80)];
        _progressView.delegate = self;
    }
    return _progressView;
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

- (UIPinchGestureRecognizer *)pinchGestureRecognizer {
    if (!_pinchGestureRecognizer) {
        _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlepinch:)];
    }
    return _pinchGestureRecognizer;
}

- (UIButton *)zoomMaxButton {
    if (!_zoomMaxButton) {
        _zoomMaxButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_zoomMaxButton setImage:[UIImage imageNamed:@"max_button"] forState:UIControlStateNormal];
        [_zoomMaxButton addTarget:self action:@selector(zoomMax) forControlEvents:UIControlEventTouchDown];
        [_zoomMaxButton addTarget:self action:@selector(cancelZoom) forControlEvents:UIControlEventTouchUpInside];
        _zoomMaxButton.frame = CGRectMake(30, 70, 40, 40);
    }
    return _zoomMaxButton;
}

- (UIButton *)zoomMinButton {
    if (!_zoomMinButton) {
        _zoomMinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_zoomMinButton setImage:[UIImage imageNamed:@"min_button"] forState:UIControlStateNormal];
        [_zoomMinButton addTarget:self action:@selector(zoomMin) forControlEvents:UIControlEventTouchDown];
        [_zoomMinButton addTarget:self action:@selector(cancelZoom) forControlEvents:UIControlEventTouchUpInside];
        _zoomMinButton.frame = CGRectMake(110, 70, 40, 40);
    }
    return _zoomMinButton;
}

@end
