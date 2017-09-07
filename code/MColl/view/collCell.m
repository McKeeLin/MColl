//
//  collCell.m
//  MColl
//
//  Created by 林景隆 on 15-2-5.
//  Copyright (c) 2015年 mckeelin. All rights reserved.
//

#import "collCell.h"

@implementation collCell

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if( newSuperview )
    {
        if( !_imageView )
        {
            _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            _imageView.layer.contentsGravity = kCAGravityResizeAspectFill;
            [self.contentView addSubview:_imageView];
        }
        if( !_selectionIndicator )
        {
            _selectionIndicator = [[UIImageView alloc] initWithFrame:CGRectZero];
            _selectionIndicator.image = [UIImage imageNamed:@"selected"];
            _selectionIndicator.hidden = YES;
            [self.contentView addSubview:_selectionIndicator];
        }
        self.contentView.layer.masksToBounds = YES;
        _selectionState = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onThumbnilCompleteNotification:) name:ThumbnilCompletedNotification object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _imageView.frame = self.contentView.bounds;
    _imageView.image = _item.thumbnail;
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat w = _selectionIndicator.image.size.width;
    CGFloat h = _selectionIndicator.image.size.height;
    CGFloat x = width - 5 - w;
    CGFloat y = height - 5 - h;
    _selectionIndicator.frame = CGRectMake(x, y, w, h);
}

- (void)setSelectionState:(NSInteger)selectionState
{
    _selectionState = selectionState;
    if( !_selectionIndicator )
    {
        _selectionIndicator = [[UIImageView alloc] initWithFrame:CGRectZero];
        _selectionIndicator.image = [UIImage imageNamed:@"selected"];
        _selectionIndicator.hidden = YES;
        [self.contentView addSubview:_selectionIndicator];
    }
    BOOL hidden = _selectionState == 0;
    _selectionIndicator.hidden = hidden;
    [_selectionIndicator.superview bringSubviewToFront:_selectionIndicator];
}




- (void)onThumbnilCompleteNotification:(NSNotification*)notifcation
{
    if( notifcation.object == self.item )
    {
        _imageView.image = self.item.thumbnail;
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
}

@end






@implementation collAddCell

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if( newSuperview )
    {
        if( !_btn )
        {
            _btn = [[UIButton alloc] initWithFrame:CGRectZero];
            _btn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
            [_btn setTitle:@"+" forState:UIControlStateNormal];
            [_btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [self addSubview:_btn];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat btnWH = 20;
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    _btn.frame = CGRectMake((width-btnWH)/2, (height-btnWH)/2, btnWH, btnWH);
}

@end
