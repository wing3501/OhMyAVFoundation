//
//  NSFileManager+Ext.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2018/10/15.
//  Copyright © 2018年 styf. All rights reserved.
//

#import "NSFileManager+Ext.h"

@implementation NSFileManager (Ext)

- (NSString *)temporaryDirectoryWithTemplateString:(NSString *)templateString {
    
    NSString *mkdTemplate = [NSTemporaryDirectory() stringByAppendingPathComponent:templateString];
    
    const char *templateCString = [mkdTemplate fileSystemRepresentation];
    char *buffer = (char *)malloc(strlen(templateCString) + 1);
    strcpy(buffer, templateCString);
    
    NSString *directoryPath = nil;
    
    char *result = mkdtemp(buffer);
    if (result) {
        directoryPath = [self stringWithFileSystemRepresentation:buffer
                                                          length:strlen(result)];
    }
    free(buffer);
    return directoryPath;
}
@end
