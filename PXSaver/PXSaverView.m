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
    
    NSMutableArray *imageQueue;
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
        
        imageView.layer.shouldRasterize = YES;
        
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
        
        otherImageView.layer.shouldRasterize = YES;
        
        [otherImageView setImage:otherImage];
        [self addSubview:otherImageView];
        
        imageQueue = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.500px.com/v1/photos?consumer_key=%@&feature=editors&rpp=10&image_size=5", @"zEJa8SeeKpcrqQQfHGzDiKuuHRQssAS09ppVl7Kb"]]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        NSArray *photos = [dictionary valueForKey:@"photos"];
        
        for (NSDictionary *photo in photos)
        {
            NSString *urlString = [photo valueForKey:@"image_url"];
            
            NSImage *downloadedImage = [[NSImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [imageQueue addObject:downloadedImage];
            });
        }
    }];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
}

- (void)animateOneFrame
{
    CGFloat widthTranslationMax = self.bounds.size.width/10;
    CGFloat heightTranslationMax = self.bounds.size.height/10;
    
    //crossfade 
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        [context setDuration:secondsPerCrossfade];
        imageView.layer.opacity = 1.0f;
        otherImageView.layer.opacity = 0.0f;
    } completionHandler:^{
        if (imageQueue.count > 0)
        {
            NSImage *object = [imageQueue objectAtIndex:0];
            imageView.image = object;
            
            [imageQueue removeObjectAtIndex:0];
            [imageQueue addObject:object];
        }
    }];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        [context setDuration:secondsPerAnimation + secondsPerCrossfade];
        CGAffineTransform transform = CGAffineTransformMakeTranslation(SSRandomFloatBetween(-widthTranslationMax, widthTranslationMax), SSRandomFloatBetween(-heightTranslationMax, heightTranslationMax));;
        CGFloat scaleFactor = SSRandomFloatBetween(1.4, 1.5);
        transform = CGAffineTransformScale(transform, scaleFactor, scaleFactor);
        imageView.layer.affineTransform = transform;
    } completionHandler:^{
        
    }];
    
    id temp = otherImageView;
    otherImageView = imageView;
    imageView = temp;
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
