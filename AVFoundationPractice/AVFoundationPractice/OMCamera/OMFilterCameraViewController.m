//
//  OMFilterCameraViewController.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2018/10/19.
//  Copyright © 2018年 styf. All rights reserved.
//

#import "OMFilterCameraViewController.h"
#import "OMCameraManager.h"
#import "OMCircleProgressView.h"
#import "OMPreviewView.h"
#import "OMContextManager.h"
#import "OMPhotoFilters.h"
@interface OMFilterCameraViewController ()<OMCircleProgressViewDelegate,OMCameraManagerDelegate>
/// 相机管理器
@property (nonatomic,strong) OMCameraManager *cameraManager;
/// 预览图层
@property (nonatomic,strong) OMPreviewView *previewView;
/// 拍摄按钮
@property (nonatomic,strong) OMCircleProgressView *progressView;
/// 切换滤镜
@property (nonatomic,strong) UIButton *filterButton;
/// 滤镜下标
@property (nonatomic,assign) NSInteger filterIndex;
/// 关闭按钮
@property (nonatomic,strong) UIButton *closeButton;
@end

@implementation OMFilterCameraViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

/**
 初始化
 */
- (void)commonInit {
    [self setupUI];
    
    NSError *error;
    if ([self.cameraManager setupSession:&error]) {
        [self.cameraManager startSession];
        
    } else {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
}

/**
 设置视图
 */
- (void)setupUI {
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.previewView];
    [self.view addSubview:self.progressView];
    [self.view addSubview:self.filterButton];
    [self.view addSubview:self.closeButton];
    
}

/**
 切换滤镜
 */
- (void)changeFilter {
    NSArray *array = [OMPhotoFilters filterNames];
    _filterIndex++;
    if (_filterIndex == array.count) {
        _filterIndex = 0;
    }
    NSString *name = array[_filterIndex];
    [_filterButton setTitle:name forState:UIControlStateNormal];
    CIFilter *filter = [OMPhotoFilters filterForDisplayName:name];
    [[NSNotificationCenter defaultCenter]postNotificationName:OMFilterSelectionChangedNotification object:filter];
}

/**
 关闭页面
 */
- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - OMCircleProgressViewDelegate

- (void)progressViewDidSingleTap:(OMCircleProgressView *)progressView {
    
}

- (void)progressViewBeganLongPress:(OMCircleProgressView *)progressView {
    if (!self.cameraManager.isRecording) {
        dispatch_async(dispatch_queue_create("com.tapharmonic.kamera", NULL), ^{
            [self.cameraManager startRecording];
        });
    }
}

- (void)progressViewStopCountDown:(OMCircleProgressView *)progressView {
    [self.cameraManager stopRecording];//停止录制视频
}

#pragma mark - OMCameraManagerDelegate

/**
 捕捉到视频帧
 */
- (void)captureVideoSample:(CIImage *)image {
    [self.previewView setImage:image];
}

#pragma mark - getter and setter

- (OMCameraManager *)cameraManager {
    if (!_cameraManager) {
        _cameraManager = [[OMCameraManager alloc]init];
        _cameraManager.delegate = self;
    }
    return _cameraManager;
}

- (OMCircleProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[OMCircleProgressView alloc]initWithFrame:CGRectMake(ScreenWidth * 0.5 - 40, ScreenHeight - 120, 80, 80)];
        _progressView.delegate = self;
    }
    return _progressView;
}

- (OMPreviewView *)previewView {
    if (!_previewView) {
        EAGLContext *eaglContext = [OMContextManager sharedOMContextManager].eaglContext;
        _previewView = [[OMPreviewView alloc] initWithFrame:self.view.bounds context:eaglContext];
        _previewView.filter = [OMPhotoFilters defaultFilter];
        _previewView.coreImageContext = [OMContextManager sharedOMContextManager].ciContext;
    }
    return _previewView;
}

- (UIButton *)filterButton {
    if (!_filterButton) {
        _filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _filterButton.frame = CGRectMake(60, 60, 250, 50);
        [_filterButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_filterButton addTarget:self action:@selector(changeFilter) forControlEvents:UIControlEventTouchUpInside];
        [_filterButton setTitle:[OMPhotoFilters filterNames].firstObject forState:UIControlStateNormal];
    }
    return _filterButton;
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
@end
