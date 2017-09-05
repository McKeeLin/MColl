//
//  PreviewVC.h
//  MColl
//
//  Created by McKee on 2016/12/30.
//  Copyright © 2016年 mckeelin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "groupObject.h"

@class captureView;

@interface PreviewVC : UIViewController

@property (weak)NSData *imageData;

@property (weak) groupObject *group;

@property (weak) captureView *capView;

@end
