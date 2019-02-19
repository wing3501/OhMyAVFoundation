//
//  NSBundle+FXYImagePicker.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/19.
//  Copyright © 2019 styf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (FXYImagePicker)
+ (NSBundle *)fxy_imagePickerBundle;

+ (NSString *)fxy_localizedStringForKey:(NSString *)key value:(NSString *)value;
+ (NSString *)fxy_localizedStringForKey:(NSString *)key;
@end

