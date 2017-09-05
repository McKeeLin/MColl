//
//  captureVC.h
//  MColl
//
//

#import "baseViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "groupObject.h"

@class collectionVC;
@class GroupVC;

@interface captureVC : baseViewController

@property (nonatomic) groupObject *group;

@property (weak) collectionVC *collVC;

@property (weak) GroupVC *groupVC;

@end
