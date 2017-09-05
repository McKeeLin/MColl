//
//  HRListView.h
//  Recruitment
//
//  Created by McKee on 16/5/29.
//  Copyright © 2016年 OA.NETEASE. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HRListView;

/**
 *  列表选择视图委托
 */
@protocol HRListViewDelegate <NSObject>

@optional

/**
 *  由列表选择视图选择某一项后调用的方法
 *
 *  @param listView HRListView实例
 *  @param row      已选择项在列表中的行号, -1：取消
 */
- (void)listView:(HRListView*)listView didSelectedAtRow:(NSInteger)row;

@end


/**
 *  列表选择视图回调
 *
 *  @param selectedRow 已选择项在列表中的行号, -1：取消
 */
typedef void(^HRLISTVIEW_BLOCK) (NSInteger selectedRow);


/**
 *  列表选择视图
 */
@interface HRListView : UIView

/**
 *  列表项数组
 */
@property NSArray *items;

/**
 *  列表选择视图委托
 */
@property (weak) id<HRListViewDelegate> delegate;

/**
 *  列表选择视图回调
 */
@property (strong) HRLISTVIEW_BLOCK block;

/**
 *  以委托的方式显示列表选择视图
 *
 *  @param items    列表项数组
 *  @param delegate 委托
 */
+ (void)showItems:(NSArray*)items withTitle:(NSString*)title delegate:(id<HRListViewDelegate>)delegate;

/**
 *  以回调方式显示列表选择视图
 *
 *  @param items 列表项数组
 *  @param title 功能标题
 *  @param block 回调
 */
+ (void)showItems:(NSArray*)items
        withTitle:(NSString *)title
        withBlock:(HRLISTVIEW_BLOCK)block;

+ (void)showItems:(NSArray*)items
        withTitle:(NSString *)title
             tips:(NSAttributedString*)tips
            block:(HRLISTVIEW_BLOCK)block;


@end
