//
//  dataHelper.m
//  MColl
//
// https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/1274986687/testflight?section=iosbuilds
//

#import "dataHelper.h"
#import "CoderHelper.h"
#import "icloudHelper.h"
#import "appHelper.h"
#import <ImageIO/ImageIO.h>
#import "LogHelper.h"
#import "NSArray+Ex.h"

#define COLLECTION_PATH_NAME @"collection"
#define RECYCLE_BOX_NAME    @"recycleBox"

@interface dataHelper ()
{
    NSString *_documentsPath;
    NSString *_bundlePath;
    NSString *_libraryPath;
    NSString *_collPath;
    NSOperationQueue *_queue;
}

@end

@implementation dataHelper

+ (instancetype)helper
{
    static dataHelper *_helper;
    static dispatch_once_t once;
    dispatch_once( &once, ^(void){
        _helper = [[dataHelper alloc] init];
    });
    return _helper;
}

// documentsPath:   /Users/macmini_oa1/Library/Developer/CoreSimulator/Devices/1246EEF0-1B81-45D5-B34C-2937CDB1C28E/data/Containers/Data/Application/CE557749-E9BF-48A8-A1FC-2C7334B88031/Documents
// documentsPath:  /var/mobile/Containers/Data/Application/9C22C0E4-8A9E-44A7-B19C-EC38E08305CA/Documents

/*
 -[icloudHelper isEnable], url:file:///private/var/mobile/Library/Mobile%20Documents/iCloud~com~mckeelin~mcoll/
 
 */
- (instancetype)init
{
    self = [super init];
    if( self ){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _documentsPath = [paths firstObject];
        _bundlePath = [NSBundle mainBundle].bundlePath;
        _collPath = [_documentsPath stringByAppendingPathComponent:COLLECTION_PATH_NAME];
        paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        _libraryPath = [paths firstObject];
        paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _cachePath = paths.firstObject;
        
        _queue = [[NSOperationQueue alloc] init];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        if( ![fm fileExistsAtPath:_collPath] )
        {
            [fm createDirectoryAtPath:_collPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSLog(@"%@", _collPath);
        
        if( ![fm fileExistsAtPath:_cachePath] )
        {
            [fm createDirectoryAtPath:_cachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSLog(@"cache path:\n%@", _cachePath);
        
        _groups = [[NSMutableArray alloc] initWithCapacity:0];
        [self initGroups];
        [_groups exAddObject:self.shareGroup];
    }
    return self;
}

- (groupObject*)shareGroup
{
    if( !_shareGroup )
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *dirName = @"收件箱";
        NSString *sharePath = [[self sharePath] stringByAppendingPathComponent:dirName];
        NSError *error;
        if( ![fm fileExistsAtPath:sharePath] )
        {
            [fm createDirectoryAtPath:sharePath withIntermediateDirectories:YES attributes:nil error:&error];
        }
        _shareGroup = [[groupObject alloc] init];
        _shareGroup.title = dirName;
        _shareGroup.path = sharePath;
        _shareGroup.type = SHARE_BOX;
        NSDirectoryEnumerator *enumerator = [fm enumeratorAtPath:sharePath];
        NSString *subItem = nil;
        while( subItem = [enumerator nextObject] )
        {
            [enumerator skipDescendants];
            if( [subItem isEqualToString:@"Caches"]
               || [subItem isEqualToString:@".DS_Store"] )
            {
                continue;
            }
            NSRange range = [subItem rangeOfString:@"."];
            if( range.location == 0 )
            {
                continue;
            }
            ItemObject *item = [[ItemObject alloc] init];
            item.path = [_shareGroup.path stringByAppendingPathComponent:subItem];
            item.fileName = subItem;
            [_shareGroup addItem:item];
        }
    }
    return _shareGroup;
}

- (groupObject*)recycleBoxGroup
{
    if( !_recycleBoxGroup )
    {
        _recycleBoxGroup = [[groupObject alloc] init];
        _recycleBoxGroup.title = @"回收站";
        _recycleBoxGroup.type = RECYCLE_BOX;
        _recycleBoxGroup.path = [self recycleBoxPath];
    }
    
    [_recycleBoxGroup.items removeAllObjects];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [fm enumeratorAtPath:_recycleBoxGroup.path];
    NSString *subItem;
    while( subItem = [enumerator nextObject] )
    {
        [enumerator skipDescendants];
        if( [subItem isEqualToString:@"Caches"]
           || [subItem isEqualToString:@".DS_Store"] )
        {
            continue;
        }
        NSRange range = [subItem rangeOfString:@"."];
        if( range.location == 0 )
        {
            continue;
        }
        ItemObject *item = [[ItemObject alloc] init];
        item.path = [_recycleBoxGroup.path stringByAppendingPathComponent:subItem];
        item.fileName = subItem;
        [_recycleBoxGroup addItem:item];
    }
    return _recycleBoxGroup;
}

- (NSString*)nameForCommingFile:(NSURL*)fileUrl
{
    return nil;
}

- (NSString*)sharePath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *url = [fm containerURLForSecurityApplicationGroupIdentifier:@"group.com.mckeelin.mcoll"];
    NSString *path = [url.absoluteString stringByReplacingOccurrencesOfString:@"file:" withString:@""];
    NSLog(@"==== share path:\n%@", path);
    return path;
}

- (NSString*)recycleBoxPath
{
    NSString *path = [_documentsPath stringByAppendingPathComponent:RECYCLE_BOX_NAME];
    NSFileManager *fm = [NSFileManager defaultManager];
    if( ![fm fileExistsAtPath:path] )
    {
        NSError *error;
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    }
    return path;
}

- (NSString*)cacheFileForFile:(NSString *)file
{
    NSArray *components = [file pathComponents];
    NSString *fileName = components.lastObject;
    NSString *cacheFile = [_cachePath stringByAppendingPathComponent:fileName];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if( ![fm fileExistsAtPath:cacheFile] )
    {
        NSData *encodedData = [NSData dataWithContentsOfFile:file];
        NSData *plainData = [[CoderHelper helper] decodeData:encodedData];
        [plainData writeToFile:cacheFile atomically:YES];
    }
    return cacheFile;
}

- (NSString*)nameForCapture
{
    NSDate *date = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyyMMddHHmmss_SSS";
    NSString *name = [NSString stringWithFormat:@"%@.jpeg", [df stringFromDate:date]];
    return name;
}

- (NSString*)pathForGroup:(NSString*)groupName createWhenNotExist:(BOOL)create{
    NSString *path;
    path = [_collPath stringByAppendingPathComponent:groupName];
    NSFileManager *fm = [NSFileManager defaultManager];
    if( [fm fileExistsAtPath:path] ){
        return path;
    }
    else if( create ){
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        return path;
    }
    else {
        return nil;
    }
}

- (void)initGroups;
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:0];
    NSDirectoryEnumerator *enumerator = [fm enumeratorAtPath:_collPath];
    NSString *subItem;
    while( subItem = [enumerator nextObject] ){
        [enumerator skipDescendents];
        if( [subItem isEqualToString:@"Caches"] )
        {
            continue;
        }
        NSRange range = [subItem rangeOfString:@"."];
        if( range.location == 0 )
        {
            continue;
        }
        groupObject *group = [[groupObject alloc] init];
        group.title = subItem;
        group.path = [_collPath stringByAppendingPathComponent:subItem];
        
        NSDirectoryEnumerator *subenum = [fm enumeratorAtPath:group.path];
        NSString *subsubItem;
        while( subsubItem = [subenum nextObject] )
        {
            [subenum skipDescendants];
            if( [subsubItem isEqualToString:@"Caches"]
               || [subsubItem isEqualToString:@".DS_Store"] )
            {
                continue;
            }
            NSRange range = [subsubItem rangeOfString:@"."];
            if( range.location == 0 )
            {
                continue;
            }
            ItemObject *item = [[ItemObject alloc] init];
            item.path = [group.path stringByAppendingPathComponent:subsubItem];
            item.fileName = subsubItem;
            [group addItem:item];
        }
        [arr addObject:group];
    }
    
    if( arr.count > 0 )
    {
        [_groups addObjectsFromArray:arr];
    }
    else{
        ;
    }
}

- (void)createGroupWithName:(NSString *)name
{
    for( groupObject *group in _groups )
    {
        if( [group.title isEqualToString:name] )
        {
            return;
        }
    }
    
    groupObject *group = [[groupObject alloc] init];
    group.title = name;
    group.path = [self pathForGroup:name createWhenNotExist:YES];
    
    groupObject *shareGroup = [self findGroupByName:@"收件箱"];
    [_groups removeObject:shareGroup];
    [_groups addObject:group];
    [_groups exAddObject:shareGroup];
}

- (void)saveCaputreData:(NSData *)data toGroup:(groupObject*)group
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *dir = [[dataHelper helper] pathForGroup:group.title createWhenNotExist:YES];
        NSString *fileName = [[dataHelper helper] nameForCapture];
        NSString *filePath = [dir stringByAppendingPathComponent:fileName];
        NSData *encodedData = [[CoderHelper helper] encodeData:data];
        [encodedData writeToFile:filePath atomically:YES];
        
        ItemObject *item = [[ItemObject alloc] init];
        item.path = filePath;
        item.fileName = fileName;
        [group.items addObject:item];
        /*
        [[icloudHelper helper] movePhotoToICloud:filePath];
        */
        [[NSNotificationCenter defaultCenter] postNotificationName:NN_CAPTURE_FINISH object:nil];
    });
}

/*
 file:/Users/mckee/Library/Developer/CoreSimulator/Devices/E356FB99-210E-4DBC-BD31-694DE61FFEF2/data/Containers/Shared/AppGroup/A8FAF7CF-3CF4-4A07-BB11-3946F7607AB5
 */
- (void)saveShareFile:(NSURL*)fileUrl
{
    NSString *filePath = fileUrl.absoluteString;
    NSArray *components = [filePath componentsSeparatedByString:@"/"];
    NSString *fileName = components.lastObject;
    NSString *dir = _shareGroup.path;
    NSString *destPath = [dir stringByAppendingPathComponent:fileName];
    NSError *error;
    NSData *srcData = [NSData dataWithContentsOfURL:fileUrl options:NSDataReadingMappedIfSafe error:&error];
    if( error )
    {
        NSString *err = [NSString stringWithFormat:@"dataWithContentsOfURL:%@\n error:%@", fileUrl.absoluteString, error.localizedDescription];
        [[LogHelper helper] appendLog:err];
        return;
    }
    
    NSString *log = [NSString stringWithFormat:@"%s\nfile:%@\nlenght:%ld", __func__, filePath, srcData.length];
    [[LogHelper helper] appendLog:log];
    NSData *encodeData = [[CoderHelper helper] encodeData:srcData];
    [encodeData writeToFile:destPath atomically:YES];
}

- (void)reloadGroups
{
    [_groups removeAllObjects];
    [self initGroups];
}

- (groupObject*)findGroupByName:(NSString*)name
{
    for( groupObject *group in _groups )
    {
        if( [group.title isEqualToString:name] )
        {
            return group;
        }
    }
    return nil;
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

- (BOOL)moveItem:(ItemObject *)item from:(groupObject *)from to:(groupObject *)to
{
    BOOL succeeded = NO;
    NSString *dest = [to.path stringByAppendingPathComponent:item.fileName];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    if( [fm moveItemAtPath:item.path toPath:dest error:&error] )
    {
        [from.items removeObject:item];
        item.path = dest;
        [to.items addObject:item];
        succeeded = YES;
    }
    return succeeded;
}

- (void)removeGroup:(groupObject *)group
{
    for( NSInteger i = group.items.count-1; i >= 0; i-- )
    {
        ItemObject *item = group.items[i];
        [self moveItem:item from:group to:self.recycleBoxGroup];
    }
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    if( [fm removeItemAtPath:group.path error:&error] )
    {
        [_groups removeObject:group];
    }
}

- (BOOL)deleteItem:(ItemObject*)item fromGroup:(groupObject*)group
{
    NSString *name = [NSString stringWithFormat:@"%@_%@", group.title, item.fileName];
    NSString *dest = [[[dataHelper helper] recycleBoxPath] stringByAppendingPathComponent:name];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    if( [fm moveItemAtPath:item.path toPath:dest error:&error] )
    {
        item.fileName = name;
        item.path = dest;
        [group.items removeObject:item];
        [_recycleBoxGroup.items addObject:item];
        return YES;
    }
    return NO;
    
}

- (BOOL)restoreItemFromRecycleBox:(ItemObject*)item
{
    NSArray *components = [item.fileName componentsSeparatedByString:@"_"];
    NSString *groupName = components.firstObject;
    NSString *fileName = components.lastObject;
    groupObject *destGroup = [[dataHelper helper] findGroupByName:groupName];
    if( destGroup )
    {
        NSString *dest = [NSString stringWithFormat:@"%@/%@", destGroup.path, fileName];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error;
        if( [fm moveItemAtPath:item.path toPath:dest error:&error] )
        {
            item.path = dest;
            item.fileName = fileName;
            [_recycleBoxGroup.items removeObject:item];
            [destGroup.items addObject:item];
            return YES;
        }
    }
    return NO;
}

@end
