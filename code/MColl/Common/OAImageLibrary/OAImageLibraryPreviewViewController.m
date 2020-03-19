//
//  OAImageLibraryPreviewViewController.m
//  OAImageLibraryDemo
//
//  Created by mtry on 2017/8/15.
//  Copyright © 2017年 NetEase. All rights reserved.
//

#import "OAImageLibraryPreviewViewController.h"
#import "OAImageLibraryZoomView.h"
#import "OAImageLibrary.h"
#import "PHAsset+OAImageLibraryGetImage.h"

#pragma mark - OAImageLibraryPreviewModel

@interface OAImageLibraryPreviewModel : NSObject

@property (nonatomic, strong, readonly) PHAsset *asset;
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, assign) BOOL selected;

@end

@implementation OAImageLibraryPreviewModel

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

#pragma mark - OAImageLibraryPreviewCell

static CGFloat cellMargeX = 10;

@interface OAImageLibraryPreviewCell : UICollectionViewCell

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) OAImageLibraryZoomView *zoomView;
@property (nonatomic, readonly) OAImageLibraryPreviewModel *model;

@end

@implementation OAImageLibraryPreviewCell

- (OAImageLibraryZoomView *)zoomView
{
    if (!_zoomView)
    {
        _zoomView = [[OAImageLibraryZoomView alloc] init];
    }
    return _zoomView;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView)
    {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicatorView.hidesWhenStopped = YES;
    }
    return _indicatorView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self.contentView addSubview:self.zoomView];
        [self.contentView addSubview:self.indicatorView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.contentView.bounds;
    rect.size.width -= cellMargeX;
    self.zoomView.frame = rect;
    
    self.indicatorView.center = self.contentView.center;
}

- (void)reloadWithModel:(OAImageLibraryPreviewModel *)model
{
    _model = model;
    
    if (model.originalImage)
    {
        [self.zoomView reloadWithImage:model.originalImage];
    }
    else
    {
        [self.zoomView reloadWithImage:nil];
        [self.indicatorView startAnimating];
        [model.asset imageWithSize:PHImageManagerMaximumSize completeHandeler:^(UIImage *image) {
            if ([model.asset.localIdentifier isEqualToString:self.model.asset.localIdentifier])
            {
                model.originalImage = image;
                [self.zoomView reloadWithImage:image];
                self.zoomView.alpha = 0;
                [UIView animateWithDuration:0.15 animations:^{
                    self.zoomView.alpha = 1;
                }];
                [self.indicatorView stopAnimating];
            }
        }];
    }
}

@end

#pragma mark - OAImageLibraryPreviewViewController

#define OAImageLibraryPreviewIPhoneLandscapeLeftOrRight (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight))
#define OAImageLibraryPreviewTopBarHeight (OAImageLibraryPreviewIPhoneLandscapeLeftOrRight ? 30 : 64)
#define OAImageLibraryPreviewBottomBarHeight (OAImageLibraryPreviewIPhoneLandscapeLeftOrRight ? 30 : 44)

static NSString *reuseIdentifier = @"OAImageLibraryPreviewReuseIdentifier";

@interface OAImageLibraryPreviewViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, OAImageLibraryZoomViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) UIButton *finishButton;
@property (nonatomic, strong) UILabel *numberLabel;

@property (nonatomic, strong) NSMutableArray *listItems;
@property (nonatomic, strong) NSMutableArray *selectItems;

@end

@implementation OAImageLibraryPreviewViewController

- (UICollectionView *)collectionView
{
    if (!_collectionView)
    {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[OAImageLibraryPreviewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    }
    return _collectionView;
}

- (UIView *)topBar
{
    if (!_topBar)
    {
        _topBar = [[UIView alloc] init];
        _topBar.backgroundColor = [UIColor colorWithRed:0.156 green:0.156 blue:0.156 alpha:0.8];
    }
    return _topBar;
}

- (UIView *)bottomBar
{
    if (!_bottomBar)
    {
        _bottomBar = [[UIView alloc] init];
        _bottomBar.backgroundColor = [UIColor colorWithRed:0.156 green:0.156 blue:0.156 alpha:0.8];
    }
    return _bottomBar;
}

- (UIButton *)backButton
{
    if (!_backButton)
    {
        _backButton = [[UIButton alloc] init];
        [_backButton setImage:[UIImage imageNamed:@"imageLibrary_back"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(touchUpInsideBackButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIButton *)selectButton
{
    if (!_selectButton)
    {
        _selectButton = [[UIButton alloc] init];
        [_selectButton setImage:[UIImage imageNamed:@"imageLibrary_select"] forState:UIControlStateNormal];
        [_selectButton addTarget:self action:@selector(touchUpInsideSelectButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectButton;
}

- (UILabel *)numberLabel
{
    if (!_numberLabel)
    {
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.font = [UIFont systemFontOfSize:14];
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.textColor = [UIColor whiteColor];
    }
    return _numberLabel;
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

- (NSMutableArray *)listItems
{
    if (!_listItems)
    {
        _listItems = [NSMutableArray array];
    }
    return _listItems;
}

- (NSMutableArray *)selectItems
{
    if (!_selectItems)
    {
        _selectItems = [NSMutableArray array];
    }
    return _selectItems;
}

- (instancetype)initWithShowAssets:(NSArray<PHAsset *> *)showAssets selectAssets:(NSArray<PHAsset *> *)selectAssets
{
    self = [super init];
    if (self)
    {
        for (PHAsset *asset in showAssets)
        {
            [self.listItems addObject:[[OAImageLibraryPreviewModel alloc] initWithAsset:asset]];
        }
        for (PHAsset *asset in selectAssets)
        {
            for (OAImageLibraryPreviewModel *model in self.listItems)
            {
                if ([asset.localIdentifier isEqualToString:model.asset.localIdentifier])
                {
                    model.selected = YES;
                    [self.selectItems addObject:model];
                }
            }
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.topBar];
    [self.view addSubview:self.bottomBar];
    [self.topBar addSubview:self.backButton];
    [self.topBar addSubview:self.selectButton];
    [self.bottomBar addSubview:self.numberLabel];
    [self.bottomBar addSubview:self.finishButton];
    
    [self updateBottomBarStatus];
    [self updateSelectButtonStatus];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect rect = self.view.bounds;
    rect.size.width += cellMargeX;
    self.collectionView.frame = rect;
    
    rect = self.view.bounds;
    rect.size.height = OAImageLibraryPreviewTopBarHeight;
    self.topBar.frame = rect;
    
    rect = self.view.bounds;
    rect.size.height = OAImageLibraryPreviewBottomBarHeight;
    rect.origin.y = CGRectGetHeight(self.view.frame) - rect.size.height;
    self.bottomBar.frame = rect;
    
    rect.size.width = 50;
    rect.size.height = CGRectGetHeight(self.topBar.frame);
    rect.origin.x = 0;
    rect.origin.y = 0;
    self.backButton.frame = rect;
    self.backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
    
    rect.origin.x = CGRectGetWidth(self.topBar.frame) - CGRectGetWidth(self.backButton.frame);
    self.selectButton.frame = rect;
    
    rect = self.bottomBar.bounds;
    rect.size.width = 60;
    rect.origin.x = CGRectGetWidth(self.bottomBar.frame) - rect.size.width;
    self.finishButton.frame = rect;
    
    rect.size = CGSizeMake(20, 20);
    rect.origin.x = CGRectGetMinX(self.finishButton.frame) - rect.size.width + 5;
    rect.origin.y = (CGRectGetHeight(self.bottomBar.frame) - rect.size.height) / 2;
    self.numberLabel.frame = rect;
    self.numberLabel.layer.cornerRadius = rect.size.height / 2;
    self.numberLabel.layer.masksToBounds = YES;
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.showIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.presentedViewController)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (!self.presentedViewController)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    [layout invalidateLayout];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.listItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OAImageLibraryPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (indexPath.row < self.listItems.count)
    {
        OAImageLibraryPreviewModel *model = self.listItems[indexPath.row];
        [cell reloadWithModel:model];
        
        cell.zoomView.delegate = self;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = self.view.bounds.size;
    size.width += cellMargeX;
    return size;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.showIndex = scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame);
    [self updateSelectButtonStatus];
}

- (void)imageLibraryZoomViewDidSingleTap:(OAImageLibraryZoomView *)zoomView
{
    CGFloat alpha = self.topBar.alpha == 1 ? 0 : 1;
    [UIView animateWithDuration:0.15 animations:^{
        self.topBar.alpha = alpha;
        self.bottomBar.alpha = alpha;
    }];
}

- (void)touchUpInsideBackButton:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchUpInsideSelectButton:(UIButton *)button
{
    if (self.showIndex < self.listItems.count)
    {
        OAImageLibraryPreviewModel *model = self.listItems[self.showIndex];
        if (!model.selected && self.selectItems.count >= [OAImageLibrary sharedInstance].maxNumber)
        {
            NSString *message = [NSString stringWithFormat:@"最多只能选择%ld张图片", [OAImageLibrary sharedInstance].maxNumber];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        
        model.selected = !model.selected;
        if (model.selected)
        {
            if (![self.selectItems containsObject:model])
            {
                [self.selectItems addObject:model];
                [self.delegate imageLibraryPreviewViewController:self addAssetLocalIdentifier:model.asset.localIdentifier];
            }
        }
        else
        {
            if ([self.selectItems containsObject:model])
            {
                [self.selectItems removeObject:model];
                [self.delegate imageLibraryPreviewViewController:self removeAssetLocalIdentifier:model.asset.localIdentifier];
            }
        }
        [self updateSelectButtonStatus];
        [self updateBottomBarStatus];
    }
}

- (void)touchUpInsideFinishButton:(UIButton *)button
{
    [self.delegate imageLibraryPreviewViewControllerFinished:self];
}

- (void)updateBottomBarStatus
{
    BOOL enabled = self.selectItems.count > 0;
    self.finishButton.enabled = enabled;
    self.numberLabel.text = [NSString stringWithFormat:@"%ld", self.selectItems.count];
    if (enabled)
    {
        self.numberLabel.backgroundColor = [UIColor colorWithRed:0.53 green:0.81 blue:0.13 alpha:1];
    }
    else
    {
        self.numberLabel.backgroundColor = [UIColor colorWithRed:0.53 green:0.81 blue:0.13 alpha:0.5];
    }
}

- (void)updateSelectButtonStatus
{
    if (self.showIndex < self.listItems.count)
    {
        OAImageLibraryPreviewModel *model = self.listItems[self.showIndex];
        if (model.selected)
        {
            [self.selectButton setImage:[UIImage imageNamed:@"imageLibrary_selected"] forState:UIControlStateNormal];
        }
        else
        {
            [self.selectButton setImage:[UIImage imageNamed:@"imageLibrary_select"] forState:UIControlStateNormal];
        }
    }
}

@end
