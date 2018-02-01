//
//  captureVC.m
//  MColl
//
//

#import "captureVC.h"
#import "captureView.h"
#import "dataHelper.h"
#import "collectionVC.h"
#import "icloudHelper.h"
#import "CoderHelper.h"
#import "GroupVC.h"

@interface captureVC ()<CAAnimationDelegate>
{
    captureView *_frontCaptureView;
    captureView *_backCaptureView;
    captureView *_currentCaptureView;
    UIToolbar *_toolbar;
    CATransition *_transition;
}

@end

@implementation captureVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if( self ){
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        _frontCaptureView = [[captureView alloc] initWithFrame:CGRectZero frontCamera:YES];
        [self.baseContainerView addSubview:_frontCaptureView];
        
        _backCaptureView = [[captureView alloc] initWithFrame:CGRectZero frontCamera:NO];
        [self.baseContainerView addSubview:_backCaptureView];
        _currentCaptureView = _backCaptureView;
        
        UIBarButtonItem *switchItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"切换", nil) style:UIBarButtonItemStylePlain target:self action:@selector(onTouchSwitch:)];
        UIBarButtonItem *flexibleItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *captureItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"拍照", nil) style:UIBarButtonItemStylePlain target:self action:@selector(onTouchCapture:)];
        UIBarButtonItem *flexibleItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"退出", nil) style:UIBarButtonItemStylePlain target:self action:@selector(onTouchClose:)];
        _toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
        _toolbar.backgroundColor = [UIColor clearColor];
        _toolbar.items = [NSArray arrayWithObjects:switchItem, flexibleItem1, captureItem, flexibleItem2, closeItem, nil];
        [self.baseContainerView addSubview:_toolbar];
        
        _transition = [[CATransition alloc] init];
        _transition.duration = 0.7;
        _transition.type = @"cube";
        _transition.timingFunction = UIViewAnimationCurveEaseInOut;
        _transition.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCaptureFinished:) name:NN_CAPTURE_FINISH object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _frontCaptureView.frame = self.baseContainerView.bounds;
    _backCaptureView.frame = self.baseContainerView.bounds;
    CGFloat toolbarHeight = 58;
    _toolbar.frame = CGRectMake(0, self.baseContainerView.frame.size.height - toolbarHeight, self.baseContainerView.frame.size.width, toolbarHeight);
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [_currentCaptureView start];
}


- (void)setGroup:(groupObject *)group
{
    _group = group;
    _frontCaptureView.group = group;
    _backCaptureView.group = group;
}

- (void)onCaptureFinished:(NSNotification*)notification
{
    if( _currentCaptureView.imageData ){
        [_collVC onCaptureFinish];
        [_groupVC onCaptureFinished];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)onTouchSwitch:(id)sender
{
    [self.baseContainerView.layer addAnimation:_transition forKey:@"animation"];
}

- (void)onTouchCapture:(id)sender
{
    _currentCaptureView.group = _group;
    _currentCaptureView.capVC = self;
    [_currentCaptureView caputre];
}

- (void)onTouchClose:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^(){
    }];
}

- (void)animationDidStart:(CAAnimation *)anim
{
    [_currentCaptureView stop];
    NSInteger frontIndex = [self.baseContainerView.subviews indexOfObject:_frontCaptureView];
    NSInteger backIndex = [self.baseContainerView.subviews indexOfObject:_backCaptureView];
    if( _currentCaptureView == _frontCaptureView ){
        [self.baseContainerView exchangeSubviewAtIndex:frontIndex withSubviewAtIndex:backIndex];
        _currentCaptureView = _backCaptureView;
        _transition.subtype = @"fromLeft";
    }
    else{
        [self.baseContainerView exchangeSubviewAtIndex:backIndex withSubviewAtIndex:frontIndex];
        _currentCaptureView = _frontCaptureView;
        _transition.subtype = @"fromRight";
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flagD
{
    [_currentCaptureView start];
}

@end
