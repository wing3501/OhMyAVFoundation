//
//  FXYImagePickerConfig.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/19.
//  Copyright © 2019 styf. All rights reserved.
//

#import "FXYImagePickerConfig.h"
#import "NSBundle+FXYImagePicker.h"

@implementation FXYImagePickerConfig
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static FXYImagePickerConfig *config = nil;
    dispatch_once(&onceToken, ^{
        if (config == nil) {
            config = [[FXYImagePickerConfig alloc] init];
            config.preferredLanguage = nil;
            config.gifPreviewMaxImagesCount = 50;
        }
    });
    return config;
}

- (void)setPreferredLanguage:(NSString *)preferredLanguage {
    _preferredLanguage = preferredLanguage;
    
    if (!preferredLanguage || !preferredLanguage.length) {
        preferredLanguage = [NSLocale preferredLanguages].firstObject;
    }
    if ([preferredLanguage rangeOfString:@"zh-Hans"].location != NSNotFound) {
        preferredLanguage = @"zh-Hans";
    } else if ([preferredLanguage rangeOfString:@"zh-Hant"].location != NSNotFound) {
        preferredLanguage = @"zh-Hant";
    } else if ([preferredLanguage rangeOfString:@"vi"].location != NSNotFound) {
        preferredLanguage = @"vi";
    } else {
        preferredLanguage = @"en";
    }
    _languageBundle = [NSBundle bundleWithPath:[[NSBundle fxy_imagePickerBundle] pathForResource:preferredLanguage ofType:@"lproj"]];
}
@end
