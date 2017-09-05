//
//  collCell.h
//  MColl
//
//  Created by 林景隆 on 15-2-5.
//  Copyright (c) 2015年 mckeelin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemObject.h"

@interface collCell : UICollectionViewCell

@property UIImageView *imageView;

@property UIImageView *selectionIndicator;

@property (nonatomic) NSInteger selectionState;

@property (weak) ItemObject *item;

@end



@interface collAddCell : UICollectionViewCell

@property UIButton *btn;

@end
