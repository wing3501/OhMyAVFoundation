//
//  UIImage+FXYBundle.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/20.
//  Copyright © 2019 styf. All rights reserved.
//

#import "UIImage+FXYBundle.h"
#import "NSBundle+FXYImagePicker.h"
@implementation UIImage (FXYBundle)
+ (UIImage *)fxy_imageNamedFromMyBundle:(NSString *)name {
    NSBundle *imageBundle = [NSBundle fxy_imagePickerBundle];
    name = [name stringByAppendingString:@"@2x"];
    NSString *imagePath = [imageBundle pathForResource:name ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    if (!image) {
        // 兼容业务方自己设置图片的方式
        name = [name stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
        image = [UIImage imageNamed:name];
    }
    return image;
}
@end
