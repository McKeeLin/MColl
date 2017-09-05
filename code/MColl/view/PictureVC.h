//
//  previewVC.h
//  OA2
//
//  Created by game-netease on 15/6/4.
//  Copyright (c) 2015年 game-netease. All rights reserved.
//

#import <QuickLook/QuickLook.h>
#import "groupObject.h"

@class GroupVC;

@interface PictureVC : QLPreviewController

@property groupObject *group;

@property NSInteger index;

@property (weak) GroupVC *groupVC;

@end
