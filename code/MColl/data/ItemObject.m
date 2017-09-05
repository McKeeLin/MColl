//
//  ItemObject.m
//  MColl
//
//  Created by McKee on 2016/12/16.
//  Copyright © 2016年 mckeelin. All rights reserved.
//

#import "ItemObject.h"
#import "appHelper.h"
#import "CoderHelper.h"
#import <ImageIO/ImageIO.h>

@implementation ItemObject

- (void)loadThumbnail
{
    CGFloat width = [[appHelper helper] thumbnailWithHeight];
    NSData *encodedData = [NSData dataWithContentsOfFile:_path];
    NSData *plainData = [[CoderHelper helper] decodeData:encodedData];
    CGImageSourceRef src = CGImageSourceCreateWithData((__bridge CFDataRef)plainData, NULL);
    CFDictionaryRef options = (__bridge CFDictionaryRef) @{
                                                           (id) kCGImageSourceCreateThumbnailWithTransform : @YES,
                                                           (id) kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                                           (id) kCGImageSourceThumbnailMaxPixelSize : @(width)
                                                           };
    
    CGImageRef scaledImageRef = CGImageSourceCreateThumbnailAtIndex(src, 0, options);
    _thumbnail = [UIImage imageWithCGImage:scaledImageRef];
    CGImageRelease(scaledImageRef);
    CFRelease(src);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ThumbnilCompletedNotification object:self];
}

- (void)loadThumbnilInThread
{
    [NSThread detachNewThreadSelector:@selector(loadThumbnail) toTarget:self withObject:nil];
}

@end
