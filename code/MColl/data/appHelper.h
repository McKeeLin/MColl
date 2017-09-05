//
//  appHelper.h
//  MColl
//
//  Copyright (c) 2015年 mckeelin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class collectionVC;

@interface appHelper : NSObject

@property BOOL isIPhone;

@property (weak) collectionVC *collVC;

+ (instancetype)helper;

- (CGFloat)thumbnailWithHeight;

@end
