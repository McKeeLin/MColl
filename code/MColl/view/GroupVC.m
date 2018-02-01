//
//  GroupVC.m
//  MColl
//
//  Created by McKee on 2017/4/28.
//  Copyright © 2017年 mckeelin. All rights reserved.
//

#import "GroupVC.h"
#import "appHelper.h"
#import "collCell.h"
#import "dataHelper.h"
#import "CoderHelper.h"
#import "PictureVC.h"
#import "HRListView.h"
#import "captureVC.h"
#import "UIAlertView+Blocks.h"

@interface GroupVC ()<UICollectionViewDelegate,UICollectionViewDataSource,HRListViewDelegate>
{
    UICollectionView *_coll;
    CGFloat _itemWidth;
    UIToolbar *_toolbar;
    UIBarButtonItem *_backItem;
    UIBarButtonItem *_selectItem;
    UIBarButtonItem *_selectAllItem;
    UIBarButtonItem *_unselectAllItem;
    UIBarButtonItem *_restoreItem;
    UIBarButtonItem *_cancelItem;
    UIBarButtonItem *_shareItem;
    UIBarButtonItem *_removeItem;
    UIBarButtonItem *_moveItem;
    UIBarButtonItem *_renameItem;
    UIBarButtonItem *_deleteGroupItem;
    UIBarButtonItem *_captureItem;
    BOOL _selectionMode;
}

@end

@implementation GroupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _group.title;
    self.view.backgroundColor = [UIColor whiteColor];
    
    _itemWidth = [appHelper helper].thumbnailWithHeight;
    CGFloat titleLabelHeight = 30;
    CGFloat thumbnilHeight = 180;
    CGFloat minimumLineSpacing = 2;
    CGFloat minimumInteritemSpacing = 2;
    if( [appHelper helper].isIPhone ){
        titleLabelHeight = 50;
        minimumLineSpacing = 10;
        thumbnilHeight = _itemWidth;
    }
    
    _captureItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(showCapture)];
    
    _selectItem = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStylePlain target:self action:@selector(onTouchSelect:)];
    _selectAllItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(onTouchSelectAll:)];
    _unselectAllItem = [[UIBarButtonItem alloc] initWithTitle:@"取消选择" style:UIBarButtonItemStylePlain target:self action:@selector(onTouchUnselectAll:)];
    _cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(onTouchCancel:)];
    self.navigationItem.rightBarButtonItem = _selectItem;
    
    _shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(onTouchShare:)];
    _renameItem = [[UIBarButtonItem alloc] initWithTitle:@"重命名分组" style:UIBarButtonItemStylePlain target:self action:@selector(onTouchRenameGroup:)];
    _deleteGroupItem = [[UIBarButtonItem alloc] initWithTitle:@"删除分组" style:UIBarButtonItemStylePlain target:self action:@selector(onTouchDeleteGroup:)];
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    _moveItem = [[UIBarButtonItem alloc] initWithTitle:@"移动到" style:UIBarButtonItemStylePlain target:self action:@selector(onTouchMove:)];
    _removeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(onTouchRemove:)];
    _restoreItem = [[UIBarButtonItem alloc] initWithTitle:@"恢复" style:UIBarButtonItemStylePlain target:self action:@selector(restore)];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flexibleItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    if( _group.type == RECYCLE_BOX )
    {
        _toolbar.items = @[flexibleItem];
    }
    else if( _group.type == SHARE_BOX )
    {
        _toolbar.items = @[flexibleItem, _captureItem, flexibleItem2];
    }
    else
    {
        _toolbar.items = @[_renameItem, flexibleItem, _captureItem, flexibleItem2, _deleteGroupItem];
    }
    [self.view addSubview:_toolbar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    CGFloat barHeight = 44;
    
    if( !_coll )
    {
        _itemWidth = (width - 2 * 5)/4;
        [appHelper helper].thumbnailWithHeight = _itemWidth;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(_itemWidth, _itemWidth);
        layout.minimumLineSpacing = 2;
        layout.minimumInteritemSpacing = 2;
        layout.sectionInset = [appHelper helper].isIPhone ? UIEdgeInsetsMake(10, 2, 5, 2) : UIEdgeInsetsMake(20, 20, 20, 20);
        _coll = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _coll.delegate = self;
        _coll.dataSource = self;
        _coll.backgroundColor = [UIColor clearColor];
        _coll.bounces = YES;
        _coll.alwaysBounceVertical = YES;
        [_coll registerClass:[collCell class] forCellWithReuseIdentifier:@"GroupVCCell"];
        [self.view addSubview:_coll];
    }
    _coll.frame = CGRectMake(0, 0, width, height-barHeight);
    _toolbar.frame = CGRectMake(0, height-barHeight, width, barHeight);
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
    return _group.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    collCell *cell = (collCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"GroupVCCell" forIndexPath:indexPath];
    ItemObject *item = _group.items[indexPath.item];
    cell.item = item;
    if( !item.thumbnail )
    {
        [item loadThumbnilInThread];
    }
    else
    {
        [cell.imageView setImage:item.thumbnail];
    }
    cell.imageView.layer.contentsGravity = kCAGravityResizeAspectFill;
    if( _selectionMode )
    {
        cell.selectionState = item.selected ? 1 : 0;
    }
    else
    {
        cell.selectionState = 0;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if( _selectionMode )
    {
        ItemObject *item = _group.items[indexPath.item];
        item.selected = !item.selected;
        collCell *cell = (collCell*)[collectionView cellForItemAtIndexPath:indexPath];
        cell.selectionState = item.selected ? 1 : 0;
//        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
    else
    {
        PictureVC *vc = [[PictureVC alloc] init];
        vc.group = _group;
        vc.index = indexPath.item;
        vc.groupVC = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)onTouchSelect:(id)sender
{
    _backItem = self.navigationItem.leftBarButtonItem;
    self.navigationItem.rightBarButtonItem = _selectAllItem;
    self.navigationItem.leftBarButtonItem = _cancelItem;
    self.title = @"请选择";
    _selectionMode = YES;
    
    UIBarButtonItem *flexibleItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flexibleItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    if( _group.type == RECYCLE_BOX )
    {
        _toolbar.items = @[_restoreItem, flexibleItem1,_removeItem, flexibleItem2, _moveItem];
    }
    else
    {
        _toolbar.items = @[_moveItem, flexibleItem1, _removeItem];
    }
}

- (void)onTouchSelectAll:(id)sender
{
    for( ItemObject *item in _group.items )
    {
        item.selected = YES;
    }
    [_coll reloadData];
    self.navigationItem.rightBarButtonItem = _unselectAllItem;
}

- (void)onTouchUnselectAll:(id)sender
{
    for( ItemObject *item in _group.items )
    {
        item.selected = NO;
    }
    [_coll reloadData];
    self.navigationItem.rightBarButtonItem = _selectAllItem;

}

- (void)onTouchCancel:(id)sender
{
    _selectionMode = NO;
    for( ItemObject *item in _group.items )
    {
        item.selected = NO;
    }
    [_coll reloadData];
    self.navigationItem.rightBarButtonItem = _selectItem;
    self.navigationItem.leftBarButtonItem = _backItem;
    self.title = _group.title;
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flexibleItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    if( _group.type == RECYCLE_BOX )
    {
        _toolbar.items = @[flexibleItem];
    }
    else if( _group.type == SHARE_BOX )
    {
        _toolbar.items = @[flexibleItem, _captureItem, flexibleItem2];
    }
    else
    {
        _toolbar.items = @[_renameItem, flexibleItem, _captureItem, flexibleItem2, _deleteGroupItem];
    }
}

- (void)onTouchRemove:(id)sender
{
    if( _group.type == RECYCLE_BOX )
    {
        [UIAlertView showWithTitle:@"确定要删除所选图片？" message:@"删除后将不可恢复～" cancelButtonTitle:@"取消" otherButtonTitles:@[@"删除"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if( buttonIndex == 1 )
            {
                NSMutableArray *idps = [NSMutableArray arrayWithCapacity:0];
                NSFileManager *fm = [NSFileManager defaultManager];
                
                for( NSInteger i = _group.items.count - 1; i >= 0; i-- )
                {
                    ItemObject *item = _group.items[i];
                    if( item.selected )
                    {
                        NSError *error;
                        if( [fm removeItemAtPath:item.path error:&error] )
                        {
                            NSIndexPath *idp = [NSIndexPath indexPathForItem:i inSection:0];
                            [idps addObject:idp];
                            [_group.items removeObject:item];
                        }
                    }
                }
                
                if( idps.count > 0 )
                {
                    [_coll deleteItemsAtIndexPaths:idps];
                }
            }
            [self onTouchCancel:nil];
        }];
        return;
    }
    
    NSMutableArray *idps = [NSMutableArray arrayWithCapacity:0];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    for( NSInteger i = _group.items.count - 1; i >= 0; i-- )
    {
        ItemObject *item = _group.items[i];
        if( item.selected )
        {
            if( _group.type == RECYCLE_BOX )
            {
                NSError *error;
                if( [fm removeItemAtPath:item.path error:&error] )
                {
                    NSIndexPath *idp = [NSIndexPath indexPathForItem:i inSection:0];
                    [idps addObject:idp];
                    [_group.items removeObject:item];
                }
            }
            else
            {
                if( [[dataHelper helper] deleteItem:item fromGroup:_group] )
                {
                    NSIndexPath *idp = [NSIndexPath indexPathForItem:i inSection:0];
                    [idps addObject:idp];
                }
            }
        }
    }
    
    if( idps.count > 0 )
    {
        [_coll deleteItemsAtIndexPaths:idps];
    }
    [self onTouchCancel:nil];
}

- (void)onTouchMove:(id)sender
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

- (void)onTouchShare:(id)sender
{
//    UIActivityViewController
}

- (void)onTouchRenameGroup:(id)sender
{
    NSString *title = [NSString stringWithFormat:@"重命名分组：%@", _group.title];
    UIAlertController *renameVC = [UIAlertController alertControllerWithTitle:title message:@"请输入新的分组名" preferredStyle:UIAlertControllerStyleAlert];
    [renameVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = _group.title;
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
            self.title = tf.text;
        }
    }];
    [renameVC addAction:renameOKAction];
    
    [self presentViewController:renameVC animated:YES completion:nil];
}

- (void)onTouchDeleteGroup:(id)sender
{
    UIAlertController *alert = [[UIAlertController alloc] init];
    alert.title = [NSString stringWithFormat:@"确认要删除分组：%@", _group.title];
    alert.message = @"该操作将会把分组下的照片移动到回收站，建议先将不想删除的照片移动到其他分组后再执行该操作！";
    
    UIAlertAction *renameCancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:renameCancelAction];
    
    UIAlertAction *renameOKAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[dataHelper helper] removeGroup:_group];
        [self.navigationController popViewControllerAnimated:YES];
        [alert dismissViewControllerAnimated:YES completion:^{
        }];
        
    }];
    [alert addAction:renameOKAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showCapture
{
    captureVC *vc = [[captureVC alloc] init];
    vc.group = _group;
    vc.groupVC = self;
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

- (void)restore
{
    NSMutableArray *idps = [NSMutableArray arrayWithCapacity:0];
    for( NSInteger i = _group.items.count - 1; i >= 0; i-- )
    {
        ItemObject *item = _group.items[i];
        if( item.selected )
        {
            NSArray *components = [item.fileName componentsSeparatedByString:@"_"];
            NSString *groupName = components.firstObject;
            NSString *fileName = components.lastObject;
            groupObject *destGroup = [[dataHelper helper] findGroupByName:groupName];
            if( destGroup )
            {
                NSString *dest = [NSString stringWithFormat:@"%@/%@", destGroup.path, fileName];
                NSFileManager *fm = [NSFileManager defaultManager];
                NSError *error;
                if( [fm moveItemAtPath:item.path toPath:dest error:&error] )
                {
                    item.path = dest;
                    item.fileName = fileName;
                    [_group.items removeObject:item];
                    [destGroup.items addObject:item];
                    NSIndexPath *idp = [NSIndexPath indexPathForItem:i inSection:0];
                    [idps addObject:idp];
                }
            }
            else
            {
                continue;
            }
        }
    }
    
    if( idps.count > 0 )
    {
        [_coll deleteItemsAtIndexPaths:idps];
    }
    [self onTouchCancel:nil];
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
            NSMutableArray *idps = [NSMutableArray arrayWithCapacity:0];
            for( NSInteger i = _group.items.count - 1; i >= 0; i-- )
            {
                ItemObject *item = _group.items[i];
                if( item.selected )
                {
                    if( [[dataHelper helper] moveItem:item from:_group to:destGroup] )
                    {
                        item.selected = NO;
                        NSIndexPath *idp = [NSIndexPath indexPathForItem:i inSection:0];
                        [idps addObject:idp];
                    }
                }
            }
            
            if( idps.count > 0 )
            {
                [_coll deleteItemsAtIndexPaths:idps];
            }
        }
    }
    
    [self onTouchCancel:nil];
}

- (void)onCaptureFinished
{
    [_coll reloadData];
}

- (void)reload
{
    [_coll reloadData];
}

@end
