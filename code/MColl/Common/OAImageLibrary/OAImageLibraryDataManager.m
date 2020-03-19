//
//  OAImageLibraryDataManager.m
//  OAImageLibraryDemo
//
//  Created by mtry on 2017/8/15.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "OAImageLibraryDataManager.h"
#import <objc/runtime.h>

@implementation PHAssetCollection (OAImageLibrary)

- (void)setAssets:(NSArray *)assets
{
    objc_setAssociatedObject(self, @selector(assets), assets, OBJC_ASSOCIATION_COPY);
}

- (NSArray *)assets
{
    return objc_getAssociatedObject(self, @selector(assets));
}

@end

@implementation OAImageLibraryDataManager

+ (void)fetchCollectionDataWithCompleteHandler:(void(^)(NSArray <PHAssetCollection *> *listItems))completeHandler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *listItems = [NSMutableArray array];
        
        PHFetchResult *systemResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
        [systemResult enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL * _Nonnull stop) {
            if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary ||
                collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumRecentlyAdded ||
                collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumPanoramas ||
                collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumVideos )
            {
                [listItems addObject:collection];
            }
        }];
        
        PHFetchResult *customResult = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        [customResult enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([collection isKindOfClass:[PHAssetCollection class]])
            {//我的相册里有iPhoto事件，会是这样的对象PHCollectionList
                [listItems addObject:collection];
            }
        }];
        
        [listItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *assets = [self fetchAssetsForAssetCollection:collection];
            if (assets.count)
            {
                collection.assets = assets;
            }
            else
            {
                [listItems removeObject:collection];
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completeHandler(listItems);
        });
    });
}

+ (NSArray *)fetchAssetsForAssetCollection:(PHAssetCollection *)collection
{
    NSMutableArray *listItems = [NSMutableArray array];
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType=%ld || mediaType=%ld", PHAssetMediaTypeImage,PHAssetMediaTypeVideo];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:options];
    [result enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        [listItems addObject:asset];
    }];
    return listItems;
}

@end


