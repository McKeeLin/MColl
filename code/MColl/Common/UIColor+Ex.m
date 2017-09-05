//
//  UIColor+Ex.m
//  Demo
//
//  Created by McKee on 2017/6/8.
//  Copyright © 2017年 OA.NetEase. All rights reserved.
//

#import "UIColor+Ex.h"

@implementation UIColor (Ex)

+ (UIColor*)fromRGB:(NSInteger)rgb
{
    return [UIColor colorWithRed:((float)((rgb & 0xFF0000) >> 16))/255.0
                           green:((float)((rgb & 0xFF00) >> 8))/255.0
                            blue:((float)(rgb & 0xFF))/255.0 alpha:1.0];
    
}

+ (UIColor*)fromRed:(int)red green:(int)green blue:(int)blue
{
    return [UIColor colorWithRed:red*1.00/255.00
                           green:green*1.00/255.00
                            blue:blue*1.00/255.00
                           alpha:1.0];
}

@end
