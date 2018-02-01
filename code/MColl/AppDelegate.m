//
//  AppDelegate.m
//  MColl
//
//  Copyright (c) 2015年 mckeelin. All rights reserved.
//

#import "AppDelegate.h"
#import "icloudHelper.h"
#import "dataHelper.h"
#import "BlurCoverView.h"
#import "TouchIDLoginVC.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "collectionVC.h"
#import "UIImage+ImageEffects.h"
#import "GroupsVC.h"

@interface AppDelegate ()
{
    NSDate *_lastTime;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //[[icloudHelper helper] queryGroups];
    
    [[NSUserDefaults standardUserDefaults] setFloat:[NSDate date].timeIntervalSince1970  forKey:@"TouchIDPassTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    LAContext *ctx = [[LAContext alloc] init];
    NSError *error;
    BOOL touchIDEnable = [ctx canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    if( touchIDEnable )
    {
        TouchIDLoginVC *vc = [[TouchIDLoginVC alloc] init];
        _window.rootViewController = vc;
    }
    else
    {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[GroupsVC fromXib]];
        _window.rootViewController = nav;
    }
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage fromColor:[UIColor whiteColor]] forBarMetrics:0];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    
    BlurCoverView *view = [[BlurCoverView alloc] initWithFrame:self.window.frame];
    view.tag = 1001;
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        if (window.windowLevel == UIWindowLevelNormal)
        {
            [window addSubview:view];
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[dataHelper helper] reloadGroups];
    
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        for(UIView *view in [window subviews])
        {
            if([view isKindOfClass:[BlurCoverView class]])
            {
                [view removeFromSuperview];
            }
        }
    }
    
    LAContext *ctx = [[LAContext alloc] init];
    NSError *error;
    BOOL touchIDEnable = [ctx canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    if( touchIDEnable )
    {
        NSDate *currentTime = [NSDate date];
        NSTimeInterval lastPassTime = [[NSUserDefaults standardUserDefaults] floatForKey:@"TouchIDPassTime"];
        CGFloat diff = currentTime.timeIntervalSince1970 - lastPassTime;
        if( diff >= 60 )
        {
            TouchIDLoginVC *vc = [[TouchIDLoginVC alloc] init];
            [_window.rootViewController presentViewController:vc animated:YES completion:nil];;
        }
    }
    
    if( [_window.rootViewController isKindOfClass:[UINavigationController class]] )
    {
        UINavigationController *nav = (UINavigationController*)_window.rootViewController;
        if( [nav.topViewController isKindOfClass:[collectionVC class]] )
        {
            collectionVC *collVC = (collectionVC*)nav.topViewController;
            [collVC reload];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"tips" message:url.absoluteString delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [av show];
    if( [url isFileURL] )
    {
        NSArray *groups = [dataHelper helper].groups;
        if( groups.count > 0 )
        {
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"请选择分组" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            for( groupObject *group in groups )
            {
                UIAlertAction *action = [UIAlertAction actionWithTitle:group.title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[dataHelper helper] saveCaputreData:data toGroup:group];
                }];
                [ac addAction:action];
            }
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                ;
            }];
            [ac addAction:cancel];
            UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
            [vc presentViewController:ac animated:YES completion:nil];
        }
    }
    return YES;
}

@end
