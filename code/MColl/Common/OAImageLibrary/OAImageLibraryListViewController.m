//
//  OAImageLibraryListViewController.m
//  OAImageLibraryDemo
//
//  Created by mtry on 2017/8/15.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "OAImageLibraryListViewController.h"
#import "OAImageLibraryDetailsViewController.h"
#import "OAImageLibrary.h"
#import "OAImageLibraryDataManager.h"
#import "PHAsset+OAImageLibraryGetImage.h"
#import "UIImage+OAFoundation.h"

#pragma mark - OAImageLibraryListModel

@interface OAImageLibraryListModel : NSObject

@property (nonatomic, readonly) PHAssetCollection *collection;
@property (nonatomic, readonly) NSInteger assetCount;
@property (nonatomic, strong) UIImage *image;

@end

@implementation OAImageLibraryListModel

- (instancetype)initWithAssetCollection:(PHAssetCollection *)assetCollection
{
    self = [super init];
    if (self)
    {
        _collection = assetCollection;
        _assetCount = assetCollection.assets.count;
    }
    return self;
}

@end

#pragma mark - OAImageLibraryListCell

#define OAImageLibraryListCellHeight (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 100 : 60)
#define OAImageLibraryListCellImageWH (OAImageLibraryListCellHeight - 10)

@interface OAImageLibraryListCell : UITableViewCell

@end

@implementation OAImageLibraryListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.textLabel.font = [UIFont systemFontOfSize:15];
        self.detailTextLabel.font = [UIFont systemFontOfSize:14];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.imageView.frame;
    rect.size.height = OAImageLibraryListCellImageWH;
    rect.size.width = OAImageLibraryListCellImageWH;
    rect.origin.y = (CGRectGetHeight(self.contentView.frame) - rect.size.height) / 2;
    self.imageView.frame = rect;
}

- (void)reloadWithModel:(OAImageLibraryListModel *)model
{
    self.textLabel.text = model.collection.localizedTitle;
    self.detailTextLabel.text = [NSString stringWithFormat:@"%ld", model.assetCount];
    if (!model.image)
    {
        PHAsset *asset = model.collection.assets.lastObject;
        CGSize size = CGSizeMake(OAImageLibraryListCellImageWH, OAImageLibraryListCellImageWH);
        [asset imageWithSize:size completeHandeler:^(UIImage *image) {
            if (!CGSizeEqualToSize(image.size, size))
            {
                image = [image imageScaleAspectFillWithSize:size];
            }
            model.image = image;
            self.imageView.image = image;
            [self setNeedsLayout];
        }];
    }
    else
    {
        self.imageView.image = model.image;
        [self setNeedsLayout];
    }
}

@end

#pragma mark - OAImageLibraryListViewController

@interface OAImageLibraryListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *listItems;

@end

@implementation OAImageLibraryListViewController

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (NSMutableArray *)listItems
{
    if (!_listItems)
    {
        _listItems = [NSMutableArray array];
    }
    return _listItems;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(touchUpInsideRightBarButtonItem:)];
    [self.view addSubview:self.tableView];
    [self loadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return OAImageLibraryListCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"OAImageLibraryListViewControllerIdentifier";
    OAImageLibraryListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[OAImageLibraryListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.row < self.listItems.count)
    {
        OAImageLibraryListModel *model = self.listItems[indexPath.row];
        [cell reloadWithModel:model];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < self.listItems.count)
    {
        OAImageLibraryListModel *model = self.listItems[indexPath.row];
        OAImageLibraryDetailsViewController *controller = [[OAImageLibraryDetailsViewController alloc] initWithAssets:model.collection.assets];
        controller.title = model.collection.localizedTitle;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)touchUpInsideRightBarButtonItem:(UIBarButtonItem *)buttonItem
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        if ([OAImageLibrary sharedInstance].mode == OAImageLibraryModePicker)
        {
            if ([OAImageLibrary sharedInstance].pickerCompleteHandler)
            {
                [OAImageLibrary sharedInstance].pickerCompleteHandler(OAImageLibraryCompleteTypeCancel, nil, nil);
            }
        }
        else if ([OAImageLibrary sharedInstance].mode == OAImageLibraryModeCroper)
        {
            if ([OAImageLibrary sharedInstance].croperCompleteHandler)
            {
                [OAImageLibrary sharedInstance].croperCompleteHandler(OAImageLibraryCompleteTypeCancel, nil, nil);
            }
        }
        [[OAImageLibrary sharedInstance] didFinished];
    }];
}

- (void)loadData
{
    [OAImageLibraryDataManager fetchCollectionDataWithCompleteHandler:^(NSArray<PHAssetCollection *> *listItems) {
        [self.listItems removeAllObjects];
        for (PHAssetCollection *collection in listItems)
        {
            OAImageLibraryListModel *model = [[OAImageLibraryListModel alloc] initWithAssetCollection:collection];
            [self.listItems addObject:model];
        }
        [self.tableView reloadData];
    }];
}

@end
