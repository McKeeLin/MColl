//
//  HRListView.m
//  Recruitment
//
//  Created by McKee on 16/5/29.
//  Copyright © 2016年 OA.NETEASE. All rights reserved.
//

#import "HRListView.h"
#import "UILabel+Ex.h"
#import "UIColor+Ex.h"
#import "UIFont+Ex.h"


HRListView *g_listView;


@interface ListItemCell : UITableViewCell
{
    UIView *_bottomLine;
}
@property UIView *bottomLine;
@end

@implementation ListItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if( self )
    {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.font = [UIFont systemFontOfSize:14];
        self.textLabel.textColor = [UIColor fromRGB:0x333338];
    
        _bottomLine = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomLine.backgroundColor = [UIColor fromRGB:0xeeeeee];
        [self addSubview:_bottomLine];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat lineWidth = width * 0.8;
    _bottomLine.frame = CGRectMake((width - lineWidth)/2, height - 1, lineWidth, 1);
}

@end



@interface HRListView ()<UITableViewDelegate,UITableViewDataSource>
{
    UIView *_tapArea;
    UIView *_listContentView;
    UILabel *_titleLab;
    UILabel *_tipsLab;
    UIView *_separator;
    UITableView *_tableView;
    UIButton *_cancelButton;
}

@property UILabel *titleLab;

@property UILabel *tipsLab;

@end

@implementation HRListView

+ (void)showItems:(NSArray *)items withTitle:(NSString*)title delegate:(id<HRListViewDelegate>)delegate
{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    g_listView = [[HRListView alloc] initWithFrame:window.bounds];
    g_listView.delegate = delegate;
    g_listView.items = items;
    g_listView.titleLab.text = title;
    [window addSubview:g_listView];
}

+ (void)showItems:(NSArray *)items withTitle:(NSString*)title withBlock:(HRLISTVIEW_BLOCK)block
{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    g_listView = [[HRListView alloc] initWithFrame:window.bounds];
    g_listView.block = block;
    g_listView.items = items;
    g_listView.titleLab.text = title;
    [window addSubview:g_listView];
    [g_listView show];
}

+ (void)showItems:(NSArray *)items withTitle:(NSString *)title tips:(NSAttributedString *)tips block:(HRLISTVIEW_BLOCK)block
{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    g_listView = [[HRListView alloc] initWithFrame:window.bounds];
    g_listView.block = block;
    g_listView.items = items;
    g_listView.titleLab.text = title;
    g_listView.tipsLab.attributedText = tips;
    [window addSubview:g_listView];
    [g_listView show];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if( self )
    {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        
        _tapArea = [[UIView alloc] initWithFrame:CGRectZero];
        _tapArea.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGestureRecognizer:)];
        [_tapArea addGestureRecognizer:tgr];
        [self addSubview:_tapArea];
        
        _listContentView = [[UIView alloc] initWithFrame:CGRectZero];
        _listContentView.backgroundColor = [UIColor whiteColor];
        _listContentView.layer.cornerRadius = 5;
        _listContentView.layer.masksToBounds = YES;
        [self addSubview:_listContentView];
        
        _titleLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLab.font = [UIFont systemFontOfSize:12];
        _titleLab.textColor = [UIColor fromRGB:0x999999];
        _titleLab.backgroundColor = [UIColor clearColor];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _titleLab.numberOfLines = 0;
        [_listContentView addSubview:_titleLab];
        
        _separator = [[UIView alloc] initWithFrame:CGRectZero];
        _separator.backgroundColor = [UIColor fromRGB:0xeeeeee];
        [_listContentView addSubview:_separator];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_listContentView addSubview:_tableView];
        
        _tipsLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipsLab.font = [UIFont exFontWithName:@"PingFang SC" size:12];
        _tipsLab.textColor = [UIColor fromRGB:0x999999];
        _tipsLab.numberOfLines = 0;
        [_listContentView addSubview:_tipsLab];
        
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _cancelButton.backgroundColor = [UIColor fromRGB:0xffb42a28];
        _cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        _cancelButton.layer.cornerRadius = 5;
        _cancelButton.layer.masksToBounds = YES;
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(onTouchCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.bounds.size.width;
    CGFloat contentWidth = width - 30;
    CGFloat height = self.bounds.size.height;
    CGFloat maxHeight = height * 0.6;
    CGFloat titleHeight = 44;
    CGFloat tipsHeight = 0;
    if( _tipsLab.attributedText.string.length )
    {
        tipsHeight = [_tipsLab heightForWidth:contentWidth*0.8];
    }
    CGFloat buttonHeight = 44;
    CGFloat interval = 5;
    CGFloat interval2 = 5;
    CGFloat tableMaxHeight = maxHeight - titleHeight - tipsHeight - buttonHeight - interval - 2 * interval2;
    CGFloat tableHeight = 44 * _items.count;
    tableHeight = tableHeight < tableMaxHeight ? tableHeight : tableMaxHeight;
    
    CGFloat listContentHeight = titleHeight + tableHeight + tipsHeight + 2 * interval2;
    CGFloat top = height - interval2 - buttonHeight - interval - listContentHeight;
    CGFloat left = (width - contentWidth)/2;
    _tapArea.frame = self.bounds;
    _listContentView.frame = CGRectMake(left, top, contentWidth, listContentHeight);
    _separator.frame = CGRectMake(contentWidth*0.1, titleHeight - 1, contentWidth*0.8, 1);
    _titleLab.frame = CGRectMake(_separator.frame.origin.x, 0, _separator.frame.size.width, titleHeight);
    _tableView.frame = CGRectMake(0, titleHeight, contentWidth, tableHeight);
    _tipsLab.frame = CGRectMake(_separator.frame.origin.x, titleHeight+tableHeight+interval2, _separator.frame.size.width, tipsHeight);
    top += listContentHeight + interval;
    _cancelButton.frame = CGRectMake(left, top, contentWidth, buttonHeight);
}

#pragma mark- UITableViewDelegate UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *Id = @"HRListViewCell";
    ListItemCell *cell = (ListItemCell*)[tableView dequeueReusableCellWithIdentifier:Id];
    if( !cell )
    {
        cell = [[ListItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Id];
    }
    NSString *title = [_items objectAtIndex:indexPath.row];
    cell.textLabel.text = title;
    cell.bottomLine.hidden = indexPath.row == _items.count - 1;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( [_delegate respondsToSelector:@selector(listView:didSelectedAtRow:)] )
    {
        [_delegate listView:self didSelectedAtRow:indexPath.row];
    }
    
    if( _block )
    {
        _block( indexPath.row );
    }
    [self dismiss];
}

#pragma mark- Actions

- (void)show
{
    CGFloat width = self.bounds.size.width;
    CGFloat contentWidth = width - 30;
    CGFloat height = self.bounds.size.height;
    CGFloat maxHeight = height * 0.6;
    CGFloat titleHeight = 44;
    CGFloat tipsHeight = 0;

    if( _tipsLab.attributedText.string.length > 0 )
    {
        tipsHeight = [_tipsLab heightForWidth:contentWidth*0.8];
    }
    CGFloat buttonHeight = 44;
    CGFloat interval = 5;
    CGFloat interval2 = 5;
    CGFloat tableMaxHeight = maxHeight - titleHeight - tipsHeight - buttonHeight - interval - 2 * interval2;
    CGFloat tableHeight = 44 * _items.count;
    tableHeight = tableHeight < tableMaxHeight ? tableHeight : tableMaxHeight;
    
    CGFloat listContentHeight = titleHeight + tableHeight + tipsHeight + 2 * interval2;
    CGFloat top = height + 1;
    CGFloat finalTop = height - interval2 - buttonHeight - interval - listContentHeight;
    CGFloat left = (width - contentWidth)/2;
    _listContentView.frame = CGRectMake(left, top, contentWidth, listContentHeight);
    
    top += listContentHeight + interval;
    _cancelButton.frame = CGRectMake(left, top, contentWidth, buttonHeight);
    
    [UIView animateWithDuration:0.3 animations:^(void){
        _listContentView.frame = CGRectMake(left, finalTop, contentWidth, listContentHeight);
        CGFloat buttonTop = finalTop + listContentHeight + interval;
        _cancelButton.frame = CGRectMake(left, buttonTop, contentWidth, buttonHeight);
    }];
}

- (void)dismiss
{
    CGFloat height = self.bounds.size.height;
    [UIView animateWithDuration:0.3 animations:^(void){
        CGRect listContentFrame = _listContentView.frame;
        listContentFrame.origin.y = height + 1;
        _listContentView.frame = listContentFrame;
        
        CGRect buttonFrame = _cancelButton.frame;
        buttonFrame.origin.y = _listContentView.frame.size.height + _listContentView.frame.origin.y + 5;
        _cancelButton.frame = buttonFrame;
    } completion:^(BOOL finished){
        [self removeFromSuperview];
        g_listView = nil;
    }];
}

- (void)onTouchCancelButton:(id)sender
{
    [self dismiss];
    
    if( [_delegate respondsToSelector:@selector(listView:didSelectedAtRow:)] )
    {
        [_delegate listView:self didSelectedAtRow:-1];
    }
    
    if( _block )
    {
        _block( -1 );
    }
}


- (void)onTapGestureRecognizer:(UITapGestureRecognizer*)tgr
{
    [self onTouchCancelButton:nil];
}

@end
