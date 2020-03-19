//
//  DirsVC.m
//  MColl
//
//  Created by McKee on 2018/1/15.
//  Copyright © 2018年 mckeelin. All rights reserved.
//

#import "GroupsVC.h"
#import "GroupItemCell.h"
#import "GroupVC.h"
#import "dataHelper.h"
#import "LogVC.h"
#import "LogHelper.h"

@interface GroupsVC ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    IBOutlet UICollectionView *_collectonView;
}

@end

@implementation GroupsVC

+ (instancetype)fromXib
{
    GroupsVC *vc = [[GroupsVC alloc] initWithNibName:@"GroupsVC" bundle:nil];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MColl";
    
    _collectonView.delegate = self;
    _collectonView.dataSource = self;
    
    UINib *cell = [UINib nibWithNibName:@"GroupItemCell" bundle:nil];
    [_collectonView registerNib:cell forCellWithReuseIdentifier:@"GroupItemCell"];
    
    /*
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"日志" style:UIBarButtonItemStylePlain target:self action:@selector(showLog)];
    self.navigationItem.rightBarButtonItem = item;
    [[LogHelper helper] appendLog:@"begin"];
    */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_collectonView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [dataHelper helper].groups.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GroupItemCell *cell = (GroupItemCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"GroupItemCell" forIndexPath:indexPath];
    groupObject *group = [dataHelper helper].groups[indexPath.item];
    cell.lab.text = group.title;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    groupObject *group = [dataHelper helper].groups[indexPath.item];
    GroupVC *vc = [[GroupVC alloc] init];
    vc.group = group;
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)onAddTouchup:(id)sender
{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"请输入文件夹名称"
                                                                message:nil
                                                         preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"创建" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        NSString *groupName = vc.textFields.firstObject.text;
        if( groupName.length > 0 )
        {
            [[dataHelper helper] createGroupWithName:groupName];
        }
        [_collectonView reloadData];
    }];
    [vc addAction:action];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:cancel];
    
    [vc addTextFieldWithConfigurationHandler:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)onTouchTrash:(id)sender
{
    groupObject *group = [[dataHelper helper] recycleBoxGroup];
    GroupVC *vc = [[GroupVC alloc] init];
    vc.group = group;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)showLog
{
    LogVC *vc = [[LogVC alloc] initWithNibName:@"LogVC" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
