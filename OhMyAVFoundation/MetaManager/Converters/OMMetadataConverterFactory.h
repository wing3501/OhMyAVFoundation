//
//  OMMetadataConverterFactory.h
//  OhMyAVFoundation
//
//  Created by 申屠云飞 on 2018/8/31.
//  Copyright © 2018年 styf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OMDefaultMetadataConverter.h"
@interface OMMetadataConverterFactory : OMDefaultMetadataConverter
- (id <OMMetadataConverter>)converterForKey:(NSString *)key;
@end
