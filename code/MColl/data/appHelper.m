//
//  appHelper.m
//  MColl
//
//  Copyright (c) 2015年 mckeelin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "appHelper.h"

@implementation appHelper

+ (instancetype)helper
{
    static appHelper *helper = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^(){
        helper = [[appHelper alloc] init];
    });
    return helper;
}

- (instancetype)init
{
    self = [super init];
    if( self ){
        self.isIPhone = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
        _thumbnailWithHeight = _isIPhone ? 70 : 80;;
    }
    return self;
}

/*
- (CGFloat)thumbnailWithHeight
{
    return self.isIPhone ? 70 : 80;
}
*/

@end
