//
//  OAImageLibraryCropViewController.m
//  OAImageLibraryDemo
//
//  Created by mtry on 2017/8/15.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "OAImageLibraryCropViewController.h"
#import "OAImageLibraryZoomView.h"
#import "OAImageLibrary.h"
#import "PHAsset+OAImageLibraryGetImage.h"

#define OAImageLibraryCropLandscapeLeftOrRight ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight)
#define OAImageLibraryCropIPhoneLandscapeLeftOrRight (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && OAImageLibraryCropLandscapeLeftOrRight)
#define OAImageLibraryCropBottomBarHeight (OAImageLibraryCropIPhoneLandscapeLeftOrRight ? 30 : 44)

#pragma mark - OAImageLibraryCropMaskView

const CGFloat OAImageLibraryCropMaskViewLineWidth = 2;

@interface OAImageLibraryCropMaskView : UIView

@property (nonatomic, assign) CGRect cropFrame;

@end

@implementation OAImageLibraryCropMaskView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0 alpha:0.5].CGColor);
    CGContextFillRect(context, rect);
    
    CGFloat lineWidth = OAImageLibraryCropMaskViewLineWidth;
    CGRect frame = CGRectInset(self.cropFrame, lineWidth / 2, lineWidth / 2);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextStrokeRectWithWidth(context, frame, lineWidth);
    CGContextAddRect(context, frame);
    CGContextSetBlendMode(context, kCGBlendModeClear);
    CGContextFillPath(context);
}

@end

#pragma mark - OAImageLibraryCropViewController

@interface OAImageLibraryCropViewController ()

@property (nonatomic, strong) OAImageLibraryCropMaskView *maskView;
@property (nonatomic, strong) OAImageLibraryZoomView *zoomView;
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *finishButton;

@property (nonatomic, readonly) PHAsset *asset;
@property (nonatomic) CGRect cropFrame;

@end

@implementation OAImageLibraryCropViewController

- (OAImageLibraryCropMaskView *)maskView
{
    if (!_maskView)
    {
        _maskView = [[OAImageLibraryCropMaskView alloc] initWithFrame:self.view.bounds];
        _maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _maskView;
}

- (OAImageLibraryZoomView *)zoomView
{
    if (!_zoomView)
    {
        _zoomView = [[OAImageLibraryZoomView alloc] init];
        _zoomView.clipsToBounds = NO;
        _zoomView.scrollView.clipsToBounds = NO;
        _zoomView.scrollView.minimumZoomScale = 0.5;
        _zoomView.zoomContentMode = OAImageLibraryZoomContentModeScaleAspectFill;
    }
    return _zoomView;
}

- (UIView *)bottomBar
{
    if (!_bottomBar)
    {
        _bottomBar = [[UIView alloc] init];
        _bottomBar.backgroundColor = [UIColor colorWithRed:0.156 green:0.156 blue:0.156 alpha:0.8];
    }
    return _bottomBar;
}

- (UIButton *)cancelButton
{
    if (!_cancelButton)
    {
        _cancelButton = [[UIButton alloc] init];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(touchUpInsideCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)finishButton
{
    if (!_finishButton)
    {
        _finishButton = [[UIButton alloc] init];
        _finishButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_finishButton setTitle:@"完成" forState:UIControlStateNormal];
        [_finishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_finishButton addTarget:self action:@selector(touchUpInsideFinishButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishButton;
}

- (instancetype)initWithAsset:(PHAsset *)asset
{
    self = [super init];
    if (self)
    {
        _asset = asset;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.view.clipsToBounds = YES;
    
    [self.view addSubview:self.zoomView];
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.bottomBar];
    [self.bottomBar addSubview:self.cancelButton];
    [self.bottomBar addSubview:self.finishButton];
    
    [self.asset imageWithSize:PHImageManagerMaximumSize completeHandeler:^(UIImage *image) {
        [self.zoomView reloadWithImage:image];
    }];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect rect = self.view.bounds;
    rect.size.height = OAImageLibraryCropBottomBarHeight;
    rect.origin.y = CGRectGetHeight(self.view.frame) - rect.size.height;
    self.bottomBar.frame = rect;
    
    rect = self.bottomBar.bounds;
    rect.size.width = 50;
    self.cancelButton.frame = rect;
    
    rect.origin.x = CGRectGetWidth(self.bottomBar.frame) - rect.size.width;
    self.finishButton.frame = rect;
    
    CGFloat width = fmin(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    if (OAImageLibraryCropLandscapeLeftOrRight)
    {
        width -= OAImageLibraryCropBottomBarHeight;
    }
    CGRect cropFrame = CGRectZero;
    cropFrame.size.width = width;
    cropFrame.size.height = width;
    cropFrame.origin.x = (CGRectGetWidth(self.view.frame) - cropFrame.size.width) / 2;
    cropFrame.origin.y = (CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.bottomBar.frame) - cropFrame.size.height) / 2;
    self.cropFrame = cropFrame;
    self.maskView.cropFrame = cropFrame;
    self.zoomView.frame = CGRectInset(self.cropFrame, OAImageLibraryCropMaskViewLineWidth / 2, OAImageLibraryCropMaskViewLineWidth / 2);
    [self.maskView setNeedsDisplay];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.presentedViewController)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (!self.presentedViewController)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
}

- (void)touchUpInsideCancelButton:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchUpInsideFinishButton:(UIButton *)button
{
    UIImage *image = self.zoomView.imageView.image;
    CGSize imageSize = self.zoomView.imageView.frame.size;
    CGRect cropFrame = self.zoomView.bounds;
    cropFrame.origin.x = self.zoomView.scrollView.contentOffset.x;
    cropFrame.origin.y = self.zoomView.scrollView.contentOffset.y;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGRect rect = CGRectMake(0, 0, imageSize.width, imageSize.height);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, scale);
    [image drawInRect:rect];
    UIImage *showImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (showImage)
    {
        CGRect rect = CGRectZero;
        rect.origin.x = cropFrame.origin.x * scale;
        rect.origin.y = cropFrame.origin.y * scale;
        rect.size.width = cropFrame.size.width * scale;
        rect.size.height = cropFrame.size.height * scale;
        CGImageRef imageRef = CGImageCreateWithImageInRect([showImage CGImage], rect);
        UIImage *result = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
        if ([OAImageLibrary sharedInstance].croperCompleteHandler)
        {
            [OAImageLibrary sharedInstance].croperCompleteHandler(OAImageLibraryCompleteTypeSuccess, result, nil);
        }
        [[OAImageLibrary sharedInstance] didFinished];
        CGImageRelease(imageRef);
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (UIImage *)cropImage:(UIImage *)image frame:(CGRect)frame
{
    return nil;
}

@end
