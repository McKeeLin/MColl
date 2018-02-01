//
//  captureView.h
//  MColl
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "groupObject.h"

@class collectionVC;
@class captureVC;

@interface captureView : UIView

@property (readonly) NSData *imageData;

@property groupObject *group;

@property (weak) captureVC *capVC;

- (instancetype)initWithFrame:(CGRect)frame frontCamera:(BOOL)frontCamera;

- (void)start;

- (void)stop;

- (void)caputre;

@end
