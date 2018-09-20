//
//  OMCameraController.h
//  OhMyAVFoundation
//
//  Created by 申屠云飞 on 2018/9/10.
//  Copyright © 2018年 styf. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const OMThumbnailCreatedNotication;

@protocol OMCameraControllerDelegate <NSObject>
- (void)deviceConfigurationFailedWithError:(NSError *)error;
- (void)mediaCaptureFailedWithError:(NSError *)error;
- (void)assetLibraryWriteFailedWithError:(NSError *)error;
@end

@interface OMCameraController : NSObject

@property (nonatomic,strong) id<OMCameraControllerDelegate> delegate;
@property (nonatomic,strong,readonly) AVCaptureSession *captureSession;

@property (nonatomic,readonly) NSUInteger cameraCount;
@property (nonatomic,readonly) BOOL cameraHasTorch;
@property (nonatomic,readonly) BOOL cameraHasFlash;
@property (nonatomic,readonly) BOOL cameraSupportsTapToFocus;
@property (nonatomic,readonly) BOOL cameraSupportsTapToExpose;
@property (nonatomic,assign) AVCaptureTorchMode torchMode;
@property (nonatomic,assign) AVCaptureFlashMode flashMode;

//session配置
- (BOOL)setupSession:(NSError **)error;
- (void)startSession;
- (void)stopSession;
//设备支持
- (BOOL)switchCameras;
- (BOOL)canSwitchCameras;
//点击
- (void)focusAtPoint:(CGPoint)point;
- (void)exposeAtPoint:(CGPoint)point;
- (void)resetFocusAndExposureModes;
//照片拍摄
- (void)captureStillImage;
//视频录制
- (void)startRecording;
- (void)stopRecoding;
- (BOOL)isRecording;
- (CMTime)recordedDuration;
@end
