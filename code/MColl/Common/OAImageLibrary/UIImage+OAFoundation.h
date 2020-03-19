//
//  UIImage+OAFoundation.h
//  OA2
//
//  Created by mtry on 2017/10/18.
//  Copyright © 2017年 game-netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (OAFoundation)

+ (UIImage *)imageWithColor:(UIColor *)color;

- (UIImage *)imageScaleAspectFillWithSize:(CGSize)size;

- (UIImage *)imageAddCornerWithRadius:(CGFloat)radius andSize:(CGSize)size;

@end
