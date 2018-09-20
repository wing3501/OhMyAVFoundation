//
//  OMGenre.m
//  OhMyAVFoundation
//
//  Created by 申屠云飞 on 2018/8/31.
//  Copyright © 2018年 styf. All rights reserved.
//

#import "OMGenre.h"

@implementation OMGenre

+ (NSArray *)videoGenres {
    static dispatch_once_t predicate;
    static NSArray *videoGenres = nil;
    dispatch_once(&predicate, ^{
        videoGenres = @[[[OMGenre alloc] initWithIndex:4000 name:@"Comedy"],
                        [[OMGenre alloc] initWithIndex:4001 name:@"Drama"],
                        [[OMGenre alloc] initWithIndex:4002 name:@"Animation"],
                        [[OMGenre alloc] initWithIndex:4003 name:@"Action & Adventure"],
                        [[OMGenre alloc] initWithIndex:4004 name:@"Classic"],
                        [[OMGenre alloc] initWithIndex:4005 name:@"Kids"],
                        [[OMGenre alloc] initWithIndex:4006 name:@"Nonfiction"],
                        [[OMGenre alloc] initWithIndex:4007 name:@"Reality TV"],
                        [[OMGenre alloc] initWithIndex:4008 name:@"Sci-Fi & Fantasy"],
                        [[OMGenre alloc] initWithIndex:4009 name:@"Sports"],
                        [[OMGenre alloc] initWithIndex:4010 name:@"Teens"],
                        [[OMGenre alloc] initWithIndex:4011 name:@"Latino TV"]];
    });
    return videoGenres;
}

+ (NSArray *)musicGenres {
    static dispatch_once_t predicate;
    static NSArray *musicGenres = nil;
    dispatch_once(&predicate, ^{
        musicGenres = @[[[OMGenre alloc] initWithIndex:0 name:@"Blues"],
                        [[OMGenre alloc] initWithIndex:1 name:@"Classic Rock"],
                        [[OMGenre alloc] initWithIndex:2 name:@"Country"],
                        [[OMGenre alloc] initWithIndex:3 name:@"Dance"],
                        [[OMGenre alloc] initWithIndex:4 name:@"Disco"],
                        [[OMGenre alloc] initWithIndex:5 name:@"Funk"],
                        [[OMGenre alloc] initWithIndex:6 name:@"Grunge"],
                        [[OMGenre alloc] initWithIndex:7 name:@"Hip-Hop"],
                        [[OMGenre alloc] initWithIndex:8 name:@"Jazz"],
                        [[OMGenre alloc] initWithIndex:9 name:@"Metal"],
                        [[OMGenre alloc] initWithIndex:10 name:@"New Age"],
                        [[OMGenre alloc] initWithIndex:11 name:@"Oldies"],
                        [[OMGenre alloc] initWithIndex:12 name:@"Other"],
                        [[OMGenre alloc] initWithIndex:13 name:@"Pop"],
                        [[OMGenre alloc] initWithIndex:14 name:@"R&B"],
                        [[OMGenre alloc] initWithIndex:15 name:@"Rap"],
                        [[OMGenre alloc] initWithIndex:16 name:@"Reggae"],
                        [[OMGenre alloc] initWithIndex:17 name:@"Rock"],
                        [[OMGenre alloc] initWithIndex:18 name:@"Techno"],
                        [[OMGenre alloc] initWithIndex:19 name:@"Industrial"],
                        [[OMGenre alloc] initWithIndex:20 name:@"Alternative"],
                        [[OMGenre alloc] initWithIndex:21 name:@"Ska"],
                        [[OMGenre alloc] initWithIndex:22 name:@"Death Metal"],
                        [[OMGenre alloc] initWithIndex:23 name:@"Pranks"],
                        [[OMGenre alloc] initWithIndex:24 name:@"Soundtrack"],
                        [[OMGenre alloc] initWithIndex:25 name:@"Euro-Techno"],
                        [[OMGenre alloc] initWithIndex:26 name:@"Ambient"],
                        [[OMGenre alloc] initWithIndex:27 name:@"Trip-Hop"],
                        [[OMGenre alloc] initWithIndex:28 name:@"Vocal"],
                        [[OMGenre alloc] initWithIndex:29 name:@"Jazz+Funk"],
                        [[OMGenre alloc] initWithIndex:30 name:@"Fusion"],
                        [[OMGenre alloc] initWithIndex:31 name:@"Trance"],
                        [[OMGenre alloc] initWithIndex:32 name:@"Classical"],
                        [[OMGenre alloc] initWithIndex:33 name:@"Instrumental"],
                        [[OMGenre alloc] initWithIndex:34 name:@"Acid"],
                        [[OMGenre alloc] initWithIndex:35 name:@"House"],
                        [[OMGenre alloc] initWithIndex:36 name:@"Game"],
                        [[OMGenre alloc] initWithIndex:37 name:@"Sound Clip"],
                        [[OMGenre alloc] initWithIndex:38 name:@"Gospel"],
                        [[OMGenre alloc] initWithIndex:39 name:@"Noise"],
                        [[OMGenre alloc] initWithIndex:40 name:@"AlternRock"],
                        [[OMGenre alloc] initWithIndex:41 name:@"Bass"],
                        [[OMGenre alloc] initWithIndex:42 name:@"Soul"],
                        [[OMGenre alloc] initWithIndex:43 name:@"Punk"],
                        [[OMGenre alloc] initWithIndex:44 name:@"Space"],
                        [[OMGenre alloc] initWithIndex:45 name:@"Meditative"],
                        [[OMGenre alloc] initWithIndex:46 name:@"Instrumental Pop"],
                        [[OMGenre alloc] initWithIndex:47 name:@"Instrumental Rock"],
                        [[OMGenre alloc] initWithIndex:48 name:@"Ethnic"],
                        [[OMGenre alloc] initWithIndex:49 name:@"Gothic"],
                        [[OMGenre alloc] initWithIndex:50 name:@"Darkwave"],
                        [[OMGenre alloc] initWithIndex:51 name:@"Techno-Industrial"],
                        [[OMGenre alloc] initWithIndex:52 name:@"Electronic"],
                        [[OMGenre alloc] initWithIndex:53 name:@"Pop-Folk"],
                        [[OMGenre alloc] initWithIndex:54 name:@"Eurodance"],
                        [[OMGenre alloc] initWithIndex:55 name:@"Dream"],
                        [[OMGenre alloc] initWithIndex:56 name:@"Southern Rock"],
                        [[OMGenre alloc] initWithIndex:57 name:@"Comedy"],
                        [[OMGenre alloc] initWithIndex:58 name:@"Cult"],
                        [[OMGenre alloc] initWithIndex:59 name:@"Gangsta"],
                        [[OMGenre alloc] initWithIndex:60 name:@"Top 40"],
                        [[OMGenre alloc] initWithIndex:61 name:@"Christian Rap"],
                        [[OMGenre alloc] initWithIndex:62 name:@"Pop/Funk"],
                        [[OMGenre alloc] initWithIndex:63 name:@"Jungle"],
                        [[OMGenre alloc] initWithIndex:64 name:@"Native American"],
                        [[OMGenre alloc] initWithIndex:65 name:@"Cabaret"],
                        [[OMGenre alloc] initWithIndex:66 name:@"New Wave"],
                        [[OMGenre alloc] initWithIndex:67 name:@"Psychedelic"],
                        [[OMGenre alloc] initWithIndex:68 name:@"Rave"],
                        [[OMGenre alloc] initWithIndex:69 name:@"Showtunes"],
                        [[OMGenre alloc] initWithIndex:70 name:@"Trailer"],
                        [[OMGenre alloc] initWithIndex:71 name:@"Lo-Fi"],
                        [[OMGenre alloc] initWithIndex:72 name:@"Tribal"],
                        [[OMGenre alloc] initWithIndex:73 name:@"Acid Punk"],
                        [[OMGenre alloc] initWithIndex:74 name:@"Acid Jazz"],
                        [[OMGenre alloc] initWithIndex:75 name:@"Polka"],
                        [[OMGenre alloc] initWithIndex:76 name:@"Retro"],
                        [[OMGenre alloc] initWithIndex:77 name:@"Musical"],
                        [[OMGenre alloc] initWithIndex:78 name:@"Rock & Roll"],
                        [[OMGenre alloc] initWithIndex:79 name:@"Hard Rock"],
                        [[OMGenre alloc] initWithIndex:80 name:@"Folk"],
                        [[OMGenre alloc] initWithIndex:81 name:@"Folk-Rock"],
                        [[OMGenre alloc] initWithIndex:82 name:@"National Folk"],
                        [[OMGenre alloc] initWithIndex:83 name:@"Swing"],
                        [[OMGenre alloc] initWithIndex:84 name:@"Fast Fusion"],
                        [[OMGenre alloc] initWithIndex:85 name:@"Bebob"],
                        [[OMGenre alloc] initWithIndex:86 name:@"Latin"],
                        [[OMGenre alloc] initWithIndex:87 name:@"Revival"],
                        [[OMGenre alloc] initWithIndex:88 name:@"Celtic"],
                        [[OMGenre alloc] initWithIndex:89 name:@"Bluegrass"],
                        [[OMGenre alloc] initWithIndex:90 name:@"Avantgarde"],
                        [[OMGenre alloc] initWithIndex:91 name:@"Gothic Rock"],
                        [[OMGenre alloc] initWithIndex:92 name:@"Progressive Rock"],
                        [[OMGenre alloc] initWithIndex:93 name:@"Psychedelic Rock"],
                        [[OMGenre alloc] initWithIndex:94 name:@"Symphonic Rock"],
                        [[OMGenre alloc] initWithIndex:95 name:@"Slow Rock"],
                        [[OMGenre alloc] initWithIndex:96 name:@"Big Band"],
                        [[OMGenre alloc] initWithIndex:97 name:@"Chorus"],
                        [[OMGenre alloc] initWithIndex:98 name:@"Easy Listening"],
                        [[OMGenre alloc] initWithIndex:99 name:@"Acoustic"],
                        [[OMGenre alloc] initWithIndex:100 name:@"Humour"],
                        [[OMGenre alloc] initWithIndex:101 name:@"Speech"],
                        [[OMGenre alloc] initWithIndex:102 name:@"Chanson"],
                        [[OMGenre alloc] initWithIndex:103 name:@"Opera"],
                        [[OMGenre alloc] initWithIndex:104 name:@"Chamber Music"],
                        [[OMGenre alloc] initWithIndex:105 name:@"Sonata"],
                        [[OMGenre alloc] initWithIndex:106 name:@"Symphony"],
                        [[OMGenre alloc] initWithIndex:107 name:@"Booty Bass"],
                        [[OMGenre alloc] initWithIndex:108 name:@"Primus"],
                        [[OMGenre alloc] initWithIndex:109 name:@"Porn Groove"],
                        [[OMGenre alloc] initWithIndex:110 name:@"Satire"],
                        [[OMGenre alloc] initWithIndex:111 name:@"Slow Jam"],
                        [[OMGenre alloc] initWithIndex:112 name:@"Club"],
                        [[OMGenre alloc] initWithIndex:113 name:@"Tango"],
                        [[OMGenre alloc] initWithIndex:114 name:@"Samba"],
                        [[OMGenre alloc] initWithIndex:115 name:@"Folklore"],
                        [[OMGenre alloc] initWithIndex:116 name:@"Ballad"],
                        [[OMGenre alloc] initWithIndex:117 name:@"Power Ballad"],
                        [[OMGenre alloc] initWithIndex:118 name:@"Rhythmic Soul"],
                        [[OMGenre alloc] initWithIndex:119 name:@"Freestyle"],
                        [[OMGenre alloc] initWithIndex:120 name:@"Duet"],
                        [[OMGenre alloc] initWithIndex:121 name:@"Punk Rock"],
                        [[OMGenre alloc] initWithIndex:122 name:@"Drum Solo"],
                        [[OMGenre alloc] initWithIndex:123 name:@"A Capella"],
                        [[OMGenre alloc] initWithIndex:124 name:@"Euro-House"],
                        [[OMGenre alloc] initWithIndex:125 name:@"Dance Hall"]];
    });
    return musicGenres;
}

+ (OMGenre *)id3GenreWithName:(NSString *)name {
    for (OMGenre *genre in [self musicGenres]) {
        if ([genre.name isEqualToString:name]) {
            return genre;
        }
    }
    return [[OMGenre alloc] initWithIndex:255 name:name];
}

+ (OMGenre *)id3GenreWithIndex:(NSUInteger)genreIndex {
    for (OMGenre *genre in [self musicGenres]) {
        if (genre.index == genreIndex) {
            return genre;
        }
    }
    return [[OMGenre alloc] initWithIndex:255 name:@"Custom"];
}

+ (OMGenre *)iTunesGenreWithIndex:(NSUInteger)genreIndex {
    return [self id3GenreWithIndex:genreIndex - 1];
}

+ (OMGenre *)videoGenreWithName:(NSString *)name {
    for (OMGenre *genre in [self videoGenres]) {
        if ([genre.name isEqualToString:name]) {
            return genre;
        }
    }
    return nil;
}

- (instancetype)initWithIndex:(NSUInteger)genreIndex name:(NSString *)name {
    self = [super init];
    if (self) {
        _index = genreIndex;
        _name = [name copy];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[OMGenre alloc] initWithIndex:_index name:_name];
}

- (NSString *)description {
    return self.name;
}

- (BOOL)isEqual:(id)other {
    if (self == other) {
        return YES;
    }
    if (!other || ![other isMemberOfClass:[self class]]) {
        return NO;
    }
    return self.index == [other index] && [self.name isEqual:[other name]];
}

- (NSUInteger)hash {
    NSUInteger prime = 37;
    NSUInteger hash = 0;
    hash += (_index + 1) * prime;
    hash += [self.name hash] * prime;
    return hash;
}
@end
