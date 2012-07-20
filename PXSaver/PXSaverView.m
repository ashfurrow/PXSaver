//
//  PXSaverView.m
//  PXSaver
//
//  Created by Ash Furrow on 12-07-20.
//  Copyright (c) 2012 500px. All rights reserved.
//

#import "PXSaverView.h"
#import <QuartzCore/QuartzCore.h>

#define secondsPerAnimation 4
#define secondsPerCrossfade 1

@implementation PXSaverView
{
    NSImage *image;
    NSImageView *imageView;
    
    NSImage *otherImage;
    NSImageView *otherImageView;
    
    NSBezierPath *path;
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:secondsPerAnimation];
        
        image = [[NSImage alloc] initWithContentsOfFile:
                          [[NSBundle bundleForClass: [self class]]
                           pathForResource: @"fog"
                           ofType: @"jpg"]];

        
        imageView = [[NSImageView alloc] initWithFrame:self.bounds];
        imageView.wantsLayer = YES;
        imageView.imageScaling = NSImageScaleProportionallyUpOrDown;
        imageView.alphaValue = 0.0f;
        
        [imageView setImage:image];
        [self addSubview:imageView];
        
        
        otherImage = [[NSImage alloc] initWithContentsOfFile:
                 [[NSBundle bundleForClass: [self class]]
                  pathForResource: @"stars"
                  ofType: @"jpg"]];
        
        
        otherImageView = [[NSImageView alloc] initWithFrame:self.bounds];
        otherImageView.wantsLayer = YES;
        otherImageView.imageScaling = NSImageScaleProportionallyUpOrDown;
        otherImageView.alphaValue = 0.0f;
        
        [otherImageView setImage:otherImage];
        [self addSubview:otherImageView];
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
    //crossfade in
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        [context setDuration:secondsPerCrossfade];
        imageView.layer.opacity = 1.0f;
        otherImageView.layer.opacity = 0.0f;
    } completionHandler:nil];
    
//    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
//        [context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
//        [context setDuration:secondsPerAnimation];
//        CGFloat widthTranslationMax = self.bounds.size.width/10;
//        CGFloat heightTranslationMax = self.bounds.size.height/10;
//        CGAffineTransform transform = CGAffineTransformMakeTranslation(SSRandomFloatBetween(-widthTranslationMax, widthTranslationMax), SSRandomFloatBetween(-heightTranslationMax, heightTranslationMax));;
//        CGFloat scaleFactor = SSRandomFloatBetween(1.3, 1.35);
//        transform = CGAffineTransformScale(transform, scaleFactor, scaleFactor);
//        imageView.layer.affineTransform = transform;
//    } completionHandler:nil];
    
    //crossfade out
    double delayInSeconds = secondsPerAnimation - secondsPerCrossfade;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            [context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [context setDuration:secondsPerCrossfade];
            imageView.layer.opacity = 0.0f;
            otherImageView.layer.opacity = 1.0f;
        } completionHandler:nil];
    });
    
    id temp = otherImageView;
    otherImageView = imageView;
    imageView = temp;
    
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
