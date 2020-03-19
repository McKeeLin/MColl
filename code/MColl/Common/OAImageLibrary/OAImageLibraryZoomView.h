//
//  OAImageLibraryZoomView.h
//  OAImageLibraryDemo
//
//  Created by mtry on 2017/8/15.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OAImageLibraryZoomScrollView : UIScrollView

@end

typedef NS_ENUM(NSInteger, OAImageLibraryZoomContentMode)
{
    OAImageLibraryZoomContentModeScaleAspectFit,  //defualt
    OAImageLibraryZoomContentModeScaleAspectFill,
};

@class OAImageLibraryZoomView;

@protocol OAImageLibraryZoomViewDelegate <NSObject>

- (void)imageLibraryZoomViewDidSingleTap:(OAImageLibraryZoomView *)zoomView;

@end

@interface OAImageLibraryZoomView : UIView

@property (nonatomic, weak) id<OAImageLibraryZoomViewDelegate>delegate;
@property (nonatomic, assign) OAImageLibraryZoomContentMode zoomContentMode;
@property (nonatomic, readonly) OAImageLibraryZoomScrollView *scrollView;
@property (nonatomic, readonly) UIImageView *imageView;

- (void)reloadWithImage:(UIImage *)image;

@end


