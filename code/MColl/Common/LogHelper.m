//
//  LogHelper.m
//  WorkLoad
//
//  Created by McKee on 2017/8/16.
//  Copyright © 2017年 OA. All rights reserved.
//

#import "LogHelper.h"
#import "dataHelper.h"

@interface LogHelper ()
{
    NSFileHandle *_handle;
}

@end

@implementation LogHelper

+ (instancetype)helper
{
    static LogHelper *gLogHelper;
    static dispatch_once_t once;
    dispatch_once(&once, ^(){
        gLogHelper = [[LogHelper alloc] init];
        ///*
        // 不需要日志时注掉这段
        //<<
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *dir = [[dataHelper helper] sharePath];
        NSString *filePath = [NSString stringWithFormat:@"%@/log.txt", dir];
        gLogHelper.filePath = filePath;
        
        //>>
        //*/
    });
    return gLogHelper;
}

- (void)setFilePath:(NSString *)filePath
{
    _filePath = filePath;
    if( _handle )
    {
        [_handle synchronizeFile];
        [_handle closeFile];
    }
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSString *path = [filePath stringByDeletingLastPathComponent];
    if( ![fm fileExistsAtPath:path] )
    {
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if( ![fm fileExistsAtPath:filePath] )
    {
        [fm createFileAtPath:filePath contents:nil attributes:nil];
    }
    _handle = [NSFileHandle fileHandleForWritingAtPath:filePath];
}

- (void)appendLog:(NSString*)log
{
    if( _handle )
    {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *time = [df stringFromDate:[NSDate date]];
        NSString *text = [NSString stringWithFormat:@"%@\r\n%@\r\n\r\n", time, log];
        NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
        [_handle seekToEndOfFile];
        [_handle seekToEndOfFile];
        [_handle writeData:data];
        [_handle synchronizeFile];
    }
    
    [self debuglog:log];
}

- (NSString*)contents
{
    NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:_filePath];
    NSData *data = [fh readDataToEndOfFile];
    NSString *contents = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return contents;
}

- (void)clear
{
    if( _handle )
    {
        [_handle truncateFileAtOffset:0];
        [_handle synchronizeFile];
    }
}

- (void)debuglog:(NSString*)log
{
#ifdef DEBUG
    NSLog(@"%@", log);
#endif
}

@end
