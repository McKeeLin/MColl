//
//  previewVC.m
//  OA2
//
//  Created by game-netease on 15/6/4.
//  Copyright (c) 2015年 game-netease. All rights reserved.
//

#import "PictureVC.h"
#import "CoderHelper.h"
#import "dataHelper.h"
#import "GroupVC.h"
#import "collectionVC.h"
#import "appHelper.h"
#import "UIAlertView+Blocks.h"


@interface attachmetPreviewItem : NSObject<QLPreviewItem>
@property (nonatomic) NSURL * previewItemURL;
@property (nonatomic) NSString * previewItemTitle;

- (id)initWithUrl:(NSURL*)url title:(NSString*)title;

@end

@implementation attachmetPreviewItem

- (id)initWithUrl:(NSURL *)url title:(NSString *)title
{
    self = [super init];
    if( self ){
        _previewItemURL = url;
        _previewItemTitle = title;
    }
    return self;
}

@end


@interface PictureVC ()<QLPreviewControllerDelegate,QLPreviewControllerDataSource>
{
    UIBarButtonItem *_deleteItem;
    UIBarButtonItem *_restoreItem;
}

@end

@implementation PictureVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if( self )
    {
        if( !_deleteItem )
        {
            _deleteItem = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(onTouchDelete:)];
            _restoreItem = [[UIBarButtonItem alloc] initWithTitle:@"恢复" style:UIBarButtonItemStylePlain target:self action:@selector(onTouchRestore:)];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = self;
    self.delegate = self;
    self.navigationItem.rightBarButtonItem = nil;    
    [self reloadData];
    [self setCurrentPreviewItemIndex:_index];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if( self.toolbarItems.count >= 1 )
    {
        NSInteger i = self.toolbarItems.count;
        NSMutableArray *items = [NSMutableArray arrayWithArray:self.toolbarItems];
        if( [self.toolbarItems indexOfObject:_deleteItem] == NSNotFound )
        {
            UIBarButtonItem *space0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            [items insertObject:space0 atIndex:i++];
            [items insertObject:_deleteItem atIndex:i++];
            if( _group.type == RECYCLE_BOX )
            {
                UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
                [items insertObject:space atIndex:i++];
                [items insertObject:_restoreItem atIndex:i++];
                UIBarButtonItem *space2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//                [items insertObject:space2 atIndex:i];
            }
            [self setToolbarItems:items animated:NO];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return _group.items.count;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    ItemObject *item = _group.items[index];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:item.fileName];
    NSFileManager *fm = [NSFileManager defaultManager];
    if( ![fm fileExistsAtPath:filePath] )
    {
        NSData *encodedData = [NSData dataWithContentsOfFile:item.path];
        NSData *plainData = [[CoderHelper helper] decodeData:encodedData];
        if( ![plainData writeToFile:filePath atomically:YES] )
        {
            return nil;
        }
    }
    
    return [[attachmetPreviewItem alloc] initWithUrl:[NSURL fileURLWithPath:filePath] title:item.name];
}

- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id <QLPreviewItem>)item
{
    return YES;
}

- (void)onTouchDelete:(id)sender
{
    if( _group.items.count == 0 )
    {
        return;
    }
    NSInteger currentPreviewItemIndex = self.currentPreviewItemIndex;
    ItemObject *item = _group.items[currentPreviewItemIndex];
    NSString *name = [NSString stringWithFormat:@"%@_%@", _group.title, item.fileName];
    NSString *dest = [[[dataHelper helper] recycleBoxPath] stringByAppendingPathComponent:name];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    if( _group.type == RECYCLE_BOX )
    {
        [UIAlertView showWithTitle:@"确定要删除照片？" message:@"从回收站删除照片将不可恢复！" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if( buttonIndex == 1 )
            {
                NSError *err;
                if( [fm removeItemAtPath:item.path error:&err] )
                {
                    [_group.items removeObject:item];
                    [self reloadData];
                    NSInteger index = currentPreviewItemIndex - 1;
                    if( _group.items.count > 0 )
                    {
                        if( index < 0 )
                        {
                            index = 0;
                        }
                        [self setCurrentPreviewItemIndex:index];
                    }
                    else
                    {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
            }
        }];
    }
    else
    {
        if( [fm moveItemAtPath:item.path toPath:dest error:&error] )
        {
            item.fileName = name;
            item.path = dest;
            [_group.items removeObject:item];
            [[dataHelper helper].recycleBoxGroup.items addObject:item];
            
            [self reloadData];
            NSInteger index = currentPreviewItemIndex - 1;
            if( _group.items.count > 0 )
            {
                if( index < 0 )
                {
                    index = 0;
                }
                [self setCurrentPreviewItemIndex:index];
            }
            else
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
    
    [_groupVC reload];
}

- (void)onTouchRestore:(id)sender
{
    if( _group.items.count == 0 )
    {
        return;
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    NSInteger currentPreviewItemIndex = self.currentPreviewItemIndex;
    ItemObject *item = _group.items[currentPreviewItemIndex];
    NSArray *components = [item.fileName componentsSeparatedByString:@"_"];
    NSString *groupName = components.firstObject;
    NSString *fileName = components.lastObject;
    groupObject *destGroup = [[dataHelper helper] findGroupByName:groupName];
    if( destGroup )
    {
        NSString *dest = [NSString stringWithFormat:@"%@/%@", destGroup.path, fileName];
        if( [fm moveItemAtPath:item.path toPath:dest error:&error] )
        {
            item.fileName = fileName;
            item.path = dest;
            [_group.items removeObject:item];
            [destGroup.items addObject:item];
            [_groupVC reload];
            [[appHelper helper].collVC reload];
            [self reloadData];
            NSInteger index = currentPreviewItemIndex - 1;
            if( _group.items.count > 0 )
            {
                if( index < 0 )
                {
                    index = 0;
                }
                [self setCurrentPreviewItemIndex:index];
            }
            else
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
}

@end
