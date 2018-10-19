//
//  OMContextManager.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2018/10/19.
//  Copyright © 2018年 styf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OMContextManager : NSObject
@property (strong, nonatomic, readonly) EAGLContext *eaglContext;
@property (strong, nonatomic, readonly) CIContext *ciContext;
SingletonH(OMContextManager)
@end

NS_ASSUME_NONNULL_END
