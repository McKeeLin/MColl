//
//  CoderHelper.m
//  MColl
//
//  Created by McKee on 2016/12/27.
//  Copyright © 2016年 mckeelin. All rights reserved.
//

#import "CoderHelper.h"

#define HeaderTag   253
#define TailerTag   179

@implementation CoderHelper

+ (instancetype)helper
{
    static CoderHelper *_helper;
    static dispatch_once_t once;
    dispatch_once( &once, ^(void){
        _helper = [[CoderHelper alloc] init];
    });
    return _helper;
}

- (NSData*)encodeData:(NSData *)plainData
{
    Byte tag1;
    Byte tag2;
    [plainData getBytes:&tag1 length:1];
    [plainData getBytes:&tag2 range:NSMakeRange(plainData.length-1, 1)];
    if(tag1 == HeaderTag && tag2 == TailerTag )
    {
        return plainData;
    }
    
    Byte key = 1;
    int mod = plainData.length > 255 ? plainData.length % 255 : 2;
    NSLog(@"HEADER %d",mod);
    Byte headerByte = mod;
    Byte headTag = HeaderTag;
    Byte tailerTag = TailerTag;
    NSMutableData *encodedData = [[NSMutableData alloc] initWithCapacity:plainData.length+4];
    [encodedData appendBytes:&headTag length:1];
    [encodedData appendBytes:&headerByte length:1];
    for( NSInteger i = 0; i < plainData.length; i++ ){
        Byte subByte = 0;
        NSRange r = NSMakeRange(i, 1);
        [plainData getBytes:&subByte range:r];
        if( i % mod == 0 ){
            Byte newByte = subByte ^ key;
            [encodedData appendBytes:&newByte length:1];
        }
        else{
            [encodedData appendBytes:&subByte length:1];
        }
    }
    Byte tailerByte = time(NULL) % 10;
    [encodedData appendBytes:&tailerByte length:1];
    [encodedData appendBytes:&tailerTag length:1];
    return encodedData;
}

- (NSData*)decodeData:(NSData *)encodedData
{
    Byte headerTag;
    Byte tailerTag;
    Byte mod;
    [encodedData getBytes:&headerTag length:1];
    [encodedData getBytes:&tailerTag range:NSMakeRange(encodedData.length-1, 1)];
    [encodedData getBytes:&mod range:NSMakeRange(1, 1)];
    NSLog(@"==> mod:%d", (int)mod);
    if( headerTag == HeaderTag && tailerTag == TailerTag )
    {
        Byte key = 1;
        NSInteger len = encodedData.length - 4;
        
        NSMutableData *plainData = [[NSMutableData alloc] initWithCapacity:len];
        NSData *tempData = [encodedData subdataWithRange:NSMakeRange(2, len)];
        for( NSInteger i = 0; i < tempData.length; i++ ){
            Byte subByte = 0;
            NSRange r = NSMakeRange(i, 1);
            [tempData getBytes:&subByte range:r];
            if( i % mod == 0 ){
                Byte newByte = subByte ^ key;
                [plainData appendBytes:&newByte length:1];
            }
            else{
                [plainData appendBytes:&subByte length:1];
            }
        }
        return plainData;
    }
    else
    {
        return encodedData;
    }
}

@end
