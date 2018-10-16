//
//  NSFileManager+Ext.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2018/10/15.
//  Copyright © 2018年 styf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (Ext)

- (NSString *)temporaryDirectoryWithTemplateString:(NSString *)templateString;

@end

NS_ASSUME_NONNULL_END
