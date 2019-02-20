//
//  FXYCommonTools.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/19.
//  Copyright © 2019 styf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FXYCommonTools : NSObject

/**
 是否是iphoneX

 @return 是否
 */
+ (BOOL)fxy_isIPhoneX;

/**
 状态栏高度

 @return 高度
 */
+ (CGFloat)fxy_statusBarHeight;
// 获得Info.plist数据字典
+ (NSDictionary *)fxy_getInfoDictionary;
+ (BOOL)fxy_isRightToLeftLayout;
@end

