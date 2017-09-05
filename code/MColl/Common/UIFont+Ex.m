//
//  UIFont+Ex.m
//  Recruitment
//
//  Created by McKee on 2017/6/27.
//  Copyright © 2017年 OA.NETEASE. All rights reserved.
//

#import "UIFont+Ex.h"

@implementation UIFont (Ex)

+ (instancetype)exFontWithName:(NSString *)name size:(CGFloat)size
{
    UIFont *font = [self fontWithName:name size:size];
    if( !font )
    {
        font = [UIFont systemFontOfSize:size];
    }
    return font;
}

@end
