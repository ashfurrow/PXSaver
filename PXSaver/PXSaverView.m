//
//  PXSaverView.m
//  PXSaver
//
//  Created by Ash Furrow on 12-07-20.
//  Copyright (c) 2012 500px. All rights reserved.
//

#import "PXSaverView.h"
#import <QuartzCore/QuartzCore.h>

#define secondsPerAnimation 5
#define secondsPerCrossfade 2

@implementation PXSaverView
{
    NSImage *image;
    NSImageView *imageView;
    
    NSBezierPath *path;
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
//        [self setAnimationTimeInterval:1/30.0];
        [self setAnimationTimeInterval:secondsPerAnimation + secondsPerCrossfade];
        
        image = [[NSImage alloc] initWithContentsOfFile:
                          [[NSBundle bundleForClass: [self class]]
                           pathForResource: @"fog"
                           ofType: @"jpg"]];

        
        imageView = [[NSImageView alloc] initWithFrame:self.bounds];
        imageView.wantsLayer = YES;
        imageView.imageScaling = NSImageScaleProportionallyUpOrDown;
        imageView.alphaValue = 0.0f;
        
//        CGFloat scaleFactor = 1.0f;//SSRandomFloatBetween(1.2, 1.3);
//        imageView.layer.affineTransform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
        [imageView setImage:image];
        [self addSubview:imageView];
    }
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
//    NSLog(@"%f, %f", self.bounds.size.width, self.bounds.size.height);
        
//    [image drawInRect:self.bounds fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
}

- (void)animateOneFrame
{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [context setDuration:secondsPerCrossfade/2];
        imageView.layer.opacity = 1.0f;
    } completionHandler:^{
        
    }];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        [context setDuration:secondsPerAnimation];
        CGFloat widthTranslationMax = self.bounds.size.width/10;
        CGFloat heightTranslationMax = self.bounds.size.height/10;
        CGAffineTransform transform = CGAffineTransformMakeTranslation(SSRandomFloatBetween(-widthTranslationMax, widthTranslationMax), SSRandomFloatBetween(-heightTranslationMax, heightTranslationMax));;
        CGFloat scaleFactor = SSRandomFloatBetween(1.3, 1.35);
        transform = CGAffineTransformScale(transform, scaleFactor, scaleFactor);
        imageView.layer.affineTransform = transform;
    } completionHandler:^{
    }];
    
    double delayInSeconds = secondsPerAnimation - secondsPerCrossfade/2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            [context setDuration:secondsPerCrossfade/2];
            imageView.layer.opacity = 0.0f;
        } completionHandler:^{
            
        }];
    });
    
//    [image drawInRect:self.bounds fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
