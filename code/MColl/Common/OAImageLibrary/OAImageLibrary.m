//
//  OAImageLibrary.m
//  OAImageLibraryDemo
//
//  Created by mtry on 2017/8/15.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "OAImageLibrary.h"
#import "OAImageLibraryListViewController.h"
#import <Photos/Photos.h>

@implementation OAImageLibrary

+ (instancetype)sharedInstance
{
    static id shareObject;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[self class] new];
    });
    return shareObject;
}

- (void)showPickerInController:(UIViewController *)inController
                     maxNumber:(NSInteger)maxNumber
               completeHandler:(void(^)(OAImageLibraryCompleteType type, NSArray <PHAsset *> *imageData, NSString *message))completeHandler
{
    _mode = OAImageLibraryModePicker;
    _maxNumber = maxNumber;
    _pickerCompleteHandler = completeHandler;
    [self showInController:inController];
}

- (void)showCroperInController:(UIViewController *)inController
               completeHandler:(void(^)(OAImageLibraryCompleteType type, UIImage *image, NSString *message))completeHandler
{
    _mode = OAImageLibraryModeCroper;
    _croperCompleteHandler = completeHandler;
    [self showInController:inController];
}

- (void)showInController:(UIViewController *)inController
{
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined)
    {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showInController:inController];
                });
            }
            else
            {
                [self didFinished];
            }
        }];
    }
    else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusRestricted ||
             [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied)
    {
        NSString *message = @"请在设置->隐私->照片中允许访问";
        if (self.mode == OAImageLibraryModePicker)
        {
            if (self.pickerCompleteHandler)
            {
                self.pickerCompleteHandler(OAImageLibraryCompleteTypeFailure, nil, message);
            }
        }
        else if (self.mode == OAImageLibraryModeCroper)
        {
            if (self.croperCompleteHandler)
            {
                self.croperCompleteHandler(OAImageLibraryCompleteTypeFailure, nil, message);
            }
        }
        [self didFinished];
    }
    else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized)
    {
        OAImageLibraryListViewController *controller = [[OAImageLibraryListViewController alloc] init];
        controller.title = @"照片";
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
        dispatch_async(dispatch_get_main_queue(), ^{
            [inController presentViewController:navigation animated:YES completion:nil];
        });
        if (self.willShowLibraryControllerHandler)
        {
            self.willShowLibraryControllerHandler(controller);
        }
    }
}

- (void)didFinished
{
    _mode = OAImageLibraryModeNone;
    _maxNumber = 0;
    _pickerCompleteHandler = nil;
    _croperCompleteHandler = nil;
    _willShowLibraryControllerHandler = nil;
}

@end
