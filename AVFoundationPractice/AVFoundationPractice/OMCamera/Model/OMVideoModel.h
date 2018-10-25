//
//  OMVideoModel.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2018/10/22.
//  Copyright © 2018年 styf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OMVideoModel : NSObject
/// 视频文件名称
@property (nonatomic,copy) NSString *fileName;
/// 视频文件地址
@property (nonatomic,copy) NSString *filePath;
/// 是否选中
@property (nonatomic, getter=isSelected) BOOL         selected;
@end

NS_ASSUME_NONNULL_END
