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

//人脸识别
/// 浮层
@property (nonatomic,strong) CALayer *overlayLayer;
/// 人脸的层
@property (nonatomic,strong) NSMutableDictionary *faceLayers;

//机器码识别
//机器码的层
@property (nonatomic,strong) NSMutableDictionary *codeLayers;
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
        [self.view.layer addSublayer:self.videoPreviewLayer];
        [self.cameraManager startSession];
        //人脸识别图层
        [self.videoPreviewLayer addSublayer:self.overlayLayer];
    } else {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    [self setupUI];
}

- (void)dealloc {
    [self.cameraManager stopSession];
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
 应用视角转换
 */
static CATransform3D CATransform3DMakePerspective(CGFloat eyePosition) {
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0 / eyePosition;
    return transform;
}

/**
 把设备坐标空间的对象转换为视图空间对象集合
 */
- (NSArray *)transformedObjsFromObjs:(NSArray *)objs {
    NSMutableArray *transformedObjs = [NSMutableArray array];
    for (AVMetadataObject *obj in objs) {
        AVMetadataObject *transformedObj = [self.videoPreviewLayer transformedMetadataObjectForMetadataObject:obj];
        [transformedObjs addObject:transformedObj];
    }
    return transformedObjs;
}

/**
 创建一个人脸图层
 */
- (CALayer *)makeFaceLayer {
    CALayer *layer = [CALayer layer];
    layer.borderWidth = 5.0f;
    layer.borderColor =
    [UIColor colorWithRed:0.188 green:0.517 blue:0.877 alpha:1.000].CGColor;
    return layer;
}

// Rotate around Z-axis
- (CATransform3D)transformForRollAngle:(CGFloat)rollAngleInDegrees {
    CGFloat rollAngleInRadians = OMDegreesToRadians(rollAngleInDegrees);
    return CATransform3DMakeRotation(rollAngleInRadians, 0.0f, 0.0f, 1.0f);
}

// Rotate around Y-axis
- (CATransform3D)transformForYawAngle:(CGFloat)yawAngleInDegrees {
    CGFloat yawAngleInRadians = OMDegreesToRadians(yawAngleInDegrees);
    CATransform3D yawTransform = CATransform3DMakeRotation(yawAngleInRadians, 0.0f, -1.0f, 0.0f);
    return CATransform3DConcat(yawTransform, [self orientationTransform]);//需要为设备方向计算一个相应的旋转变换，否则人脸的偏转将不正确
}

- (CATransform3D)orientationTransform {
    CGFloat angle = 0.0;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case UIDeviceOrientationLandscapeRight:
            angle = -M_PI / 2.0f;
            break;
        case UIDeviceOrientationLandscapeLeft:
            angle = M_PI / 2.0f;
            break;
        default: // as UIDeviceOrientationPortrait
            angle = 0.0;
            break;
    }
    return CATransform3DMakeRotation(angle, 0.0f, 0.0f, 1.0f);
}

/**
 弧度
 */
static CGFloat OMDegreesToRadians(CGFloat degrees) {
    return degrees * M_PI / 180;
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

/**
 检测到人脸
 */
- (void)didDetectFaces:(NSArray *)faces {
    
    NSArray *transformedFaces = [self transformedObjsFromObjs:faces];
    
    NSMutableArray *lostFaces = [self.faceLayers.allKeys mutableCopy];//存放移出屏幕的人脸
    for (AVMetadataFaceObject *face in transformedFaces) {
        
        NSNumber *faceID = @(face.faceID);
        [lostFaces removeObject:faceID];
        
        CALayer *layer = [self.faceLayers objectForKey:faceID];
        if (!layer) {
            // no layer for faceID, create new face layer
            layer = [self makeFaceLayer];
            [self.overlayLayer addSublayer:layer];
            self.faceLayers[faceID] = layer;
        }
        
        layer.transform = CATransform3DIdentity;
        layer.frame = face.bounds;
        
        if (face.hasRollAngle) {
            CATransform3D t = [self transformForRollAngle:face.rollAngle];
            layer.transform = CATransform3DConcat(layer.transform, t);
        }
        
        if (face.hasYawAngle) {
            CATransform3D t = [self transformForYawAngle:face.yawAngle];
            layer.transform = CATransform3DConcat(layer.transform, t);
        }
    }
    
    for (NSNumber *faceID in lostFaces) {//移出丢失的人脸图层
        CALayer *layer = [self.faceLayers objectForKey:faceID];
        [layer removeFromSuperlayer];
        [self.faceLayers removeObjectForKey:faceID];
    }
}

/**
 检测到机器码
 */
- (void)didDetectCodes:(NSArray *)codes {
    NSArray *transformedCodes = [self transformedObjsFromObjs:codes];
    NSMutableArray *lostCodes = [self.codeLayers.allKeys mutableCopy];
    for (AVMetadataMachineReadableCodeObject *code in transformedCodes) {
        
        NSString *stringValue = code.stringValue;
        if (stringValue) {
            [lostCodes removeObject:stringValue];
        } else {
            continue;
        }
        
        NSArray *layers = self.codeLayers[stringValue];
        
        if (!layers) {
            // no layers for stringValue, create new code layers
            layers = @[[self makeBoundsLayer], [self makeCornersLayer]];
            
            self.codeLayers[stringValue] = layers;
            [self.overlayLayer addSublayer:layers[0]];
            [self.overlayLayer addSublayer:layers[1]];
        }
        
        CAShapeLayer *boundsLayer  = layers[0];
        boundsLayer.path  = [self bezierPathForBounds:code.bounds].CGPath;
        boundsLayer.hidden = NO;
        
        CAShapeLayer *cornersLayer = layers[1];
        cornersLayer.path = [self bezierPathForCorners:code.corners].CGPath;
        cornersLayer.hidden = NO;
        
        NSLog(@"String: %@", stringValue);
    }
    
    for (NSString *stringValue in lostCodes) {
        for (CALayer *layer in self.codeLayers[stringValue]) {
            [layer removeFromSuperlayer];
        }
        [self.codeLayers removeObjectForKey:stringValue];
    }
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

- (NSMutableDictionary *)faceLayers {
    if (!_faceLayers) {
        _faceLayers = @{}.mutableCopy;
    }
    return _faceLayers;
}

- (CALayer *)overlayLayer {
    if (!_overlayLayer) {
        _overlayLayer = [CALayer layer];
        _overlayLayer.frame = self.view.bounds;
        _overlayLayer.sublayerTransform = CATransform3DMakePerspective(1000);
    }
    return _overlayLayer;
}

- (NSMutableDictionary *)codeLayers {
    if (!_codeLayers) {
        _codeLayers = @{}.mutableCopy;
    }
    return _codeLayers;
}

@end
