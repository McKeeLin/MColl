//
//  OAImageLibraryDetailsViewController.m
//  OAImageLibraryDemo
//
//  Created by mtry on 2017/8/15.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import <Photos/Photos.h>
#import "OAImageLibraryDetailsViewController.h"
#import "OAImageLibraryPreviewViewController.h"
#import "OAImageLibraryCropViewController.h"
#import "OAImageLibrary.h"
#import "PHAsset+OAImageLibraryGetImage.h"

#pragma mark - OAImageLibraryDetailsModel

@interface OAImageLibraryDetailsModel : NSObject

@property (nonatomic, copy, readonly) PHAsset *asset;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, strong) UIImage *thumbnails;

@end

@implementation OAImageLibraryDetailsModel

- (instancetype)initWithAsset:(PHAsset *)asset
{
    self = [super init];
    if (self)
    {
        _asset = asset;
    }
    return self;
}

@end

#pragma mark - OAImageLibraryDetailsCell

@class OAImageLibraryDetailsCell;

@protocol OAImageLibraryDetailsCellDelegate <NSObject>

- (void)imageLibraryDetailsCell:(OAImageLibraryDetailsCell *)cell didTouchSelectButton:(UIButton *)button;

@end

@interface OAImageLibraryDetailsCell : UICollectionViewCell

@property (nonatomic, weak) id<OAImageLibraryDetailsCellDelegate>delegate;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *selectButton;

@end

@implementation OAImageLibraryDetailsCell
{
    OAImageLibraryDetailsModel *_model;
}

- (UIImageView *)imageView
{
    if (!_imageView)
    {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.userInteractionEnabled = YES;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UIButton *)selectButton
{
    if (!_selectButton)
    {
        _selectButton = [[UIButton alloc] init];
        [_selectButton addTarget:self action:@selector(touchUpInsideSelectButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectButton;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.selectButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = CGRectZero;
    rect.size = CGSizeMake(40, 40);
    rect.origin.x = CGRectGetWidth(self.contentView.frame) - rect.size.width;
    self.selectButton.frame = rect;
    self.selectButton.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 10, 0);
}

- (void)touchUpInsideSelectButton:(UIButton *)button
{
    [self.delegate imageLibraryDetailsCell:self didTouchSelectButton:button];
}

- (void)reloadWithModel:(OAImageLibraryDetailsModel *)model
{
    _model = model;
    if (model.selected)
    {
        [self.selectButton setImage:[UIImage imageNamed:@"imageLibrary_selected"] forState:UIControlStateNormal];
    }
    else
    {
        [self.selectButton setImage:[UIImage imageNamed:@"imageLibrary_select"] forState:UIControlStateNormal];
    }
    
    if (model.thumbnails)
    {
        self.imageView.image = model.thumbnails;
        [self setNeedsLayout];
    }
    else
    {
        [model.asset imageWithSize:self.contentView.bounds.size completeHandeler:^(UIImage *image) {
            if ([model.asset.localIdentifier isEqualToString:_model.asset.localIdentifier])
            {
                model.thumbnails = image;
                self.imageView.image = image;
                [self setNeedsLayout];
            }
        }];
    }
}

@end

#pragma mark - OAImageLibraryDetailsBar

#define OAImageLibraryDetailsBarHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight)) ? 30 : 44)

@class OAImageLibraryDetailsBar;

@protocol OAImageLibraryDetailsBarDelegate <NSObject>

- (void)imageLibraryDetailsBarPreview:(OAImageLibraryDetailsBar *)bar;
- (void)imageLibraryDetailsBarFinish:(OAImageLibraryDetailsBar *)bar;

@end

@interface OAImageLibraryDetailsBar : UIView

@property (nonatomic, weak) id<OAImageLibraryDetailsBarDelegate>delegate;
@property (nonatomic, strong) UIButton *previewButton;
@property (nonatomic, strong) UIButton *finishButton;
@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, assign) BOOL enabled;

@end

@implementation OAImageLibraryDetailsBar

- (UIButton *)previewButton
{
    if (!_previewButton)
    {
        _previewButton = [[UIButton alloc] init];
        _previewButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_previewButton setTitle:@"预览" forState:UIControlStateNormal];
        [_previewButton setTitleColor:[UIColor colorWithRed:0.53 green:0.81 blue:0.13 alpha:1] forState:UIControlStateNormal];
        [_previewButton setTitleColor:[UIColor colorWithRed:0.53 green:0.81 blue:0.13 alpha:0.5] forState:UIControlStateHighlighted];
        [_previewButton setTitleColor:[UIColor colorWithRed:0.53 green:0.81 blue:0.13 alpha:0.5] forState:UIControlStateDisabled];
        [_previewButton addTarget:self action:@selector(touchUpInsidePreviewButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _previewButton;
}

- (UIButton *)finishButton
{
    if (!_finishButton)
    {
        _finishButton = [[UIButton alloc] init];
        _finishButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_finishButton setTitle:@"完成" forState:UIControlStateNormal];
        [_finishButton setTitleColor:[UIColor colorWithRed:0.53 green:0.81 blue:0.13 alpha:1] forState:UIControlStateNormal];
        [_finishButton setTitleColor:[UIColor colorWithRed:0.53 green:0.81 blue:0.13 alpha:0.5] forState:UIControlStateHighlighted];
        [_finishButton setTitleColor:[UIColor colorWithRed:0.53 green:0.81 blue:0.13 alpha:0.5] forState:UIControlStateDisabled];
        [_finishButton addTarget:self action:@selector(touchUpInsideFinishButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishButton;
}

- (UILabel *)numberLabel
{
    if (!_numberLabel)
    {
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.font = [UIFont systemFontOfSize:14];
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.textColor = [UIColor whiteColor];
        _numberLabel.text = @"0";
    }
    return _numberLabel;
}

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    self.finishButton.enabled = enabled;
    self.previewButton.enabled = enabled;
    if (enabled)
    {
        self.numberLabel.backgroundColor = [UIColor colorWithRed:0.53 green:0.81 blue:0.13 alpha:1];
    }
    else
    {
        self.numberLabel.backgroundColor = [UIColor colorWithRed:0.53 green:0.81 blue:0.13 alpha:0.5];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addSubview:self.previewButton];
        [self addSubview:self.finishButton];
        [self addSubview:self.numberLabel];
        self.enabled = NO;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    rect.size.width = 60;
    self.previewButton.frame = rect;
    
    rect = self.previewButton.frame;
    rect.origin.x = CGRectGetWidth(self.frame) - rect.size.width;
    self.finishButton.frame = rect;
    
    rect.size = CGSizeMake(20, 20);
    rect.origin.x = CGRectGetMinX(self.finishButton.frame) - rect.size.width + 5;
    rect.origin.y = (CGRectGetHeight(self.frame) - rect.size.height) / 2;
    self.numberLabel.frame = rect;
    self.numberLabel.layer.cornerRadius = rect.size.height / 2;
    self.numberLabel.layer.masksToBounds = YES;
}

- (void)touchUpInsidePreviewButton:(UIButton *)button
{
    [self.delegate imageLibraryDetailsBarPreview:self];
}

- (void)touchUpInsideFinishButton:(UIButton *)button
{
    [self.delegate imageLibraryDetailsBarFinish:self];
}

- (void)reloadWithNumber:(NSInteger)number
{
    self.numberLabel.text = [NSString stringWithFormat:@"%ld", number];
    self.enabled = number > 0;
}

@end

#pragma mark - OAImageLibraryDetailsViewController

static NSString *reuseIdentifier = @"OAImageLibraryDetailsReuseIdentifier";

@interface OAImageLibraryDetailsViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, OAImageLibraryDetailsCellDelegate, OAImageLibraryDetailsBarDelegate, OAImageLibraryPreviewViewControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) OAImageLibraryDetailsBar *bottomBar;
@property (nonatomic, strong) NSMutableArray *listItems;
@property (nonatomic, strong) NSMutableArray *selectedItems;

@end

@implementation OAImageLibraryDetailsViewController
{
    CGSize _collectionViewSize;
    BOOL _shouldScrollBottom;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView)
    {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = [self itemSize];
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.alwaysBounceVertical = YES;
        [_collectionView registerClass:[OAImageLibraryDetailsCell class] forCellWithReuseIdentifier:reuseIdentifier];
    }
    return _collectionView;
}

- (OAImageLibraryDetailsBar *)bottomBar
{
    if (!_bottomBar)
    {
        _bottomBar = [[OAImageLibraryDetailsBar alloc] init];
        _bottomBar.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.96 alpha:1];
        _bottomBar.delegate = self;
    }
    return _bottomBar;
}

- (NSMutableArray *)listItems
{
    if (!_listItems)
    {
        _listItems = [NSMutableArray array];
    }
    return _listItems;
}

- (NSMutableArray *)selectedItems
{
    if (!_selectedItems)
    {
        _selectedItems = [NSMutableArray array];
    }
    return _selectedItems;
}

- (instancetype)initWithAssets:(NSArray<PHAsset *> *)assets
{
    self = [super init];
    if (self)
    {
        _shouldScrollBottom = YES;
        for (PHAsset *asset in assets)
        {
            OAImageLibraryDetailsModel *model = [[OAImageLibraryDetailsModel alloc] initWithAsset:asset];
            [self.listItems addObject:model];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(touchUpInsideRightBarButtonItem:)];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    if ([OAImageLibrary sharedInstance].mode == OAImageLibraryModePicker)
    {
        [self.view addSubview:self.bottomBar];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if ([OAImageLibrary sharedInstance].mode == OAImageLibraryModePicker)
    {
        CGRect rect = self.view.bounds;
        rect.size.height = CGRectGetHeight(self.view.frame) - OAImageLibraryDetailsBarHeight;
        self.collectionView.frame = rect;
        
        rect = self.view.bounds;
        rect.origin.y = CGRectGetMaxY(self.collectionView.frame);
        rect.size.height = CGRectGetHeight(self.view.frame) - rect.origin.y;
        self.bottomBar.frame = rect;
    }
    else if ([OAImageLibrary sharedInstance].mode == OAImageLibraryModeCroper)
    {
        CGRect rect = self.view.bounds;
        rect.size.height = CGRectGetHeight(self.view.frame);
        self.collectionView.frame = rect;
    }
    
    _collectionViewSize = self.collectionView.bounds.size;
    if (_shouldScrollBottom && self.listItems.count)
    {
        _shouldScrollBottom = NO;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.listItems.count - 1 inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    _collectionViewSize = size;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    [layout invalidateLayout];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.listItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OAImageLibraryDetailsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    if (indexPath.row < self.listItems.count)
    {
        OAImageLibraryDetailsModel *model = self.listItems[indexPath.row];
        [cell reloadWithModel:model];
        cell.selectButton.hidden = [OAImageLibrary sharedInstance].mode != OAImageLibraryModePicker;
    }
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat space = [self itemSpace];
    return UIEdgeInsetsMake(space, space, space, space);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return [self itemSpace];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.listItems.count)
    {
        OAImageLibraryDetailsModel *model = self.listItems[indexPath.row];
        if ([OAImageLibrary sharedInstance].mode == OAImageLibraryModePicker)
        {
            NSArray *showAssets = [self assetsForDetailModels:self.listItems];
            NSArray *selectAssets = [self assetsForDetailModels:self.selectedItems];
            OAImageLibraryPreviewViewController *controller = [[OAImageLibraryPreviewViewController alloc] initWithShowAssets:showAssets selectAssets:selectAssets];
            controller.delegate = self;
            controller.showIndex = indexPath.row;
            [self.navigationController pushViewController:controller animated:YES];
        }
        else if ([OAImageLibrary sharedInstance].mode == OAImageLibraryModeCroper)
        {
            OAImageLibraryCropViewController *controller = [[OAImageLibraryCropViewController alloc] initWithAsset:model.asset];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

- (void)imageLibraryDetailsCell:(OAImageLibraryDetailsCell *)cell didTouchSelectButton:(UIButton *)button
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    if (indexPath && indexPath.row < self.listItems.count)
    {
        OAImageLibraryDetailsModel *model = self.listItems[indexPath.row];
        if(!model.selected && self.selectedItems.count >= [OAImageLibrary sharedInstance].maxNumber)
        {
            NSString *message = [NSString stringWithFormat:@"最多只能选择%ld张图片", [OAImageLibrary sharedInstance].maxNumber];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            model.selected = !model.selected;
            if (model.selected)
            {
                if (![self.selectedItems containsObject:model])
                {
                    [self.selectedItems addObject:model];
                }
            }
            else
            {
                if ([self.selectedItems containsObject:model])
                {
                    [self.selectedItems removeObject:model];
                }
            }
            [cell reloadWithModel:model];
            [self.bottomBar reloadWithNumber:self.selectedItems.count];
        }
    }
}

- (void)imageLibraryDetailsBarPreview:(OAImageLibraryDetailsBar *)bar
{
    NSArray *showAssets = [self assetsForDetailModels:self.selectedItems];
    NSArray *selectAssets = [self assetsForDetailModels:self.selectedItems];
    OAImageLibraryPreviewViewController *controller = [[OAImageLibraryPreviewViewController alloc] initWithShowAssets:showAssets selectAssets:selectAssets];
    controller.delegate = self;
    controller.showIndex = 0;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)imageLibraryDetailsBarFinish:(OAImageLibraryDetailsBar *)bar
{
    if ([OAImageLibrary sharedInstance].pickerCompleteHandler)
    {
        NSArray *assets = [self assetsForDetailModels:self.selectedItems];
        [OAImageLibrary sharedInstance].pickerCompleteHandler(OAImageLibraryCompleteTypeSuccess, assets, nil);
    }
    [[OAImageLibrary sharedInstance] didFinished];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageLibraryPreviewViewController:(OAImageLibraryPreviewViewController *)previewViewController addAssetLocalIdentifier:(NSString *)localIdentifier
{
    [self.listItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(OAImageLibraryDetailsModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([localIdentifier isEqualToString:model.asset.localIdentifier])
        {
            model.selected = YES;
            [self.selectedItems addObject:model];
            [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]]];
        }
    }];
}

- (void)imageLibraryPreviewViewController:(OAImageLibraryPreviewViewController *)previewViewController removeAssetLocalIdentifier:(NSString *)localIdentifier
{
    [self.selectedItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(OAImageLibraryDetailsModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([localIdentifier isEqualToString:model.asset.localIdentifier])
        {
            [self.selectedItems removeObject:model];
        }
    }];
    
    [self.listItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(OAImageLibraryDetailsModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([localIdentifier isEqualToString:model.asset.localIdentifier])
        {
            model.selected = NO;
            [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]]];
        }
    }];
}

- (void)imageLibraryPreviewViewControllerFinished:(OAImageLibraryPreviewViewController *)previewViewController
{
    [self.bottomBar.finishButton sendActionsForControlEvents:UIControlEventTouchUpInside];
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

- (CGFloat)itemSpace
{
    CGSize itemSize = [self itemSize];
    NSInteger row = floor(_collectionViewSize.width / itemSize.width);
    return (_collectionViewSize.width - itemSize.width * row) / (row + 1);
}

- (CGSize)itemSize
{
    CGFloat minWidth = fmin([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    NSInteger numberOfCol = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 4 : 5);
    CGFloat itemWH = floor(minWidth / numberOfCol - ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 5 : 3));
    return CGSizeMake(itemWH, itemWH);
}

- (NSArray<PHAsset *> *)assetsForDetailModels:(NSArray<OAImageLibraryDetailsModel *> *)models
{
    NSMutableArray *assets = [NSMutableArray array];
    for (OAImageLibraryDetailsModel *model in models)
    {
        [assets addObject:model.asset.copy];
    }
    return assets;
}

@end
