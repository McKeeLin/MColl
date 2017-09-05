//
//  UILabel+Ex.m
//  Recruitment
//
//  Created by McKee on 2017/3/16.
//  Copyright © 2017年 OA.NETEASE. All rights reserved.
//

#import "UILabel+Ex.h"

@implementation UILabel (Ex)

- (CGFloat)heightForWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    CGRect originalFrame = frame;
    if( frame.size.height == 0 )
    {
        frame.size.height = 10;
    }
    frame.size.width = width;
    self.frame = frame;
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self sizeToFit];
    
    CGFloat height = self.frame.size.height;
    self.frame = originalFrame;
    return height;
}

@end
