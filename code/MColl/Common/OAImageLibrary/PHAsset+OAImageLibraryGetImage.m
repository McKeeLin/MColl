//
//  PHAsset+OAImageLibraryGetImage.m
//  OAImageLibraryDemo
//
//  Created by mtry on 2017/8/15.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <objc/runtime.h>
#import "PHAsset+OAImageLibraryGetImage.h"

@implementation PHAsset (OAImageLibraryGetImage)

- (void)setImage:(UIImage *)image
{
    objc_setAssociatedObject(self, @selector(image), image, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIImage *)image
{
    return objc_getAssociatedObject(self, @selector(image));
}

+ (void)imagesWithSize:(CGSize)size assets:(NSArray<PHAsset *> *)assets completeHandeler:(void(^)(NSArray<UIImage *> *successImages, NSArray<PHAsset *> *failureAssets))completeHandeler
{
    @synchronized (self) {
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t queue = dispatch_get_main_queue();
        
        for (PHAsset *asset in assets)
        {
            dispatch_group_enter(group);
            dispatch_group_async(group, queue, ^{
                [asset imageWithSize:size completeHandeler:^(UIImage *image) {
                    [asset setImage:image];
                    dispatch_group_leave(group);
                }];
            });
        }
        
        dispatch_group_notify(group, queue, ^{
            NSMutableArray *successImages = [NSMutableArray array];
            NSMutableArray *failureAssets = [NSMutableArray array];
            for (PHAsset *asset in assets)
            {
                UIImage *image = [asset image];
                if (image)
                {
                    [successImages addObject:image];
                }
                else
                {
                    [failureAssets addObject:asset];
                }
            }
            completeHandeler(successImages, failureAssets);
        });
    }
}

- (void)imageWithSize:(CGSize)size completeHandeler:(void(^)(UIImage *image))completeHandeler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.synchronous = YES;
        CGSize targetSize = size;
        if (CGSizeEqualToSize(size, PHImageManagerMaximumSize))
        {
            targetSize.width = [UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale;
            targetSize.height = [UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].scale;
        }
        else
        {
            targetSize.width = size.width * [UIScreen mainScreen].scale;
            targetSize.height = size.height * [UIScreen mainScreen].scale;
        }
        [[PHImageManager defaultManager] requestImageForAsset:self targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completeHandeler(result);
            });
        }];
    });
}

@end
