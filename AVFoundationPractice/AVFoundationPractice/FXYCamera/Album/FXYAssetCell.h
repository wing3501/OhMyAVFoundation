//
//  FXYAssetCell.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/20.
//  Copyright © 2019 styf. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    FXYAssetCellTypePhoto = 0,
    FXYAssetCellTypeLivePhoto,
    FXYAssetCellTypePhotoGif,
    FXYAssetCellTypeVideo,
    FXYAssetCellTypeAudio,
} FXYAssetCellType;

@class FXYAssetModel;

@interface FXYAssetCell : UICollectionViewCell
@property (nonatomic, weak) UIButton *selectPhotoButton;
@property (nonatomic, weak) UIButton *cannotSelectLayerButton;
/// 资源模型
@property (nonatomic, strong) FXYAssetModel *model;
/// 数字序号
@property (nonatomic, assign) NSInteger index;
/// 资源类型
@property (nonatomic, assign) FXYAssetCellType type;
@property (nonatomic, assign) BOOL allowPickingGif;
@property (nonatomic, assign) BOOL allowPickingMultipleVideo;
/// 资源标识
@property (nonatomic, copy) NSString *representedAssetIdentifier;
/// 图片请求标识 用于cancel请求
@property (nonatomic, assign) int32_t imageRequestID;
/// 选中时的按钮图片
@property (nonatomic, strong) UIImage *photoSelImage;
/// 未选中时的按钮图片
@property (nonatomic, strong) UIImage *photoDefImage;
/// 是否显示选中的按钮
@property (nonatomic, assign) BOOL showSelectBtn;
/// 是否允许预览
@property (nonatomic, assign) BOOL allowPreview;
/// 选中、取消选中 图片回调
@property (nonatomic, copy) void (^didSelectPhotoBlock)(BOOL);

@end

