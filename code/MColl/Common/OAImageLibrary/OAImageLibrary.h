//
//  OAImageLibrary.h
//  OAImageLibraryDemo
//
//  Created by mtry on 2017/8/15.
//  Copyright © 2017年 NetEase. All rights reserved.
//

/*
 相册控件
 1、支持多选功能
 2、支持选择预览功能
 3、支持图片裁剪功能
 4、已经适配好：iOS8-iOS10、iPad、横竖屏切换
 */

#import <UIKit/UIKit.h>
#import "PHAsset+OAImageLibraryGetImage.h"

@class PHAsset;

typedef NS_ENUM(NSInteger, OAImageLibraryCompleteType)
{
    OAImageLibraryCompleteTypeSuccess,
    OAImageLibraryCompleteTypeFailure,
    OAImageLibraryCompleteTypeCancel,
};

typedef NS_ENUM(NSInteger, OAImageLibraryMode)
{
    OAImageLibraryModeNone,
    OAImageLibraryModePicker,
    OAImageLibraryModeCroper,
};

typedef void(^OAImageLibraryPickerCompleteHandler)(OAImageLibraryCompleteType type, NSArray <PHAsset *> *imageData, NSString *message);
typedef void(^OAImageLibraryCroperCompleteHandler)(OAImageLibraryCompleteType type, UIImage *image, NSString *message);

@interface OAImageLibrary : NSObject

+ (instancetype)sharedInstance;

/// PHAsset转UIImage使用 PHAsset+OAImageLibraryGetImage.h 中的 - (void)imageWithSize:completeHandeler: 方法
- (void)showPickerInController:(UIViewController *)inController
                     maxNumber:(NSInteger)maxNumber
               completeHandler:(void(^)(OAImageLibraryCompleteType type, NSArray <PHAsset *> *imageData, NSString *message))completeHandler;
- (void)showCroperInController:(UIViewController *)inController
               completeHandler:(void(^)(OAImageLibraryCompleteType type, UIImage *image, NSString *message))completeHandler;
- (void)didFinished;

@property (nonatomic, readonly) OAImageLibraryMode mode;
@property (nonatomic, readonly) NSInteger maxNumber;
@property (nonatomic, strong, readonly) OAImageLibraryPickerCompleteHandler pickerCompleteHandler;
@property (nonatomic, strong, readonly) OAImageLibraryCroperCompleteHandler croperCompleteHandler;
@property (nonatomic, strong) void(^willShowLibraryControllerHandler)(UIViewController *showController);

@end
