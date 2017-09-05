//
//  ItemObject.h
//  MColl
//
//  Created by McKee on 2016/12/16.
//  Copyright © 2016年 mckeelin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define ThumbnilCompletedNotification   @"ThumbnilCompletedNotification"

@interface ItemObject : NSObject

@property NSString *name;

@property NSString *path;

@property NSString *fileName;

@property UIImage *image;

@property UIImage *thumbnail;

@property (nonatomic) BOOL selected;

- (void)loadThumbnail;

- (void)loadThumbnilInThread;

@end
