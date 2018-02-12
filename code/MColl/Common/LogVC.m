//
//  LogVC.m
//  WorkLoad
//
//  Created by McKee on 2017/8/16.
//  Copyright © 2017年 OA. All rights reserved.
//

#import "LogVC.h"
#import "LogHelper.h"

@interface LogVC ()
{
    IBOutlet UITextView *_textView;
}
@end

@implementation LogVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"日志";
    _textView.text = [[LogHelper helper] contents];
    _textView.editable = NO;
    if(_textView.text.length > 0 ) {
        NSRange bottom = NSMakeRange(_textView.text.length -1, 1);
        [_textView scrollRangeToVisible:bottom];
    }
    
    UIBarButtonItem *clear = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStylePlain target:self action:@selector(clear)];
    self.navigationItem.rightBarButtonItem = clear;
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

- (void)clear
{
    [[LogHelper helper] clear];
    _textView.text = @"";
}

@end
