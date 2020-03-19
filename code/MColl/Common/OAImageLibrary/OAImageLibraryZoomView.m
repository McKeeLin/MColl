//
//  OAImageLibraryZoomView.m
//  OAImageLibraryDemo
//
//  Created by mtry on 2017/8/15.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "OAImageLibraryZoomView.h"

@implementation OAImageLibraryZoomScrollView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.nextResponder touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.nextResponder touchesEnded:touches withEvent:event];
}

@end

@interface OAImageLibraryZoomView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *singleRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *doubleRecognizer;

@end

@implementation OAImageLibraryZoomView

@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;

- (OAImageLibraryZoomScrollView *)scrollView
{
    if (!_scrollView)
    {
        _scrollView = [[OAImageLibraryZoomScrollView alloc] initWithFrame:self.bounds];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.maximumZoomScale = 3.0;
        _scrollView.minimumZoomScale = 1.0;
    }
    return _scrollView;
}

- (UIImageView *)imageView
{
    if (!_imageView)
    {
        _imageView = [[UIImageView alloc] init];
        _imageView.userInteractionEnabled = YES;
    }
    return _imageView;
}

- (UITapGestureRecognizer *)singleRecognizer
{
    if (!_singleRecognizer)
    {
        _singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTouchGestureRecognizer:)];
        _singleRecognizer.numberOfTapsRequired = 1;
    }
    return _singleRecognizer;
}

- (UITapGestureRecognizer *)doubleRecognizer
{
    if (!_doubleRecognizer)
    {
        _doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTouchGestureRecognizer:)];
        _doubleRecognizer.numberOfTapsRequired = 2;
    }
    return _doubleRecognizer;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.zoomContentMode = OAImageLibraryZoomContentModeScaleAspectFit;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addSubview:self.scrollView];
        [self.scrollView addSubview:self.imageView];
        [self.scrollView addGestureRecognizer:self.singleRecognizer];
        [self.imageView addGestureRecognizer:self.doubleRecognizer];
        [self.singleRecognizer requireGestureRecognizerToFail:self.doubleRecognizer];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.scrollView setZoomScale:1 animated:NO];
    
    if (self.imageView.image)
    {
        CGSize imageSize = self.imageView.image.size;
        CGSize scrollViewSize = self.scrollView.frame.size;
        CGFloat imageScaleWH = imageSize.width / imageSize.height;
        CGFloat scrollViewScaleWH = scrollViewSize.width / scrollViewSize.height;
        
        CGRect frame = CGRectZero;
        
        if (self.zoomContentMode == OAImageLibraryZoomContentModeScaleAspectFit)
        {
            if (imageScaleWH < scrollViewScaleWH)
            {
                frame.size.height = scrollViewSize.height;
                frame.size.width = frame.size.height * imageScaleWH;
            }
            else
            {
                frame.size.width = scrollViewSize.width;
                frame.size.height = frame.size.width / imageScaleWH;
            }
        }
        else if (self.zoomContentMode == OAImageLibraryZoomContentModeScaleAspectFill)
        {
            if (imageScaleWH < scrollViewScaleWH)
            {
                frame.size.width = scrollViewSize.width;
                frame.size.height = frame.size.width / imageScaleWH;
            }
            else
            {
                frame.size.height = scrollViewSize.height;
                frame.size.width = frame.size.height * imageScaleWH;
            }
        }
        
        self.imageView.frame = frame;
        self.scrollView.contentSize = self.imageView.frame.size;
        
        [self updateContentInset];
        
        if (self.zoomContentMode == OAImageLibraryZoomContentModeScaleAspectFill)
        {
            CGPoint contentOffset = CGPointZero;
            if (self.scrollView.contentSize.width > self.scrollView.frame.size.width)
            {
                contentOffset.x = (self.scrollView.contentSize.width - self.scrollView.frame.size.width) / 2;
            }
            if (self.scrollView.contentSize.height > self.scrollView.frame.size.height)
            {
                contentOffset.y = (self.scrollView.contentSize.height - self.scrollView.frame.size.height) / 2;
            }
            [self.scrollView setContentOffset:contentOffset animated:NO];
        }
    }
}

- (void)updateContentInset
{
    CGSize imageSize = self.imageView.frame.size;
    CGSize scrollViewSize = self.scrollView.frame.size;
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (scrollViewSize.width > imageSize.width)
    {
        insets.left = (scrollViewSize.width - imageSize.width) / 2;
    }
    if (scrollViewSize.height > imageSize.height)
    {
        insets.top = (scrollViewSize.height - imageSize.height) / 2;
    }
    self.scrollView.contentInset = insets;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self updateContentInset];
}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)singleTouchGestureRecognizer:(UITapGestureRecognizer *)recognizer
{
    [self.delegate imageLibraryZoomViewDidSingleTap:self];
}

- (void)doubleTouchGestureRecognizer:(UITapGestureRecognizer *)recognizer
{
    if (self.scrollView.zoomScale != 1)
    {
        [self.scrollView setZoomScale:1 animated:YES];
    }
    else
    {
        CGPoint point = [recognizer locationInView:self.imageView];
        [self.scrollView zoomToRect:CGRectMake(point.x, point.y, 0, 0) animated:YES];
    }
}

- (void)reloadWithImage:(UIImage *)image
{
    self.imageView.image = image;
    [self setNeedsLayout];
}

@end
