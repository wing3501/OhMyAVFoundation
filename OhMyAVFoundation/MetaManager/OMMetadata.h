//
//  OMMetadata.h
//  OhMyAVFoundation
//
//  Created by 申屠云飞 on 2018/8/31.
//  Copyright © 2018年 styf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OMGenre.h"
@interface OMMetadata : NSObject
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *artist;
@property (nonatomic,copy) NSString *albumArtist;
@property (nonatomic,copy) NSString *album;
@property (nonatomic,copy) NSString *grouping;
@property (nonatomic,copy) NSString *composer;
@property (nonatomic,copy) NSString *comments;
@property (nonatomic,strong) UIImage *artwork;
@property (nonatomic,strong) OMGenre *genre;

@property (nonatomic,copy) NSString *year;
@property (nonatomic,strong) NSNumber *bpm;
@property (nonatomic,strong) NSNumber *trackNumber;
@property (nonatomic,strong) NSNumber *trackCount;
@property (nonatomic,strong) NSNumber *discNumber;
@property (nonatomic,strong) NSNumber *discCount;

- (void)addMetadataItem:(AVMetadataItem *)item withKey:(id)key;
- (NSArray *)metadataItems;
@end
