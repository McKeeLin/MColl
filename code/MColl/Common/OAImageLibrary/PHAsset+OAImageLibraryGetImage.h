//
//  PHAsset+OAImageLibraryGetImage.h
//  OAImageLibraryDemo
//
//  Created by mtry on 2017/8/15.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <Photos/Photos.h>

@interface PHAsset (OAImageLibraryGetImage)

///原图使用size:PHImageManagerMaximumSize
- (void)imageWithSize:(CGSize)size completeHandeler:(void(^)(UIImage *image))completeHandeler;
+ (void)imagesWithSize:(CGSize)size assets:(NSArray<PHAsset *> *)assets completeHandeler:(void(^)(NSArray<UIImage *> *successImages, NSArray<PHAsset *> *failureAssets))completeHandeler;

@end
