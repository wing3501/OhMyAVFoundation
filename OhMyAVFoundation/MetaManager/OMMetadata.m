//
//  OMMetadata.m
//  OhMyAVFoundation
//
//  Created by 申屠云飞 on 2018/8/31.
//  Copyright © 2018年 styf. All rights reserved.
//

#import "OMMetadata.h"
#import "OMMetadataConverterFactory.h"
#import "OMMetadataKeys.h"
#import "OMMetadataConverter.h"
@interface OMMetadata()
@property (nonatomic,strong) NSDictionary *keyMapping;
@property (nonatomic,strong) NSMutableDictionary *metadata;
@property (nonatomic,strong) OMMetadataConverterFactory *converterFactory;
@end
@implementation OMMetadata
- (instancetype)init {
    self = [super init];
    if (self) {
        _keyMapping = [self buildKeyMapping];
        _metadata = [NSMutableDictionary dictionary];
        _converterFactory = [[OMMetadataConverterFactory alloc]init];
    }
    return self;
}

- (void)addMetadataItem:(AVMetadataItem *)item withKey:(id)key {
    NSString *normalizedKey = self.keyMapping[key];
    if (normalizedKey) {
        id<OMMetadataConverter> converter = [self.converterFactory converterForKey:normalizedKey];
        id value = [converter displayValueFromMetadataItem:item];
        if ([value isKindOfClass:[NSDictionary class]]) {//特别处理 Track 和 Disc
            NSDictionary *data = (NSDictionary *)value;
            for (NSString *currentKey in data) {
                [self setValue:data[currentKey] forKey:currentKey];
            }
        } else {
            [self setValue:value forKey:normalizedKey];
        }
        self.metadata[normalizedKey] = item;
    }
}

- (NSArray *)metadataItems {
    NSMutableArray *items = [NSMutableArray array];
    [self addMetadataItemForNumber:self.trackNumber count:self.trackCount numberKey:THMetadataKeyTrackNumber countKey:THMetadataKeyTrackCount toArray:items];
    [self addMetadataItemForNumber:self.discNumber count:self.discCount numberKey:THMetadataKeyDiscNumber countKey:THMetadataKeyDiscCount toArray:items];
    
    NSMutableDictionary *metaDict = [self.metadata mutableCopy];
    [metaDict removeObjectForKey:THMetadataKeyTrackNumber];
    [metaDict removeObjectForKey:THMetadataKeyDiscNumber];
    
    for (NSString *key in metaDict) {
        id <OMMetadataConverter> converter = [self.converterFactory converterForKey:key];
        id value = [self valueForKey:key];
        AVMetadataItem *item = [converter metadataItemFromDisplayValue:value withMetadataItem:metaDict[key]];
        if (item) {
            [items addObject:item];
        }
    }
    return items;
}

- (void)addMetadataItemForNumber:(NSNumber *)number
                           count:(NSNumber *)count
                       numberKey:(NSString *)numberKey
                        countKey:(NSString *)countKey
                         toArray:(NSMutableArray *)items {
    id<OMMetadataConverter> converter = [self.converterFactory converterForKey:numberKey];
    NSDictionary *data = @{numberKey : number?:[NSNull null],
                           countKey : count?:[NSNull null]};
    AVMetadataItem *sourceItem = self.metadata[numberKey];
    AVMetadataItem *item = [converter metadataItemFromDisplayValue:data withMetadataItem:sourceItem];
    if (item) {
        [items addObject:item];
    }
}

- (NSDictionary *)buildKeyMapping {
    return @{
             // Name Mapping
             AVMetadataCommonKeyTitle : THMetadataKeyName,
             
             // Artist Mapping
             AVMetadataCommonKeyArtist : THMetadataKeyArtist,
             AVMetadataQuickTimeMetadataKeyProducer : THMetadataKeyArtist,
             
             // Album Artist Mapping
             AVMetadataID3MetadataKeyBand : THMetadataKeyAlbumArtist,
             AVMetadataiTunesMetadataKeyAlbumArtist : THMetadataKeyAlbumArtist,
             @"TP2" : THMetadataKeyAlbumArtist,
             
             // Album Mapping
             AVMetadataCommonKeyAlbumName : THMetadataKeyAlbum,
             
             // Artwork Mapping
             AVMetadataCommonKeyArtwork : THMetadataKeyArtwork,
             
             // Year Mapping
             AVMetadataCommonKeyCreationDate : THMetadataKeyYear,
             AVMetadataID3MetadataKeyYear : THMetadataKeyYear,
             @"TYE" : THMetadataKeyYear,
             AVMetadataQuickTimeMetadataKeyYear : THMetadataKeyYear,
             AVMetadataID3MetadataKeyRecordingTime : THMetadataKeyYear,
             
             // BPM Mapping
             AVMetadataiTunesMetadataKeyBeatsPerMin : THMetadataKeyBPM,
             AVMetadataID3MetadataKeyBeatsPerMinute : THMetadataKeyBPM,
             @"TBP" : THMetadataKeyBPM,
             
             // Grouping Mapping
             AVMetadataiTunesMetadataKeyGrouping : THMetadataKeyGrouping,
             @"@grp" : THMetadataKeyGrouping,
             AVMetadataCommonKeySubject : THMetadataKeyGrouping,
             
             // Track Number Mapping
             AVMetadataiTunesMetadataKeyTrackNumber : THMetadataKeyTrackNumber,
             AVMetadataID3MetadataKeyTrackNumber : THMetadataKeyTrackNumber,
             @"TRK" : THMetadataKeyTrackNumber,
             
             // Composer Mapping
             AVMetadataQuickTimeMetadataKeyDirector : THMetadataKeyComposer,
             AVMetadataiTunesMetadataKeyComposer : THMetadataKeyComposer,
             AVMetadataCommonKeyCreator : THMetadataKeyComposer,
             
             // Disc Number Mapping
             AVMetadataiTunesMetadataKeyDiscNumber : THMetadataKeyDiscNumber,
             AVMetadataID3MetadataKeyPartOfASet : THMetadataKeyDiscNumber,
             @"TPA" : THMetadataKeyDiscNumber,
             
             // Comments Mapping
             @"ldes" : THMetadataKeyComments,
             AVMetadataCommonKeyDescription : THMetadataKeyComments,
             AVMetadataiTunesMetadataKeyUserComment : THMetadataKeyComments,
             AVMetadataID3MetadataKeyComments : THMetadataKeyComments,
             @"COM" : THMetadataKeyComments,
             
             // Genre Mapping
             AVMetadataQuickTimeMetadataKeyGenre : THMetadataKeyGenre,
             AVMetadataiTunesMetadataKeyUserGenre : THMetadataKeyGenre,
             AVMetadataCommonKeyType : THMetadataKeyGenre
             };
}
@end
