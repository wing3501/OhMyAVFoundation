//
//  FXYPhotoPickerController.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/20.
//  Copyright © 2019 styf. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FXYAlbumModel;
@interface FXYPhotoPickerController : UIViewController
@property (nonatomic, assign) BOOL isFirstAppear;
@property (nonatomic, assign) NSInteger columnNumber;
@property (nonatomic, strong) FXYAlbumModel *model;
/// 标题点击回调
@property (nonatomic, copy) void(^titleClickBlock)(BOOL buttonSelected);
@end

@interface FXYCollectionView : UICollectionView

@end
