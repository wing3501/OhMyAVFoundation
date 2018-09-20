//
//  OMGenre.h
//  OhMyAVFoundation
//
//  Created by 申屠云飞 on 2018/8/31.
//  Copyright © 2018年 styf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OMGenre : NSObject<NSCopying>
@property (nonatomic, readonly) NSUInteger index;
@property (nonatomic, copy, readonly) NSString *name;

+ (NSArray *)musicGenres;

+ (NSArray *)videoGenres;

+ (OMGenre *)id3GenreWithIndex:(NSUInteger)index;

+ (OMGenre *)id3GenreWithName:(NSString *)name;

+ (OMGenre *)iTunesGenreWithIndex:(NSUInteger)index;

+ (OMGenre *)videoGenreWithName:(NSString *)name;
@end
