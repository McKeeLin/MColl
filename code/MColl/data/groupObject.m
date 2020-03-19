//
//  groupObject.m
//  MColl
//
//

#import "groupObject.h"
#import <ImageIO/ImageIO.h>
#import "appHelper.h"
#import "CoderHelper.h"

@interface groupObject()
{
    NSOperationQueue *_queue;
}

@end

@implementation groupObject

- (instancetype)init
{
    self = [super init];
    if( self )
    {
        _items = [[NSMutableArray alloc] initWithCapacity:0];
        _queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)rename:(NSString *)newName
{
    if( [newName isEqualToString:@"收件箱"] )
    {
        return;
    }
    
    NSArray *components = [_path componentsSeparatedByString:@"/"];
    NSString *oldName = components.lastObject;
    if( [newName isEqualToString:oldName] )
    {
        return;
    }
    
//    NSRange range = [_path rangeOfString:oldName options:NSBackwardsSearch];
//    NSString *newPath = [_path stringByReplacingCharactersInRange:range withString:newName];
    NSString *parentPath = [_path stringByDeletingLastPathComponent];
    NSString *newPath = [parentPath stringByAppendingPathComponent:newName];
    NSFileManager *fm = [NSFileManager defaultManager];
    if( [fm fileExistsAtPath:newPath isDirectory:nil] )
    {
        return;
    }
    
    NSError *error;
    BOOL allMoved = YES;
    [fm createDirectoryAtPath:newPath withIntermediateDirectories:YES attributes:nil error:&error];
    if( error )
    {
        return;
    }
    
    _title = newName;
    for( ItemObject *item in _items )
    {
        NSArray *components = [item.path componentsSeparatedByString:@"/"];
        NSString *fileName = components.lastObject;
        NSString *newFilePath = [newPath stringByAppendingPathComponent:fileName];
        NSError *err = nil;
        if( [fm moveItemAtPath:item.path toPath:newFilePath error:&err] )
        {
            item.path = newFilePath;
        }
        else
        {
            allMoved = NO;
            NSLog(@"move %@ to %@ failed,error:\n%@", item.path, newPath, err.localizedDescription);
        }
    }
    
    if( allMoved )
    {
        [fm removeItemAtPath:_path error:nil];
    }
    _path = newPath;

}

- (void)addItem:(ItemObject *)item
{
    /*
    if( !item.thumbnail )
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            item.thumbnail = [self thumbnailFromPath:item.path];
        });
    }
    */
    [_items addObject:item];
}

- (UIImage*)thumbnailFromPath:(NSString*)path
{
    UIImage *thumbnail;
    CGFloat width = [[appHelper helper] thumbnailWithHeight];
    NSData *encodedData = [NSData dataWithContentsOfFile:path];
    NSData *plainData = [[CoderHelper helper] decodeData:encodedData];
    CGImageSourceRef src = CGImageSourceCreateWithData((__bridge CFDataRef)plainData, NULL);
    CFDictionaryRef options = (__bridge CFDictionaryRef) @{
                                                           (id) kCGImageSourceCreateThumbnailWithTransform : @YES,
                                                           (id) kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                                           (id) kCGImageSourceThumbnailMaxPixelSize : @(width)
                                                           };
    
    CGImageRef scaledImageRef = CGImageSourceCreateThumbnailAtIndex(src, 0, options);
    thumbnail = [UIImage imageWithCGImage:scaledImageRef];
    CGImageRelease(scaledImageRef);
    CFRelease(src);
    return thumbnail;
}

- (NSMutableArray*)subGroups
{
    if( !_subGroups )
    {
        _subGroups = [NSMutableArray arrayWithCapacity:0];
    }
    return _subGroups;
}

@end
