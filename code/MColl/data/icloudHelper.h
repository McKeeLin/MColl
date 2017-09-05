//
//  icloudHelper.h
//  faceNote
//
//  Created by 林景隆 on 4/23/14.
//  Copyright (c) 2014 cndatacom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface icloudHelper : NSObject
@property NSURL *containerUrl;
@property NSString *appDocumentPath;
@property NSString *iCloudDocumentPath;
@property BOOL synchronizationEnabled;

+ (icloudHelper*)helper;

- (void)queryGroups;

- (BOOL)isEnable;

- (void)movePhotoToICloud:(NSString*)photoPath;

- (void)initForKeyValueStore;

@end
