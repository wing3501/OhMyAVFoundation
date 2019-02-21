//
//  FXYAlbumPickerView.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/19.
//  Copyright © 2019 styf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXYImagePickerController.h"
@interface FXYAlbumPickerView : UIView
/// 列数
@property (nonatomic, assign) NSInteger columnNumber;
/// 是否第一次显示
@property (nonatomic, assign) BOOL isFirstAppear;

- (instancetype)initWithImagePickerController:(FXYImagePickerController *)imagePickerController;

/**
 设置列表
 */
- (void)configTableView;

- (void)close;
@end

