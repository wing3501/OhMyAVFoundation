//
//  OMMovieWriter.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2018/10/19.
//  Copyright © 2018年 styf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OMMovieWriterDelegate <NSObject>
- (void)didWriteMovieAtURL:(NSURL *)outputURL;
@end

@interface OMMovieWriter : NSObject

- (id)initWithVideoSettings:(NSDictionary *)videoSettings
              audioSettings:(NSDictionary *)audioSettings
              dispatchQueue:(dispatch_queue_t)dispatchQueue;

- (void)startWriting;
- (void)stopWriting;
@property (nonatomic) BOOL isWriting;

@property (weak, nonatomic) id<OMMovieWriterDelegate> delegate;
/**
 处理视频和音频样本
 
 @param sampleBuffer 样本
 */
- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

NS_ASSUME_NONNULL_END
