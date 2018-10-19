//
//  OMContextManager.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2018/10/19.
//  Copyright © 2018年 styf. All rights reserved.
//

#import "OMContextManager.h"

@implementation OMContextManager
SingletonM(OMContextManager)
- (instancetype)init {
    self = [super init];
    if (self) {
        _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        NSDictionary *options = @{kCIContextWorkingColorSpace : [NSNull null]};
        _ciContext = [CIContext contextWithEAGLContext:_eaglContext options:options];
    }
    return self;
}
@end
