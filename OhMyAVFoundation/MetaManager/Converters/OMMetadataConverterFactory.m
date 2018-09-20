//
//  OMMetadataConverterFactory.m
//  OhMyAVFoundation
//
//  Created by 申屠云飞 on 2018/8/31.
//  Copyright © 2018年 styf. All rights reserved.
//

#import "OMMetadataConverterFactory.h"
#import "OMArtworkMetadataConverter.h"
#import "OMCommentMetadataConverter.h"
#import "OMDiscMetadataConverter.h"
#import "OMGenreMetadataConverter.h"
#import "OMTrackMetadataConverter.h"
#import "OMMetadataKeys.h"
@implementation OMMetadataConverterFactory
- (id <OMMetadataConverter>)converterForKey:(NSString *)key {
    
    id <OMMetadataConverter> converter = nil;
    
    if ([key isEqualToString:THMetadataKeyArtwork]) {
        converter = [[OMArtworkMetadataConverter alloc] init];
    }
    else if ([key isEqualToString:THMetadataKeyTrackNumber]) {
        converter = [[OMTrackMetadataConverter alloc] init];
    }
    else if ([key isEqualToString:THMetadataKeyDiscNumber]) {
        converter = [[OMDiscMetadataConverter alloc] init];
    }
    else if ([key isEqualToString:THMetadataKeyComments]) {
        converter = [[OMCommentMetadataConverter alloc] init];
    }
    else if ([key isEqualToString:THMetadataKeyGenre]) {
        converter = [[OMGenreMetadataConverter alloc] init];
    }
    else {
        converter = [[OMDefaultMetadataConverter alloc] init];
    }
    
    return converter;
}
@end
