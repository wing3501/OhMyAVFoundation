//
//  OMPhotoFilters.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2018/10/19.
//  Copyright © 2018年 styf. All rights reserved.
//

#import "OMPhotoFilters.h"

@implementation OMPhotoFilters
+ (NSArray *)filterNames {
    
    return @[@"CIPhotoEffectChrome",
             @"CIPhotoEffectFade",
             @"CIPhotoEffectInstant",
             @"CIPhotoEffectMono",
             @"CIPhotoEffectNoir",
             @"CIPhotoEffectProcess",
             @"CIPhotoEffectTonal",
             @"CIPhotoEffectTransfer"];
}

+ (NSArray *)filterDisplayNames {
    return [self filterNames];
}

+ (CIFilter *)defaultFilter {
    return [CIFilter filterWithName:[[self filterNames] firstObject]];
}

+ (CIFilter *)filterForDisplayName:(NSString *)displayName {
    for (NSString *name in [self filterNames]) {
        if ([name containsString:displayName]) {
            return [CIFilter filterWithName:name];
        }
    }
    return nil;
}
@end
