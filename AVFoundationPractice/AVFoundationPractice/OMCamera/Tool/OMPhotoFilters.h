//
//  OMPhotoFilters.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2018/10/19.
//  Copyright © 2018年 styf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OMPhotoFilters : NSObject
+ (NSArray *)filterNames;
+ (NSArray *)filterDisplayNames;
+ (CIFilter *)filterForDisplayName:(NSString *)displayName;
+ (CIFilter *)defaultFilter;
@end

NS_ASSUME_NONNULL_END
