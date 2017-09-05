//
//  icloudHelper.m
//  faceNote
//
//

#import "icloudHelper.h"
#import "myDocument.h"


@interface icloudHelper()<NSMetadataQueryDelegate>
{
    __strong NSMetadataQuery *query;
}
@end

@implementation icloudHelper
@synthesize containerUrl,appDocumentPath,iCloudDocumentPath;

+ (icloudHelper*)helper
{
    static icloudHelper *helper = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^(){
        helper = [[icloudHelper alloc] init];
    });
    return helper;
}

/* device
 [NSBundle mainBundle].bundlePath:  /private/var/mobile/Containers/Bundle/Application/C7631F42-6812-4F14-9354-8CF27E80662B/faceNote.app
 NSHomeDirectory():                 /var/mobile/Containers/Data/Application/83466396-7FF2-452F-B01D-14ABF56C8021
 NSDocumentDirectory:               /var/mobile/Containers/Data/Application/83466396-7FF2-452F-B01D-14ABF56C8021/Documents
 */

- (id)init
{
    self = [super init];
    if( self )
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        /*
         /Users/game-netease/Library/Developer/CoreSimulator/Devices/BAC90603-86C0-4292-870B-A0534E0616A2/data/Applications/5A8EC6C5-7D38-4056-AB97-B95053573739/Documents
         */
        self.appDocumentPath = [paths objectAtIndex:0];
        NSLog(@"app bundle path:\n%@", [NSBundle mainBundle].bundlePath);
        NSLog(@"app home directory:\n%@", NSHomeDirectory());
        NSLog(@"app document path:\n%@", self.appDocumentPath);
        query = [[NSMetadataQuery alloc] init];
        [query setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
        query.delegate = self;
        query.predicate = [NSPredicate predicateWithFormat:@"%K like '*'", NSMetadataItemPathKey];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGatheringDidStart:) name:NSMetadataQueryDidStartGatheringNotification object:query];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGatheringProgress:) name:NSMetadataQueryGatheringProgressNotification object:query];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onQueryDidUpdate:) name:NSMetadataQueryDidUpdateNotification object:query];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGatheringFinished:) name:NSMetadataQueryDidFinishGatheringNotification object:query];
        [self isEnable];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)queryGroups
{
    [query startQuery];
}

/*
 url:file:///Users/game-netease/Library/Application%20Support/iPhone%20Simulator/7.1/Library/Mobile%20Documents/D9KLEDDTR3~com~mckeelin~facenote/
 url:file:///private/var/mobile/Library/Mobile%20Documents/D9KLEDDTR3~com~mckeelin~facenote/
 iPhone 6:/Users/game-netease/Library/Developer/CoreSimulator/Devices/46626BA8-5466-4BD9-8B51-C51F5E00D37B/data/Library/Mobile Documents/iCloud~com~mckeelin~mcoll
 
 iPhone 5 8.1: /Users/game-netease/Library/Developer/CoreSimulator/Devices/44BA26C4-A084-46D4-BCBC-B662E36BEBC6/data/Library/Mobile Documents/iCloud~com~mckeelin~mcoll
 */
- (BOOL)isEnable
{
    NSString *Id = @"iCloud.com.mckeelin.mcoll";
    self.containerUrl = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:Id];
    self.iCloudDocumentPath = [[self.containerUrl path] stringByAppendingPathComponent:@"Documents"];
    NSLog(@"%s, url:%@", __func__, containerUrl);
    return  containerUrl != nil;
}

- (void)movePhotoToICloud:(NSString *)photoPath
{
    NSString *prefix = [NSString stringWithFormat:@"%@/", NSHomeDirectory()];
    NSString *suffix = [photoPath substringFromIndex:prefix.length];
    NSRange range = [suffix rangeOfString:@"/" options:NSBackwardsSearch];
    NSString *destDirSuffix = [suffix substringToIndex:range.location];
    NSMutableArray *suffixComponents = [NSMutableArray arrayWithArray:[suffix componentsSeparatedByString:@"/"]];
    [suffixComponents removeLastObject];
    NSURL *destDirUrl = [containerUrl URLByAppendingPathComponent:destDirSuffix];
    NSError *err = nil;
    [[NSFileManager defaultManager] createDirectoryAtURL:destDirUrl withIntermediateDirectories:YES attributes:nil error:&err];
    NSLog(@"%s, err:%@", __func__, err);
    NSString *destPath = [NSString stringWithFormat:@"%@%@",containerUrl.absoluteString, suffix];
    NSURL *destUrl = [NSURL URLWithString:destPath];
    BOOL bExist = [[NSFileManager defaultManager] isUbiquitousItemAtURL:destUrl];
    if( !bExist )
    {
        NSURL *srcUrl = [NSURL fileURLWithPath:photoPath isDirectory:NO];
        NSError *error = [[NSError alloc] init];
        myDocument *doc = [[myDocument alloc] initWithFileURL:srcUrl];
        doc.data = [NSData dataWithContentsOfFile:photoPath];
        NSFileCoordinator *fc = [[NSFileCoordinator alloc] initWithFilePresenter:doc];
        [fc coordinateWritingItemAtURL:srcUrl options:NSFileCoordinatorWritingForMoving writingItemAtURL:destUrl options:NSFileCoordinatorWritingForReplacing error:&error byAccessor:^(NSURL *fileURL, NSURL *destURL){
            NSError *e;
            BOOL r = [[NSFileManager defaultManager] setUbiquitous:YES itemAtURL:fileURL destinationURL:destUrl error:&e];
            if (r) {
                [fc itemAtURL:fileURL didMoveToURL:destUrl];
                [doc updateChangeCount:UIDocumentChangeDone];
            }
        }];
    }
}

- (id)metadataQuery:(NSMetadataQuery *)query replacementObjectForResultObject:(NSMetadataItem *)result
{
    NSLog(@"%s", __func__);
    return result;
}

- (id)metadataQuery:(NSMetadataQuery *)query replacementValueForAttribute:(NSString *)attrName value:(id)attrValue
{
    NSLog(@"%s", __func__);
    return attrValue;
}

- (void)onGatheringFinished:(NSNotification*)notification
{
    NSLog(@"%s,%@", __func__, notification);
    NSArray *result = query.results;
    for( NSMetadataItem *item in result )
    {
        /*
        for( NSDictionary *attr in item.attributes )
        {
            NSLog(@"%@", attr);
        }
        */
        
        BOOL isDownloading = [[item valueForAttribute:NSMetadataUbiquitousItemIsDownloadingKey] boolValue];
        BOOL isDownloaded = [[item valueForAttribute:NSMetadataUbiquitousItemIsDownloadedKey] boolValue];
        if( !isDownloaded && !isDownloading ){
            NSError *err = nil;
            NSURL * fileURL = [item valueForAttribute:NSMetadataItemURLKey];
            BOOL result = [[NSFileManager defaultManager] startDownloadingUbiquitousItemAtURL:fileURL error:&err];
            if( !result && err ){
                NSLog(@"%s, error:%@", __func__, err);
            }
            else{
                NSLog(@"start download %@ success", fileURL);
            }
        }
    }
    [query stopQuery];
}

- (void)onGatheringDidStart:(NSNotification*)notification
{
    NSLog(@"%s,%@", __func__, notification);
}

- (void)onQueryDidUpdate:(NSNotification*)notification
{
    NSDictionary *info = notification.userInfo;
    NSLog(@"%s,%@", __func__, info);
}

- (void)onGatheringProgress:(NSNotification*)notification
{
    NSDictionary *info = notification.userInfo;
    NSLog(@"%s,%@", __func__, info);
}


#pragma mark- file encode and decode

- (void)encodeFile:(NSString *)file to:(NSString *)destFile
{
    NSData *srcData = [NSData dataWithContentsOfFile:file];
    Byte key = 1;
    time_t t = time(NULL);
    int mod = t % 255;
    NSLog(@"HEADER %d",mod);
    Byte headerByte = mod;
    NSMutableData *destData = [[NSMutableData alloc] initWithCapacity:srcData.length+2];
    [destData appendBytes:&headerByte length:1];
    for( NSInteger i = 0; i < srcData.length; i++ ){
        Byte subByte = 0;
        NSRange r = NSMakeRange(i, 1);
        [srcData getBytes:&subByte range:r];
        if( i % 2 == 1 ){
            Byte newByte = subByte ^ key;
            [destData appendBytes:&newByte length:1];
        }
        else{
            [destData appendBytes:&subByte length:1];
        }
    }
    Byte tailerByte = time(NULL) % 10;
    [destData appendBytes:&tailerByte length:1];
    [destData writeToFile:destFile atomically:YES];
}

- (void)decodeFile:(NSString *)file to:(NSString *)destFile
{
    NSData *srcData = [NSData dataWithContentsOfFile:file];
    Byte key = 1;
    NSMutableData *destData = [[NSMutableData alloc] initWithCapacity:srcData.length-1];
    for( NSInteger i = 1; i < srcData.length - 1; i++ ){
        Byte subByte = 0;
        NSRange r = NSMakeRange(i, 1);
        [srcData getBytes:&subByte range:r];
        if( (i-1) % 2 == 1 ){
            Byte newByte = subByte ^ key;
            [destData appendBytes:&newByte length:1];
        }
        else{
            [destData appendBytes:&subByte length:1];
        }
    }
    [destData writeToFile:destFile atomically:YES];
}


- (void)initForKeyValueStore
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyValueChangedNotification:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:nil];
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
}

- (void)onKeyValueChangedNotification:(NSNotification*)notification
{
    ;
}

@end
