//
//  FXYAssetPreviewCell.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/20.
//  Copyright © 2019 styf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXYAssetModel.h"
@interface FXYAssetPreviewCell : UICollectionViewCell
@property (nonatomic, strong) FXYAssetModel *model;
@property (nonatomic, copy) void (^singleTapGestureBlock)(void);
- (void)configSubviews;
- (void)photoPreviewCollectionViewDidScroll;
@end

