//
//  FXYCameraManager.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/15.
//  Copyright © 2019 styf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FXYCameraManagerDelegate <NSObject>
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

/**
 缩放回调
 
 @param value 0-1
 */
- (void)rampedZoomToValue:(CGFloat)value;

@end

@interface FXYCameraManager : NSObject
/// 代理
@property (nonatomic,weak) id<FXYCameraManagerDelegate> delegate;
/// 捕捉会话
@property (nonatomic,strong,readonly) AVCaptureSession *captureSession;
/// 是否正在录制
@property (nonatomic,assign) BOOL recording;
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
/// 当前摄像头是否支持手电筒
@property (nonatomic, readonly) BOOL cameraHasTorch;
/// 当前摄像头是否支持闪光灯
@property (nonatomic, readonly) BOOL cameraHasFlash;
/// 当前摄像头的手电筒模式
@property (nonatomic) AVCaptureTorchMode torchMode;
/// 当前摄像头的闪光灯模式
@property (nonatomic) AVCaptureFlashMode flashMode;

//*****************************对焦和曝光*****************************
/// 当前摄像头是否支持对焦
@property (nonatomic, readonly) BOOL cameraSupportsTapToFocus;
/// 当前摄像头是否支持曝光
@property (nonatomic, readonly) BOOL cameraSupportsTapToExpose;
/// 对焦
- (void)focusAtPoint:(CGPoint)point;
/// 曝光
- (void)exposeAtPoint:(CGPoint)point;
/// 复原对焦和曝光模式
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
