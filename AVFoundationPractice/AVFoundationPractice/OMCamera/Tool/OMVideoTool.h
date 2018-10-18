//
//  OMVideoTool.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2018/10/18.
//  Copyright © 2018年 styf. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^WriteCompletionHandler)(NSURL *URL, NSError *error);

NS_ASSUME_NONNULL_BEGIN

@interface OMVideoTool : NSObject
SingletonH(OMVideoTool)
/**
 把视频从一个地址写到另一个地址(quicktime格式)

 @param inputURL 读入地址
 @param outputURL 写入地址
 */
- (void)writeVideoFrom:(NSURL *)inputURL to:(NSURL *)outputURL withCompletionHandler:(WriteCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
