//
//  OAImageLibraryDataManager.h
//  OAImageLibraryDemo
//
//  Created by mtry on 2017/8/15.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <Photos/Photos.h>

@interface PHAssetCollection (OAImageLibrary)

@property (nonatomic, copy) NSArray *assets;

@end

@interface OAImageLibraryDataManager : NSObject

+ (void)fetchCollectionDataWithCompleteHandler:(void(^)(NSArray <PHAssetCollection *> *listItems))completeHandler;

@end
