//
//  OMCameraManager.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2018/10/12.
//  Copyright © 2018年 styf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OMCameraManagerDelegate <NSObject>
@optional
/**
 相机配置出现异常
 */
- (void)deviceConfigurationFailedWithError:(NSError *)error;
/**
 视频拍摄出现异常
 */
- (void)mediaCaptureFailedWithError:(NSError *)error;
/**
 写入到相册出现异常
 */
- (void)assetLibraryWriteFailedWithError:(NSError *)error;

/**
 拍照
 */
- (void)captureStillImage:(UIImage *)image;

/**
 拍视频

 @param videoURL 视频地址
 */
- (void)recordVideo:(NSURL *)videoURL;
/**
 生成缩略图

 @param thumbnail 缩略图
 */
- (void)thumbnailgenerated:(UIImage *)thumbnail;
@end

@interface OMCameraManager : NSObject
/// 代理
@property (nonatomic,strong) id<OMCameraManagerDelegate> delegate;
/// 捕捉会话
@property (nonatomic,strong,readonly) AVCaptureSession *captureSession;

//*****************************会话控制*****************************
/**
 初始化会话

 @param error 错误
 @return 是否初始化成功
 */
- (BOOL)setupSession:(NSError **)error;

/**
 启动捕捉会话
 */
- (void)startSession;

/**
 停止捕捉会话
 */
- (void)stopSession;

//*****************************切换摄像头*****************************

/**
 切换摄像头
 */
- (BOOL)switchCameras;

/**
 是否能切换摄像头
 */
- (BOOL)canSwitchCameras;
///摄像头数量
@property (nonatomic, readonly) NSUInteger cameraCount;

//*****************************手电筒和闪光灯*****************************

@property (nonatomic, readonly) BOOL cameraHasTorch;
@property (nonatomic, readonly) BOOL cameraHasFlash;
@property (nonatomic) AVCaptureTorchMode torchMode;
@property (nonatomic) AVCaptureFlashMode flashMode;

//*****************************对焦和曝光*****************************

@property (nonatomic, readonly) BOOL cameraSupportsTapToFocus;
@property (nonatomic, readonly) BOOL cameraSupportsTapToExpose;
- (void)focusAtPoint:(CGPoint)point;
- (void)exposeAtPoint:(CGPoint)point;
- (void)resetFocusAndExposureModes;

//*****************************图片捕捉*****************************

/**
 图片捕捉
 */
- (void)captureStillImage;

//*****************************视频录制*****************************

/**
 开始录制
 */
- (void)startRecording;

/**
 停止录制
 */
- (void)stopRecording;

/**
 是否正在录制
 */
- (BOOL)isRecording;

/**
 录制的时间
 */
- (CMTime)recordedDuration;
@end

NS_ASSUME_NONNULL_END
