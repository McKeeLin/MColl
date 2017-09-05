//
//  CollHeader.h
//  MColl
//
//  Created by McKee on 2016/12/27.
//  Copyright © 2016年 mckeelin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "groupObject.h"

@class collectionVC;

@interface CollHeader : UICollectionReusableView
{
    UIImageView *_iv;
}

@property UILabel *groupNameLab;

@property id target;

@property SEL action;

@property UIButton *disclosureButton;

@property (weak) groupObject *group;

@property (weak) collectionVC *collVC;

@end
