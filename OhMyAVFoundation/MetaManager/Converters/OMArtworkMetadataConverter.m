//
//  OMArtworkMetadataConverter.m
//  OhMyAVFoundation
//
//  Created by 申屠云飞 on 2018/8/31.
//  Copyright © 2018年 styf. All rights reserved.
//

#import "OMArtworkMetadataConverter.h"

@implementation OMArtworkMetadataConverter

- (id)displayValueFromMetadataItem:(AVMetadataItem *)item {
    UIImage *image = nil;
    if ([item.value isKindOfClass:[NSData class]]) {                        // 1
        image = [[UIImage alloc] initWithData:item.dataValue];
    }
    else if ([item.value isKindOfClass:[NSDictionary class]]) {             // 2
        NSDictionary *dict = (NSDictionary *)item.value;
        image = [[UIImage alloc] initWithData:dict[@"data"]];
    }
    return image;
}

- (AVMetadataItem *)metadataItemFromDisplayValue:(id)value
                                withMetadataItem:(AVMetadataItem *)item {
    
    AVMutableMetadataItem *metadataItem = [item mutableCopy];
    
//    UIImage *image = (UIImage *)value;
//    metadataItem.value = image.TIFFRepresentation;                          // 3
    
    return metadataItem;
}

@end
