//
//  MediaItem.m
//  OhMyAVFoundation
//
//  Created by 申屠云飞 on 2018/8/31.
//  Copyright © 2018年 styf. All rights reserved.
//

#import "MediaItem.h"
#import "NSFileManager+DirectoryLocations.h"
#define COMMON_META_KEY     @"commonMetadata"
#define AVAILABLE_META_KAY  @"availableMetadataFormats"

@interface MediaItem()
@property (nonatomic,strong) NSURL *url;
@property (nonatomic,strong) AVAsset *asset;
@property (nonatomic,strong) OMMetadata *metadata;
@property (nonatomic,strong) NSArray *acceptedFormats;
@property (nonatomic,assign) BOOL prepared;
@end
@implementation MediaItem
- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _url = url;
        _asset = [AVAsset assetWithURL:url];
        _filename = [url lastPathComponent];
        _filetype = [self fileTypeForURL:url];
        _editable = ![_filetype isEqualToString:AVFileTypeMPEGLayer3];
        _acceptedFormats = @[
                             AVMetadataFormatQuickTimeMetadata,
                             AVMetadataFormatiTunesMetadata,
                             AVMetadataFormatID3Metadata
                             ];
    }
    return self;
}

- (NSString *)fileTypeForURL:(NSURL *)url {
    NSString *ext = [[self.url lastPathComponent] pathExtension];
    NSString *type = nil;
    if ([ext isEqualToString:@"m4a"]) {
        type = AVFileTypeAppleM4A;
    } else if ([ext isEqualToString:@"m4v"]) {
        type = AVFileTypeAppleM4V;
    } else if ([ext isEqualToString:@"mov"]) {
        type = AVFileTypeQuickTimeMovie;
    } else if ([ext isEqualToString:@"mp4"]) {
        type = AVFileTypeMPEG4;
    } else {
        type = AVFileTypeMPEGLayer3;
    }
    return type;
}

- (void)prepareWithCompletionHandler:(OMCompletionHandler)handler {
    if (self.prepared) {
        handler(self.prepared);
        return;
    }
    self.metadata = [[OMMetadata alloc] init];
    NSArray *keys = @[COMMON_META_KEY,AVAILABLE_META_KAY];
    WEAKSELF
    [self.asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        STRONGSELF
        AVKeyValueStatus commonStatus = [strongSelf.asset statusOfValueForKey:COMMON_META_KEY error:nil];
        AVKeyValueStatus formatsStatus = [strongSelf.asset statusOfValueForKey:AVAILABLE_META_KAY error:nil];
        strongSelf.prepared = (commonStatus == AVKeyValueStatusLoaded)&&(formatsStatus == AVKeyValueStatusLoaded);
        if (strongSelf.prepared) {
            for (AVMetadataItem *item in strongSelf.asset.commonMetadata) {
                [strongSelf.metadata addMetadataItem:item withKey:item.commonKey];
            }
        }
        
        for (AVMetadataFormat format in strongSelf.asset.availableMetadataFormats) {
            if ([strongSelf.acceptedFormats containsObject:format]) {
                NSArray *items = [strongSelf.asset metadataForFormat:format];
                for (AVMetadataItem *item in items) {
                    [strongSelf.metadata addMetadataItem:item withKey:item.key];
                }
            }
        }
        handler(strongSelf.prepared);
    }];
}
//保存元数据
- (void)saveWithCompletionHandler:(OMCompletionHandler)handler {
    
    NSString *presetName = AVAssetExportPresetPassthrough;//不需要对媒体重新编码的前提下写入元数据，Passthrough导出过程的时间很短，不可以添加新的元数据
    AVAssetExportSession *session = [[AVAssetExportSession alloc]initWithAsset:self.asset presetName:presetName];
    NSURL *outputURL = [self tempURL];
    session.outputURL = outputURL;
    session.outputFileType = self.filetype;
    session.metadata = [self.metadata metadataItems];//AVMetadataItem数组
    
    [session exportAsynchronouslyWithCompletionHandler:^{
        AVAssetExportSessionStatus status = session.status;
        BOOL success = (status == AVAssetExportSessionStatusCompleted);
        if (success) {
            NSURL *sourceURL = self.url;
            NSFileManager *manager = [NSFileManager defaultManager];
            [manager removeItemAtURL:sourceURL error:nil];
            [manager moveItemAtURL:outputURL toURL:sourceURL error:nil];
            [self reset];
        }
        
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(success);
            });
        }
    }];
}

- (NSURL *)tempURL {
    NSString *tempDir = NSTemporaryDirectory();
    NSString *ext = [[self.url lastPathComponent] pathExtension];
    NSString *tempName = [NSString stringWithFormat:@"temp.%@",ext];
    NSString *tempPath = [tempDir stringByAppendingPathComponent:tempName];
    return [NSURL fileURLWithPath:tempPath];
}

- (void)reset {
    _prepared = NO;
    _asset = [AVAsset assetWithURL:self.url];
}
@end
