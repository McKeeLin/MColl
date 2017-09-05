//
//  dataHelper.h
//  MColl
//
//

#import <Foundation/Foundation.h>
#import "groupObject.h"
#import "ItemObject.h"

#define NN_CAPTURE_FINISH   @"capture_finish_notification_name"

@interface dataHelper : NSObject

@property NSMutableArray *groups;

@property (nonatomic) groupObject *shareGroup;

@property (nonatomic) groupObject *recycleBoxGroup;

@property (nonatomic) NSString *cachePath;

+ (instancetype)helper;

- (NSString*)nameForCommingFile:(NSURL*)fileUrl;

- (NSString*)nameForCapture;

- (NSString*)pathForGroup:(NSString*)groupName createWhenNotExist:(BOOL)create;

- (NSString*)sharePath;

- (NSString*)recycleBoxPath;

- (NSString*)cacheFileForFile:(NSString*)file;

- (groupObject*)findGroupByName:(NSString*)name;

- (void)createGroupWithName:(NSString*)name;

- (void)saveCaputreData:(NSData*)data toGroup:(groupObject*)group;

- (void)saveShareFile:(NSURL*)fileUrl;

- (void)reloadGroups;

- (UIImage*)thumbnailFromPath:(NSString*)path;

- (BOOL)moveItem:(ItemObject*)item from:(groupObject*)from to:(groupObject*)to;

- (void)removeGroup:(groupObject*)group;

- (BOOL)deleteItem:(ItemObject*)item fromGroup:(groupObject*)group;

- (BOOL)restoreItemFromRecycleBox:(ItemObject*)item;

@end
