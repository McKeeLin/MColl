//
//  OAImageLibraryPreviewViewController.h
//  OAImageLibraryDemo
//
//  Created by mtry on 2017/8/15.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;

@class OAImageLibraryPreviewViewController;

@protocol OAImageLibraryPreviewViewControllerDelegate <NSObject>

- (void)imageLibraryPreviewViewController:(OAImageLibraryPreviewViewController *)previewViewController addAssetLocalIdentifier:(NSString *)localIdentifier;
- (void)imageLibraryPreviewViewController:(OAImageLibraryPreviewViewController *)previewViewController removeAssetLocalIdentifier:(NSString *)localIdentifier;
- (void)imageLibraryPreviewViewControllerFinished:(OAImageLibraryPreviewViewController *)previewViewController;

@end

@interface OAImageLibraryPreviewViewController : UIViewController

- (instancetype)initWithShowAssets:(NSArray<PHAsset *> *)showAssets selectAssets:(NSArray<PHAsset *> *)selectAssets;

@property (nonatomic, weak) id<OAImageLibraryPreviewViewControllerDelegate>delegate;
@property (nonatomic, assign) NSInteger showIndex;

@end
