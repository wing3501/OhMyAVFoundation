//
//  FXYImagePickerConfig.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/19.
//  Copyright © 2019 styf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FXYPhotoPreviewView.h"
@interface FXYImagePickerConfig : NSObject
+ (instancetype)sharedInstance;
@property (copy, nonatomic) NSString *preferredLanguage;
@property(nonatomic, assign) BOOL allowPickingImage;
@property (nonatomic, assign) BOOL allowPickingVideo;
@property (strong, nonatomic) NSBundle *languageBundle;
@property (assign, nonatomic) BOOL showSelectedIndex;
@property (assign, nonatomic) BOOL showPhotoCannotSelectLayer;
@property (assign, nonatomic) BOOL notScaleImage;
@property (assign, nonatomic) BOOL needFixComposition;

/// 默认是50，如果一个GIF过大，里面图片个数可能超过1000，会导致内存飙升而崩溃
@property (assign, nonatomic) NSInteger gifPreviewMaxImagesCount;
/// 【自定义GIF播放方案】为了避免内存过大，内部默认限制只播放50帧（平均取），可通过gifPreviewMaxImagesCount属性调整，若对GIF预览有更好的效果要求，可实现这个block采用FLAnimatedImage等三方库来播放，但注意FLAnimatedImage有播放速度较慢问题，自行取舍下。
@property (nonatomic, copy) void (^gifImagePlayBlock)(FXYPhotoPreviewView *view, UIImageView *imageView, NSData *gifData, NSDictionary *info);
@end

