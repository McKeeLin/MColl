//
//  TouchIDLoginVC.m
//  WorkLoad
//
//  Created by McKee on 2017/8/11.
//  Copyright © 2017年 OA. All rights reserved.
//

#import "TouchIDLoginVC.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "collectionVC.h"
#import "GroupsVC.h"

@interface TouchIDLoginVC ()
{
    IBOutlet UIImageView *_portraitIV;
    LAContext *_touchIDContext;
}
@end

@implementation TouchIDLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _portraitIV.layer.cornerRadius = 50;
    _portraitIV.layer.masksToBounds = YES;
    _portraitIV.layer.borderColor = [UIColor colorWithRed:28.0/255.0 green:166.0/255.0 blue:165.0/255.0 alpha:1.0].CGColor;
    _portraitIV.layer.borderWidth = 1;
    [self doAuthenticate];
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

- (void)doAuthenticate
{
    if( !_touchIDContext )
    {
        _touchIDContext = [[LAContext alloc] init];
    }
    
    _touchIDContext.localizedFallbackTitle = @"";
    [_touchIDContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:NSLocalizedString(@"请将手指置于home键上进行识别", nil) reply:
     ^(BOOL success, NSError *authenticationError) {
         if (success) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 UIWindow *window = [UIApplication sharedApplication].delegate.window;
                 if( window.rootViewController == self )
                 {
                     UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[GroupsVC fromXib]];
                     window.rootViewController = nav;
                 }
                 else
                 {
                     [self dismissViewControllerAnimated:YES completion:nil];
                 }
                 [[NSUserDefaults standardUserDefaults] setFloat:[NSDate date].timeIntervalSince1970  forKey:@"TouchIDPassTime"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
             });
         }else {
         }
         _touchIDContext = nil;
     }];
}

- (IBAction)onTouchIDButton:(id)sender
{
    [self doAuthenticate];
}


@end
