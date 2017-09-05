//
//  GroupVC.h
//  MColl
//
//  Created by McKee on 2017/4/28.
//  Copyright © 2017年 mckeelin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "groupObject.h"

@class collectionVC;

@interface GroupVC : UIViewController

@property groupObject *group;

@property (weak) collectionVC *collVC;

- (void)onCaptureFinished;

- (void)reload;

@end
