//
//  UIImage+OAFoundation.m
//  OA2
//
//  Created by mtry on 2017/10/18.
//  Copyright © 2017年 game-netease. All rights reserved.
//

#import "UIImage+OAFoundation.h"

@implementation UIImage (OAFoundation)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (UIImage *)imageScaleAspectFillWithSize:(CGSize)size
{
    if (self)
    {
        CGSize imageSize = self.size;
        CGSize targetSize = size;
        CGFloat imageScaleWH = imageSize.width / imageSize.height;
        CGFloat targetScaleWH = targetSize.width / targetSize.height;
        CGRect newImageRect = CGRectZero;
        if (imageScaleWH < targetScaleWH)
        {
            newImageRect.size.width = targetSize.width;
            newImageRect.size.height = newImageRect.size.width / imageScaleWH;
        }
        else
        {
            newImageRect.size.height = targetSize.height;
            newImageRect.size.width = newImageRect.size.height * imageScaleWH;
        }
        
        UIGraphicsBeginImageContextWithOptions(newImageRect.size, NO, [UIScreen mainScreen].scale);
        [self drawInRect:newImageRect];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        if (newImage)
        {
            CGRect rect = CGRectZero;
            rect.origin.x = (newImageRect.size.width - targetSize.width) / 2 * [UIScreen mainScreen].scale;
            rect.origin.y = (newImageRect.size.height - targetSize.height) / 2 * [UIScreen mainScreen].scale;
            rect.size.width = targetSize.width * [UIScreen mainScreen].scale;
            rect.size.height = targetSize.height * [UIScreen mainScreen].scale;
            CGImageRef imageRef = CGImageCreateWithImageInRect([newImage CGImage], rect);
            UIImage *result = [UIImage imageWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
            return result;
        }
    }
    return nil;
}

- (UIImage *)imageAddCornerWithRadius:(CGFloat)radius andSize:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
    CGContextAddPath(ctx,path.CGPath);
    CGContextClip(ctx);
    [self drawInRect:rect];
    CGContextDrawPath(ctx, kCGPathFillStroke);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
