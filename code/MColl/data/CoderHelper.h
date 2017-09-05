//
//  CoderHelper.h
//  MColl
//
//  Created by McKee on 2016/12/27.
//  Copyright © 2016年 mckeelin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoderHelper : NSObject

+ (instancetype)helper;

- (NSData*)encodeData:(NSData*)plainData;

- (NSData*)decodeData:(NSData*)encodedData;

@end
