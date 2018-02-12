//
//  LogHelper.h
//  WorkLoad
//
//  Created by McKee on 2017/8/16.
//  Copyright © 2017年 OA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogHelper : NSObject

@property (nonatomic) NSString *filePath;

+ (instancetype)helper;

- (void)appendLog:(NSString *)log;

- (NSString*)contents;

- (void)clear;

@end
