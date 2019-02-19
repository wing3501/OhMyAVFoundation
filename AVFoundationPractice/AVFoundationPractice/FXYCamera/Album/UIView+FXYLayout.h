//
//  UIView+FXYLayout.h
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2019/2/19.
//  Copyright © 2019 styf. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    FXYOscillatoryAnimationToBigger,
    FXYOscillatoryAnimationToSmaller,
} FXYOscillatoryAnimationType;

@interface UIView (FXYLayout)

@property (nonatomic) CGFloat fxy_left;        ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat fxy_top;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat fxy_right;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat fxy_bottom;      ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat fxy_width;       ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat fxy_height;      ///< Shortcut for frame.size.height.
@property (nonatomic) CGFloat fxy_centerX;     ///< Shortcut for center.x
@property (nonatomic) CGFloat fxy_centerY;     ///< Shortcut for center.y
@property (nonatomic) CGPoint fxy_origin;      ///< Shortcut for frame.origin.
@property (nonatomic) CGSize  fxy_size;        ///< Shortcut for frame.size.

+ (void)showOscillatoryAnimationWithLayer:(CALayer *)layer type:(FXYOscillatoryAnimationType)type;

@end

