//
//  OMPreviewView.m
//  AVFoundationPractice
//
//  Created by 申屠云飞 on 2018/10/19.
//  Copyright © 2018年 styf. All rights reserved.
//

#import "OMPreviewView.h"

NSString *const OMFilterSelectionChangedNotification = @"filter_selection_changed";

@interface OMPreviewView()
@property (nonatomic) CGRect drawableBounds;
@end
@implementation OMPreviewView

- (instancetype)initWithFrame:(CGRect)frame context:(EAGLContext *)context {
    self = [super initWithFrame:frame context:context];
    if (self) {
        self.enableSetNeedsDisplay = NO;
        self.backgroundColor = [UIColor blackColor];
        self.opaque = YES;
        
        // because the native video image from the back camera is in
        // UIDeviceOrientationLandscapeLeft (i.e. the home button is on the right),
        // we need to apply a clockwise 90 degree transform so that we can draw
        // the video preview as if we were in a landscape-oriented view;
        // if you're using the front camera and you want to have a mirrored
        // preview (so that the user is seeing themselves in the mirror), you
        // need to apply an additional horizontal flip (by concatenating
        // CGAffineTransformMakeScale(-1.0, 1.0) to the rotation transform)
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.frame = frame;
        
        [self bindDrawable];
        _drawableBounds = self.bounds;
        _drawableBounds.size.width = self.drawableWidth;
        _drawableBounds.size.height = self.drawableHeight;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(filterChanged:)
                                                     name:OMFilterSelectionChangedNotification
                                                   object:nil];
    }
    return self;
}

- (void)filterChanged:(NSNotification *)notification {
    self.filter = notification.object;
}

- (void)setImage:(CIImage *)sourceImage {
    
    [self bindDrawable];
    
    [self.filter setValue:sourceImage forKey:kCIInputImageKey];
    CIImage *filteredImage = self.filter.outputImage;
    
    if (filteredImage) {
        CGRect cropRect = OMCenterCropImageRect(sourceImage.extent, self.drawableBounds);
        [self.coreImageContext drawImage:filteredImage
                                  inRect:self.drawableBounds
                                fromRect:cropRect];
    }
    
    [self display];
    [self.filter setValue:nil forKey:kCIInputImageKey];
}

CGRect OMCenterCropImageRect(CGRect sourceRect, CGRect previewRect) {
    
    CGFloat sourceAspectRatio = sourceRect.size.width / sourceRect.size.height;
    CGFloat previewAspectRatio = previewRect.size.width  / previewRect.size.height;
    
    // we want to maintain the aspect radio of the screen size, so we clip the video image
    CGRect drawRect = sourceRect;
    
    if (sourceAspectRatio > previewAspectRatio) {
        // use full height of the video image, and center crop the width
        CGFloat scaledHeight = drawRect.size.height * previewAspectRatio;
        drawRect.origin.x += (drawRect.size.width - scaledHeight) / 2.0;
        drawRect.size.width = scaledHeight;
    } else {
        // use full width of the video image, and center crop the height
        drawRect.origin.y += (drawRect.size.height - drawRect.size.width / previewAspectRatio) / 2.0;
        drawRect.size.height = drawRect.size.width / previewAspectRatio;
    }
    
    return drawRect;
}
@end
