//
//  ViewController.m
//  MColl
//
//

#import "collectionVC.h"
#import "appHelper.h"
#import "collCell.h"
#import "captureVC.h"
#import "dataHelper.h"
#import "PictureVC.h"
#import "CollHeader.h"
#import "CoderHelper.h"
#import "GroupVC.h"





@interface collectionVC ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    UICollectionView *_coll;
    UIToolbar *_toolbar;
    CGFloat _itemWidth;
    NSOperationQueue *_queue;
}

@end

@implementation collectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.title = @"MColl";
    self.view.backgroundColor = [UIColor whiteColor];
    
    _queue = [[NSOperationQueue alloc] init];
    CGFloat titleLabelHeight = 30;
    CGFloat thumbnilHeight = 180;
    CGFloat minimumLineSpacing = 20;
    CGFloat minimumInteritemSpacing = 1;
    _itemWidth = [appHelper helper].thumbnailWithHeight;
    if( [appHelper helper].isIPhone ){
        titleLabelHeight = 50;
        minimumLineSpacing = 10;
        thumbnilHeight = _itemWidth;
    }
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(_itemWidth, _itemWidth);
    layout.minimumLineSpacing = minimumLineSpacing;
    layout.minimumInteritemSpacing = minimumInteritemSpacing;
    layout.sectionInset = [appHelper helper].isIPhone ? UIEdgeInsetsMake(10, 5, 5, 5) : UIEdgeInsetsMake(20, 20, 20, 20);
    _coll = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _coll.delegate = self;
    _coll.dataSource = self;
    _coll.bounces = YES;
    _coll.alwaysBounceVertical = YES;
    _coll.backgroundColor = [UIColor clearColor];
    [_coll registerClass:[collCell class] forCellWithReuseIdentifier:COLLECTION_VC_CELL];
    [_coll registerClass:[CollHeader class]
        forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
               withReuseIdentifier:@"CollHeader"];
    [self.baseContainerView addSubview:_coll];
    
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    _toolbar.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAddTouchup:)];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *trashItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(onTouchTrash:)];
    UIBarButtonItem *flexibleItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *caputureItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(onCaputreTouchup:)];
    _toolbar.items = [NSArray arrayWithObjects:addItem, flexibleItem, trashItem, flexibleItem2, caputureItem, nil];
    [self.baseContainerView addSubview:_toolbar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat toolbarHeight = 40;
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    _toolbar.frame = CGRectMake(0, self.baseContainerView.frame.size.height - toolbarHeight, width, toolbarHeight);
    _coll.frame = CGRectMake(0, 0, width, height-toolbarHeight);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self reload];
}

#pragma mark- UICollectionViewDelegate

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if( [kind isEqualToString:UICollectionElementKindSectionHeader] )
    {
        NSString *CellIdentifier = @"CollHeader";
        
        CollHeader *cell =
        (CollHeader *)[collectionView
                       dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                       withReuseIdentifier:CellIdentifier
                       forIndexPath:indexPath];
        
        groupObject *group = [dataHelper helper].groups[indexPath.section];
        cell.groupNameLab.text = group.title;
        cell.disclosureButton.tag = indexPath.section;
        if( cell.disclosureButton.allTargets.count == 0 )
        {
            [cell.disclosureButton addTarget:self action:@selector(onTouchDisclosureButton:) forControlEvents:UIControlEventTouchUpInside];
        }
        return cell;
    }
    return nil;
}

-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(collectionView.bounds.size.width, 50);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    groupObject *group = [dataHelper helper].groups[indexPath.section];
    if( indexPath.item == group.items.count )
    {
        captureVC *vc = [[captureVC alloc] init];
        vc.group = group;
        vc.collVC = self;
        [self.navigationController presentViewController:vc animated:YES completion:nil];
    }
    else
    {
        PictureVC *vc = [[PictureVC alloc] init];
        vc.group = group;
        vc.index = indexPath.item;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [dataHelper helper].groups.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    groupObject *group = [dataHelper helper].groups[section];
    return group.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    collCell *cell = (collCell*)[collectionView dequeueReusableCellWithReuseIdentifier:COLLECTION_VC_CELL forIndexPath:indexPath];
    groupObject *group = [dataHelper helper].groups[indexPath.section];
    ItemObject *item = group.items[indexPath.item];
    cell.item = item;
    if( !item.thumbnail )
    {
        [item loadThumbnilInThread];
    }
    else
    {
        cell.imageView.image = item.thumbnail;
        cell.imageView.layer.contentsGravity = kCAGravityResizeAspectFill;
    }
    return cell;
}



- (void)onAddTouchup:(id)sender
{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"请输入记录名称"
                                                                message:nil
                                                         preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"创建" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        NSString *groupName = vc.textFields.firstObject.text;
        if( groupName.length > 0 )
        {
            [[dataHelper helper] createGroupWithName:groupName];
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:[dataHelper helper].groups.count-1];
        [_coll reloadData];
    }];
    [vc addAction:action];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:cancel];
    
    [vc addTextFieldWithConfigurationHandler:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)onCaputreTouchup:(id)sender
{
    captureVC *vc = [[captureVC alloc] init];
    vc.collVC = self;
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

- (void)onTouchTrash:(id)sender
{
    groupObject *group = [[dataHelper helper] recycleBoxGroup];
    GroupVC *vc = [[GroupVC alloc] init];
    vc.group = group;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)onCaptureFinish
{
    [_coll reloadData];
}

- (void)reload
{
    [_coll reloadData];
}

- (void)onLondPressGroupNameLabel:(UILabel*)label
{
    UIAlertController *controller = [[UIAlertController alloc] init];
    controller.title = @"";
    controller.message = @"";
}

- (void)onTouchDisclosureButton:(UIButton*)button
{
    groupObject *group = [dataHelper helper].groups[button.tag];
    GroupVC *vc = [[GroupVC alloc] init];
    vc.group = group;
    vc.collVC = self;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
