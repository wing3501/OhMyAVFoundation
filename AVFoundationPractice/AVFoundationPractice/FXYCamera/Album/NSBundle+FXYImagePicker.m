//
//  NSBundle+FXYImagePicker.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/19.
//  Copyright © 2019 styf. All rights reserved.
//

#import "NSBundle+FXYImagePicker.h"
#import "FXYImagePickerController.h"
#import "FXYImagePickerConfig.h"
@implementation NSBundle (FXYImagePicker)

+ (NSBundle *)fxy_imagePickerBundle {
    NSBundle *bundle = [NSBundle bundleForClass:[FXYImagePickerController class]];
    NSURL *url = [bundle URLForResource:@"FXYImagePickerController" withExtension:@"bundle"];
    bundle = [NSBundle bundleWithURL:url];
    return bundle;
}

+ (NSString *)fxy_localizedStringForKey:(NSString *)key {
    return [self fxy_localizedStringForKey:key value:@""];
}

+ (NSString *)fxy_localizedStringForKey:(NSString *)key value:(NSString *)value {
    NSBundle *bundle = [FXYImagePickerConfig sharedInstance].languageBundle;
    NSString *value1 = [bundle localizedStringForKey:key value:value table:nil];
    return value1;
}
@end
