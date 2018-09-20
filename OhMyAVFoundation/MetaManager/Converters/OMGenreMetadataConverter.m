//
//  OMGenreMetadataConverter.m
//  OhMyAVFoundation
//
//  Created by 申屠云飞 on 2018/8/31.
//  Copyright © 2018年 styf. All rights reserved.
//

#import "OMGenreMetadataConverter.h"
#import "OMGenre.h"
@implementation OMGenreMetadataConverter

- (id)displayValueFromMetadataItem:(AVMetadataItem *)item {
    
    OMGenre *genre = nil;
    
    if ([item.value isKindOfClass:[NSString class]]) {                      // 1
        if ([item.keySpace isEqualToString:AVMetadataKeySpaceID3]) {
            // ID3v2.4 stores the genre as an index value
            if (item.numberValue) {                                         // 2
                NSUInteger genreIndex = [item.numberValue unsignedIntValue];
                genre = [OMGenre id3GenreWithIndex:genreIndex];
            } else {
                genre = [OMGenre id3GenreWithName:item.stringValue];        // 3
            }
        } else {
            genre = [OMGenre videoGenreWithName:item.stringValue];          // 4
        }
    }
    else if ([item.value isKindOfClass:[NSData class]]) {                   // 5
        NSData *data = item.dataValue;
        if (data.length == 2) {
            uint16_t *values = (uint16_t *)[data bytes];
            uint16_t genreIndex = CFSwapInt16BigToHost(values[0]);
            genre = [OMGenre iTunesGenreWithIndex:genreIndex];
        }
    }
    return genre;
}

- (AVMetadataItem *)metadataItemFromDisplayValue:(id)value
                                withMetadataItem:(AVMetadataItem *)item {
    
    AVMutableMetadataItem *metadataItem = [item mutableCopy];
    
    OMGenre *genre = (OMGenre *)value;
    
    if ([item.value isKindOfClass:[NSString class]]) {                      // 6
        metadataItem.value = genre.name;
    }
    else if ([item.value isKindOfClass:[NSData class]]) {                   // 7
        NSData *data = item.dataValue;
        if (data.length == 2) {
            uint16_t value = CFSwapInt16HostToBig(genre.index + 1);         // 8
            size_t length = sizeof(value);
            metadataItem.value = [NSData dataWithBytes:&value length:length];
        }
    }
    
    return metadataItem;
}
@end
