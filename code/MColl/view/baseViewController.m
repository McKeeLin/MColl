//
//  baseViewController.m
//  OA
//
//

#import "baseViewController.h"

@interface baseViewController ()
{
    ;
}

@end

@implementation baseViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if( self ){
        [self initBaseContainerView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self  = [super initWithCoder:aDecoder];
    if( self ){
        [self initBaseContainerView];
    }
    return self;
}


- (void)initBaseContainerView
{
    if( !self.baseContainerView ){
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
        self.baseContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        self.baseContainerView.backgroundColor = [UIColor clearColor];
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.baseContainerView];
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
    self.baseContainerView.frame = self.view.bounds;
}




@end
