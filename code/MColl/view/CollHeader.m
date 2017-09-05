//
//  CollHeader.m
//  MColl
//
//  Created by McKee on 2016/12/27.
//  Copyright © 2016年 mckeelin. All rights reserved.
//

#import "CollHeader.h"
#import "collectionVC.h"
#import "dataHelper.h"

@implementation CollHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if( self )
    {
        _groupNameLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _groupNameLab.backgroundColor = [UIColor clearColor];
        _groupNameLab.font = [UIFont fontWithName:@"PingFang SC" size:12];
        _groupNameLab.numberOfLines = 1;
        _groupNameLab.textColor = [UIColor grayColor];
        [self addSubview:_groupNameLab];
        
        UILongPressGestureRecognizer *lpg = [[UILongPressGestureRecognizer alloc] init];
        lpg.minimumPressDuration = 2.0;
        [lpg addTarget:self action:@selector(onLongPressLabel:)];
        [_groupNameLab addGestureRecognizer:lpg];
        
        _iv = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iv.image = [UIImage imageNamed:@"RDisclosure"];
        [self addSubview:_iv];
        
        _disclosureButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self addSubview:_disclosureButton];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat leftMargin = 15;
    CGFloat topMargin = 10;
    
    _groupNameLab.frame =
    CGRectMake(leftMargin, topMargin, width-2*leftMargin, height-topMargin);
    
    CGFloat w = _iv.image.size.width;
    CGFloat h = _iv.image.size.height;
    CGFloat x = width - w - 8;
    CGFloat y = (height-h)/2;
    _iv.frame = CGRectMake(x, y, w, h);
    
    _disclosureButton.frame = self.bounds;
}

- (void)onLongPressLabel:(UILabel*)label
{
    UIAlertController *vc = [[UIAlertController alloc] init];
    vc.title = @"";
    vc.message = @"请选择要执行的操作";
    
    UIAlertAction *renameAction = [UIAlertAction actionWithTitle:@"重命名" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *renameVC = [[UIAlertController alloc] init];
        renameVC.title = [NSString stringWithFormat:@"重命名分组：%@", label.text];
        renameVC.message = @"请输入新的分组名";
        [renameVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        }];
        
        UIAlertAction *renameCancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [renameVC dismissViewControllerAnimated:YES completion:nil];
        }];
        [renameVC addAction:renameCancelAction];
        
        UIAlertAction *renameOKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField *tf = renameVC.textFields.firstObject;
            if( tf.text.length > 0 )
            {
                [_group rename:tf.text];
                [_collVC reload];
            }
        }];
        [renameVC addAction:renameOKAction];
        
        [_collVC presentViewController:renameVC animated:YES completion:nil];
    }];
    [vc addAction:renameAction];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@""
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * _Nonnull action) {
        ;
    }];
    [vc addAction:deleteAction];
}

@end
