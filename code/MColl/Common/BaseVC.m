//
//  BaseVC.m
//  WorkLoad
//
//  Created by McKee on 15/10/9.
//  Copyright © 2015年 OA. All rights reserved.
//

#import "BaseVC.h"

@interface BaseVC ()

@end

@implementation BaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if( _hideBackItem ){
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] initWithFrame:CGRectZero]];
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(onTouchBack:)];
    self.view.backgroundColor = [UIColor whiteColor];
    
    if( [self respondsToSelector:@selector(edgesForExtendedLayout)] )
    {
        //self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (UIStatusBarStyle)preferredStatusBarStyle
{
    if( [UIDevice currentDevice].systemVersion.floatValue >= 7.0 )
    {
        return UIStatusBarStyleLightContent;
    }
    else
    {
        return UIStatusBarStyleDefault;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
}

- (void)onTouchBack:(id)sender
{
    if( ![self.navigationController popViewControllerAnimated:YES] )
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
