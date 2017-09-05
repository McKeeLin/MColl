//
//  groupObject.h
//  MColl
//
//

#import <Foundation/Foundation.h>
#import "ItemObject.h"

typedef enum{
    PHOTO = 0,
    AUDIO,
    VIDEO,
    RECYCLE_BOX,
    SHARE_BOX
}GROUP_TYPE;

@interface groupObject : NSObject

@property NSString *title;

@property BOOL isPrivate;

@property GROUP_TYPE type;

@property NSString *path;

@property NSMutableArray *items;

- (void)rename:(NSString*)newName;

- (void)addItem:(ItemObject*)item;

- (UIImage*)thumbnailFromPath:(NSString*)path;

@end
