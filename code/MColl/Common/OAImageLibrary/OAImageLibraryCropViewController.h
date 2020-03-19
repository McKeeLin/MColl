//
//  OAImageLibraryCropViewController.h
//  OAImageLibraryDemo
//
//  Created by mtry on 2017/8/15.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;

@interface OAImageLibraryCropViewController : UIViewController

- (instancetype)initWithAsset:(PHAsset *)asset;

@end
