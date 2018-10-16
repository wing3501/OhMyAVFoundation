//
//  OMCameraManager.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2018/10/12.
//  Copyright © 2018年 styf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMCameraManager.h"
#import <AVFoundation/AVFoundation.h>
#import "OMAssetsLibraryTool.h"
#import "NSFileManager+Ext.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@interface OMCameraManager()<AVCapturePhotoCaptureDelegate,AVCaptureFileOutputRecordingDelegate>
/// 静态图输出
@property (nonatomic,strong) AVCapturePhotoOutput *imageOutput;
#else
@interface OMCameraManager()<AVCaptureFileOutputRecordingDelegate>
/// 静态图输出
@property (nonatomic,strong) AVCaptureStillImageOutput *imageOutput;
#endif

/// 捕捉会话
@property (nonatomic,strong) AVCaptureSession *captureSession;
/// 当前活跃的设备输入
@property (nonatomic,weak) AVCaptureDeviceInput *activeVideoInput;
/// 视频输出
@property (nonatomic,strong) AVCaptureMovieFileOutput *movieOutput;
/// 视频输出URL
@property (nonatomic,strong) NSURL *outputURL;
/// 视频队列
@property (nonatomic,strong) dispatch_queue_t videoQueue;
@end

@implementation OMCameraManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _videoQueue = dispatch_queue_create("com.styf.OhMyAVFoundation", NULL);
    }
    return self;
}
#pragma mark - Session Configuration
/**
 初始化会话
 
 @param error 错误
 @return 是否初始化成功
 */
- (BOOL)setupSession:(NSError **)error {
    self.captureSession = [[AVCaptureSession alloc]init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    //设置默认相机设备
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    if (videoInput) {
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        }
    }else{
        return NO;
    }
    
    //设置默认的麦克风设备
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:error];
    if (audioInput) {
        if ([self.captureSession canAddInput:audioInput]) {
            [self.captureSession addInput:audioInput];
        }
    } else {
        return NO;
    }
    
    //设置静态图输出
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    if (@available(iOS 10.0, *)) {
        self.imageOutput = [[AVCapturePhotoOutput alloc] init];
    }
#else
    self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
    self.imageOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
#endif
    if ([self.captureSession canAddOutput:self.imageOutput]) {
        [self.captureSession addOutput:self.imageOutput];
    }
    
    //设置视频文件输出
    self.movieOutput = [[AVCaptureMovieFileOutput alloc] init];
//    self.movieOutput.movieFragmentInterval = CMTimeMake(10, 1);//每隔10秒写入片段
    if ([self.captureSession canAddOutput:self.movieOutput]) {
        [self.captureSession addOutput:self.movieOutput];
    }
    
    return YES;
}

/**
 启动捕捉会话
 */
- (void)startSession {
    if (![self.captureSession isRunning]) {
        WEAKSELF
        dispatch_async(self.videoQueue, ^{
            STRONGSELF
            [strongSelf.captureSession startRunning];
        });
    }
}

/**
 停止捕捉会话
 */
- (void)stopSession {
    if ([self.captureSession isRunning]) {
        WEAKSELF
        dispatch_async(self.videoQueue, ^{
            STRONGSELF
            [strongSelf.captureSession stopRunning];
        });
    }
}

#pragma mark - Still Image Capture
/**
 图片捕捉
 */
- (void)captureStillImage {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    if (@available(iOS 10.0, *)) {
        //设置不能重用
        AVCapturePhotoSettings *photoSettings = [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey:AVVideoCodecJPEG}];
        [photoSettings setFlashMode:self.flashMode];
        [self.imageOutput capturePhotoWithSettings:photoSettings delegate:self];
    }
#else
    AVCaptureConnection *connection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (connection.isVideoOrientationSupported) {
        connection.videoOrientation = [self currentVideoOrientation];
    }
    WEAKSELF
    id handler = ^(CMSampleBufferRef sampleBuffer, NSError *error) {
        STRONGSELF
        if (sampleBuffer != NULL) {
            NSLog(@"ios8的拍照");
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
            
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            [strongSelf writeImageToAssetsLibrary:image];
        } else {
            NSLog(@"NULL sampleBuffer: %@", [error localizedDescription]);
        }
    };
    // Capture still image
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:connection
                                                  completionHandler:handler];
#endif
}

/**
 写入到相册
 
 @param image 图片
 */
- (void)writeImageToAssetsLibrary:(UIImage *)image {
    WEAKSELF
    [OMAssetsLibraryTool writeImageToAssetsLibrary:image withCompletionHandler:^(NSURL * _Nonnull URL, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            STRONGSELF
            if (!error) {
                if ([strongSelf.delegate respondsToSelector:@selector(captureStillImage:)]) {
                    [strongSelf.delegate captureStillImage:image];
                }
            } else {
                if ([strongSelf.delegate respondsToSelector:@selector(assetLibraryWriteFailedWithError:)]) {
                    [strongSelf.delegate assetLibraryWriteFailedWithError:error];
                }
            }
        });
    }];
}

#pragma mark - Video Recording

/**
 开始录制视频
 */
- (void)startRecording {
    WEAKSELF
    dispatch_async(self.videoQueue, ^{
        STRONGSELF
        if ([strongSelf isRecording]) {
            return;
        }
        AVCaptureConnection *videoConnection = [strongSelf.movieOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([videoConnection isVideoOrientationSupported]) {
            videoConnection.videoOrientation = strongSelf.currentVideoOrientation;
        }
        if ([videoConnection isVideoStabilizationSupported]) {//是否支持视频稳定功能，可以显著提高视频质量
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
                videoConnection.enablesVideoStabilizationWhenAvailable = YES;
            } else {
                videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            }
        }
        AVCaptureDevice *device = [strongSelf activeCamera];
        if (device.isSmoothAutoFocusSupported) {//是否支持平滑对焦模式，可以提供更自然的录制效果
            NSError *error;
            if ([device lockForConfiguration:&error]) {
                device.smoothAutoFocusEnabled = NO;
                [device unlockForConfiguration];
            } else {
                if ([strongSelf.delegate respondsToSelector:@selector(deviceConfigurationFailedWithError:)]) {
                    [strongSelf.delegate deviceConfigurationFailedWithError:error];
                }
            }
        }
        strongSelf.outputURL = [strongSelf uniqueURL];
        [strongSelf.movieOutput startRecordingToOutputFileURL:strongSelf.outputURL recordingDelegate:strongSelf];
    });
}

/**
 停止录制视频
 */
- (void)stopRecording {
    dispatch_async(self.videoQueue, ^{
        if ([self isRecording]) {
            [self.movieOutput stopRecording];
        }
    });
}

/**
 录制的时间
 */
- (CMTime)recordedDuration {
    return self.movieOutput.recordedDuration;
}

/**
 是否正在录制
 */
- (BOOL)isRecording {
    return self.movieOutput.isRecording;
}

/**
 生成一个唯一的临时视频路径
 */
- (NSURL *)uniqueURL {
    NSString *dirName = [NSString stringWithFormat:@"%0f",[[NSDate date]timeIntervalSince1970]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dirPath = [fileManager temporaryDirectoryWithTemplateString:dirName];
    
    if (dirPath) {
        NSString *filePath = [dirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",[[NSUUID UUID] UUIDString]]];
        return [NSURL fileURLWithPath:filePath];
    }
    return nil;
}

/**
 写入视频到相册
 
 @param videoURL 视频url
 */
- (void)writeVideoToAssetsLibrary:(NSURL *)videoURL {
    WEAKSELF
    [OMAssetsLibraryTool writeVideoToAssetsLibrary:videoURL withCompletionHandler:^(id  _Nonnull obj, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            STRONGSELF
            if (error) {
                if ([strongSelf.delegate respondsToSelector:@selector(assetLibraryWriteFailedWithError:)]) {
                    [strongSelf.delegate assetLibraryWriteFailedWithError:error];
                }
            } else {
                [OMAssetsLibraryTool generateThumbnailForVideoAtURL:videoURL width:100.f withCompletionHandler:^(UIImage *image, NSError * _Nonnull error) {
                    STRONGSELF
                    if (!error) {
                        if ([strongSelf.delegate respondsToSelector:@selector(thumbnailgenerated:)]) {
                            [strongSelf.delegate thumbnailgenerated:image];
                        }
                    }
                }];
                if ([strongSelf.delegate respondsToSelector:@selector(recordVideo:)]) {
                    [strongSelf.delegate recordVideo:videoURL];
                }
            }
        });
    }];
}

#pragma mark - Camera Configuration

/**
 摄像头数量
 */
- (NSUInteger)cameraCount {
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

/**
 获取前置或后置摄像头
 */
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

/**
 当前正在使用的摄像头
 */
- (AVCaptureDevice *)activeCamera {
    return self.activeVideoInput.device;
}

/**
 当前没在使用的摄像头
 */
- (AVCaptureDevice *)inactiveCamera {
    AVCaptureDevice *device = nil;
    if (self.cameraCount > 1) {
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}

/**
 是否能切换摄像头
 */
- (BOOL)canSwitchCameras {
    return self.cameraCount > 1;
}

/**
 切换摄像头
 */
- (BOOL)switchCameras {
    if (![self canSwitchCameras]) {
        return NO;
    }
    NSError *error;
    AVCaptureDevice *videoDevice = [self inactiveCamera];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (videoInput) {
        [self.captureSession beginConfiguration];
        [self.captureSession removeInput:self.activeVideoInput];
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        } else {
            [self.captureSession addInput:self.activeVideoInput];
        }
        [self.captureSession commitConfiguration];
    } else {
        [self.delegate deviceConfigurationFailedWithError:error];
        return NO;
    }
    return YES;
}

#pragma mark - Flash and Torch Modes

/**
 是否有闪光灯
 */
- (BOOL)cameraHasFlash {
    return [[self activeCamera] hasFlash];
}

/**
 当前的闪光灯模式
 */
- (AVCaptureFlashMode)flashMode {
    return [[self activeCamera] flashMode];
}

/**
 设置闪光灯模式
 */
- (void)setFlashMode:(AVCaptureFlashMode)flashMode {
    AVCaptureDevice *device = [self activeCamera];
    if (device.flashMode != flashMode &&
        [device isFlashModeSupported:flashMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
        } else {
            [self.delegate deviceConfigurationFailedWithError:error];
        }
    }
}

/**
 是否有手电筒
 */
- (BOOL)cameraHasTorch {
    return [[self activeCamera] hasTorch];
}

/**
 当前的手电筒模式
 */
- (AVCaptureTorchMode)torchMode {
    return [[self activeCamera] torchMode];
}

/**
 设置手电筒模式
 */
- (void)setTorchMode:(AVCaptureTorchMode)torchMode {
    
    AVCaptureDevice *device = [self activeCamera];
    
    if (device.torchMode != torchMode &&
        [device isTorchModeSupported:torchMode]) {
        
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        } else {
            [self.delegate deviceConfigurationFailedWithError:error];
        }
    }
}

#pragma mark - Focus And Exposure

/**
 是否支持对焦
 */
- (BOOL)cameraSupportsTapToFocus {
    return [[self activeCamera] isFocusPointOfInterestSupported];
}

/**
 对焦
 */
- (void)focusAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [self activeCamera];
    //是否支持自动对焦
    if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        } else {
            [self.delegate deviceConfigurationFailedWithError:error];
        }
    }
}

/**
 是否支持曝光
 */
- (BOOL)cameraSupportsTapToExpose {
    return [[self activeCamera] isExposurePointOfInterestSupported];
}

// Define KVO context pointer for observing 'adjustingExposure" device property.
static const NSString *OMCameraAdjustingExposureContext;

/**
 曝光
 */
- (void)exposeAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [self activeCamera];
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;//根据场景变化自动曝光
    if (device.isExposurePointOfInterestSupported && [device isExposureModeSupported:exposureMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.exposurePointOfInterest = point;
            device.exposureMode = exposureMode;
            if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) {
                [device addObserver:self
                         forKeyPath:@"adjustingExposure"
                            options:NSKeyValueObservingOptionNew
                            context:&OMCameraAdjustingExposureContext];//观察曝光调整何时完成
            }
            [device unlockForConfiguration];
        } else {
            [self.delegate deviceConfigurationFailedWithError:error];
        }
    }
}

/**
 KVO观察曝光调整何时完成
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (context == &OMCameraAdjustingExposureContext) {
        AVCaptureDevice *device = (AVCaptureDevice *)object;
        //设备不再调整曝光等级
        if (!device.isAdjustingExposure && [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            [object removeObserver:self
                        forKeyPath:@"adjustingExposure"
                           context:&OMCameraAdjustingExposureContext];
            //切到主线程去锁定当前曝光等级
            WEAKSELF
            dispatch_async(dispatch_get_main_queue(), ^{
                STRONGSELF
                NSError *error;
                if ([device lockForConfiguration:&error]) {
                    device.exposureMode = AVCaptureExposureModeLocked;
                    [device unlockForConfiguration];
                } else {
                    [strongSelf.delegate deviceConfigurationFailedWithError:error];
                }
            });
        }
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

/**
 还原对焦模式和曝光模式
 */
- (void)resetFocusAndExposureModes {
    
    AVCaptureDevice *device = [self activeCamera];
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    
    BOOL canResetFocus = [device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode];
    BOOL canResetExposure = [device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode];
    CGPoint centerPoint = CGPointMake(0.5f, 0.5f);
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        if (canResetFocus) {
            device.focusMode = focusMode;
            device.focusPointOfInterest = centerPoint;
        }
        if (canResetExposure) {
            device.exposureMode = exposureMode;
            device.exposurePointOfInterest = centerPoint;
        }
        [device unlockForConfiguration];
    } else {
        [self.delegate deviceConfigurationFailedWithError:error];
    }
}
#pragma mark - AVCapturePhotoCaptureDelegate

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhotoSampleBuffer:(nullable CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings error:(nullable NSError *)error  API_AVAILABLE(ios(10.0)){
    NSLog(@"ios10的拍照");
    NSData *imageData = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
    UIImage *image = [UIImage imageWithData:imageData];
    [self writeImageToAssetsLibrary:image];
}
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error API_AVAILABLE(ios(11.0)) {
    NSLog(@"ios11的拍照");
    NSData *data = photo.fileDataRepresentation;
    UIImage *image = [UIImage imageWithData:data];
    [self writeImageToAssetsLibrary:image];
}
#endif

#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    WEAKSELF
    if (error) {
        //视频录制失败
        dispatch_async(dispatch_get_main_queue(), ^{
            STRONGSELF
            [strongSelf.delegate mediaCaptureFailedWithError:error];
        });
    } else {
        NSLog(@"保存视频到相册");
        [self writeVideoToAssetsLibrary:[self.outputURL copy]];
    }
    self.outputURL = nil;
}

#pragma mark - private

/**
 根据设备方向返回捕捉方向

 @return 会话捕捉方向
 */
- (AVCaptureVideoOrientation)currentVideoOrientation {
    
    AVCaptureVideoOrientation orientation;
    
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }
    
    return orientation;
}

@end
