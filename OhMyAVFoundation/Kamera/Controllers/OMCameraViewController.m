//
//  OMCameraViewController.m
//  OhMyAVFoundation
//
//  Created by 申屠云飞 on 2018/9/11.
//  Copyright © 2018年 styf. All rights reserved.
//

#import "OMCameraViewController.h"
#import "OMPreviewView.h"
#import "OMCameraController.h"
@interface OMCameraViewController ()<OMPreviewViewDelegate,OMCameraControllerDelegate>
/// 底部
@property (nonatomic,strong) UIView *bottomView;
/// 按钮
@property (nonatomic,strong) UIButton *cameraButton;
/// 预览视图
@property (nonatomic,strong) OMPreviewView *previewView;
/// 相机控制器
@property (nonatomic,strong) OMCameraController *cameraController;
/// 照片预览图
@property (nonatomic,strong) UIImageView *imagePreviewView;
@end

@implementation OMCameraViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSError *error;
    [self.cameraController setupSession:&error];
    [self.view addSubview:self.previewView];
    [self.view addSubview:self.bottomView];
    [self.bottomView addSubview:self.cameraButton];
    [self.bottomView addSubview:self.imagePreviewView];
    
    [self.cameraController startSession];
    
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(updateThumbnail:) name:OMThumbnailCreatedNotication object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.cameraController stopSession];
}

- (void)dealloc {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

#pragma mark - overwrite

#pragma mark - public

#pragma mark - notification

- (void)updateThumbnail:(NSNotification *)notif {
    self.imagePreviewView.image = notif.object;
}

#pragma mark - event response

- (void)capture {
    [self.cameraController captureStillImage];
}

#pragma mark - private

#pragma mark - OMPreviewViewDelegate

- (void)tappedToFocusAtPoint:(CGPoint)point {
    
}

- (void)tappedToExposeAtPoint:(CGPoint)point {
    
}

- (void)tappedToResetFocusAndExposure {
    
}

#pragma mark - OMCameraControllerDelegate

- (void)deviceConfigurationFailedWithError:(NSError *)error {
    
}

- (void)mediaCaptureFailedWithError:(NSError *)error {
    
}

- (void)assetLibraryWriteFailedWithError:(NSError *)error {
    
}

#pragma mark - getter and setter

- (OMCameraController *)cameraController {
    if (!_cameraController) {
        _cameraController = [[OMCameraController alloc]init];
        _cameraController.delegate = self;
    }
    return _cameraController;
}

- (OMPreviewView *)previewView {
    if (!_previewView) {
        _previewView = [[OMPreviewView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _previewView.delegate = self;
        _previewView.session = self.cameraController.captureSession;
    }
    return _previewView;
}

- (UIButton *)cameraButton {
    if (!_cameraButton) {
        _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cameraButton.center = CGPointMake(ScreenWidth * 0.5, 40);
        _cameraButton.bounds = CGRectMake(0, 0, 28, 21);
        [_cameraButton setImage:[UIImage imageNamed:@"camera_icon"] forState:UIControlStateNormal];
        [_cameraButton addTarget:self action:@selector(capture) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraButton;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 80, ScreenWidth, 80)];
        _bottomView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    }
    return _bottomView;
}

- (UIImageView *)imagePreviewView {
    if (!_imagePreviewView) {
        _imagePreviewView = [[UIImageView alloc]initWithFrame:CGRectMake(50, 10, 60, 60)];
        _imagePreviewView.backgroundColor = [UIColor whiteColor];
    }
    return _imagePreviewView;
}
@end
