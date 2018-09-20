//
//  OMCommentMetadataConverter.m
//  OhMyAVFoundation
//
//  Created by 申屠云飞 on 2018/8/31.
//  Copyright © 2018年 styf. All rights reserved.
//

#import "OMCommentMetadataConverter.h"

@implementation OMCommentMetadataConverter
- (id)displayValueFromMetadataItem:(AVMetadataItem *)item {
    
    NSString *value = nil;
    if ([item.value isKindOfClass:[NSString class]]) {                      // 1
        value = item.stringValue;
    }
    else if ([item.value isKindOfClass:[NSDictionary class]]) {             // 2
        NSDictionary *dict = (NSDictionary *) item.value;
        if ([dict[@"identifier"] isEqualToString:@""]) {
            value = dict[@"text"];
        }
    }
    return value;
}

- (AVMetadataItem *)metadataItemFromDisplayValue:(id)value
                                withMetadataItem:(AVMetadataItem *)item {
    
    AVMutableMetadataItem *metadataItem = [item mutableCopy];               // 3
    metadataItem.value = value;
    return metadataItem;
}
@end
