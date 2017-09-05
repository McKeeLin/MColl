//
//  PreviewVC.m
//  MColl
//
//  Created by McKee on 2016/12/30.
//  Copyright © 2016年 mckeelin. All rights reserved.
//

#import "PreviewVC.h"
#import "dataHelper.h"
#import "captureView.h"
#import "HRListView.h"

@interface PreviewVC ()<HRListViewDelegate>
{
    UIImageView *_imageView;
    UIButton *_saveButton;
    UIButton *_cancelButton;
}

@end

@implementation PreviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    if( _imageData )
    {
        _imageView.image = [UIImage imageWithData:_imageData];
    }
    [self.view addSubview:_imageView];
    
    _saveButton = [[UIButton alloc] initWithFrame:CGRectZero];
    _saveButton.layer.cornerRadius = 12;
    _saveButton.layer.masksToBounds = YES;
    _saveButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _saveButton.layer.borderWidth = 1;
    [_saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [_saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_saveButton addTarget:self action:@selector(onTouchSave:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_saveButton];
    
    _cancelButton = [[UIButton alloc] initWithFrame:CGRectZero];
    _cancelButton.layer.cornerRadius = 12;
    _cancelButton.layer.masksToBounds = YES;
    _cancelButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _cancelButton.layer.borderWidth = 1;
    [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(onTouchCancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancelButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    _imageView.frame = self.view.bounds;
    
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    CGFloat buttonWidth = 100;
    CGFloat buttonHeight = 30;
    CGFloat margin = 20;
    _cancelButton.frame = CGRectMake(margin, height - buttonHeight - margin, buttonWidth, buttonHeight);
    _saveButton.frame = CGRectMake(width - margin - buttonWidth, height - buttonHeight - margin, buttonWidth, buttonHeight);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)onTouchSave:(id)sender
{
    if( _group )
    {
        [[dataHelper helper] saveCaputreData:_imageData toGroup:_group];
        [self dismissViewControllerAnimated:YES completion:^{
            [_capView start];
        }];
    }
    else
    {
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:0];
        for( groupObject *group in [dataHelper helper].groups )
        {
            if( group == _group )
            {
                continue;
            }
            [items addObject:group.title];
        }
        [HRListView showItems:items withTitle:@"想要移动到哪个分组？" delegate:self];
    }
    
}

- (void)onTouchCancel:(id)sneder
{
    [self dismissViewControllerAnimated:YES completion:^{
        [_capView start];
    }];
}


- (void)listView:(HRListView*)listView didSelectedAtRow:(NSInteger)row
{
    if( row >= 0 )
    {
        NSString *title = listView.items[row];
        groupObject *destGroup;
        for( groupObject *group in [dataHelper helper].groups )
        {
            if( [group.title isEqualToString:title] )
            {
                destGroup = group;
                break;
            }
        }
        
        if( destGroup )
        {
            [[dataHelper helper] saveCaputreData:_imageData toGroup:destGroup];
            [self dismissViewControllerAnimated:YES completion:^{
                [_capView start];
            }];
        }
    }
    
}

@end
