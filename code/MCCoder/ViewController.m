//
//  ViewController.m
//  MCCoder
//
//  Created by McKee on 2017/8/2.
//  Copyright © 2017年 mckeelin. All rights reserved.
//

#import "ViewController.h"
#import "CoderHelper.h"


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)onTouchBrowse:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseFiles = NO;
    panel.canChooseDirectories = YES;
    NSWindow *window = [self.view window];
    [panel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
        if( result == NSFileHandlingPanelOKButton  )
        {
            NSArray *urls = [panel URLs];
            NSURL *url = [panel URL];
            NSLog(@"====\n%@==\n%@", urls, url);
            _txtView.string = [url.absoluteString stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        }
    }];
}

- (IBAction)onTouchEncode:(id)sender
{
    NSFileManager *fm =[NSFileManager defaultManager];
    NSString *path = _txtView.string;
    NSDirectoryEnumerator *enumerator = [fm enumeratorAtPath:path];
    NSString *subItem;
    while( subItem = [enumerator nextObject] ){
        [enumerator skipDescendents];
        if( [subItem isEqualToString:@"Caches"] ){
            continue;
        }
        NSRange range = [subItem rangeOfString:@"."];
        if( range.location == 0 )
        {
            continue;
        }
        NSString *file = [path stringByAppendingPathComponent:subItem];
        NSData *encodedData = [[CoderHelper helper] encodeData:[NSData dataWithContentsOfFile:file]];
        [encodedData writeToFile:file atomically:YES];
    }
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"encode finished";
    [alert addButtonWithTitle:@"OK"];
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        ;
    }];
}

- (IBAction)onTouchDecode:(id)sender
{
    NSFileManager *fm =[NSFileManager defaultManager];
    NSString *path = _txtView.string;
    NSDirectoryEnumerator *enumerator = [fm enumeratorAtPath:path];
    NSString *subItem;
    while( subItem = [enumerator nextObject] ){
        [enumerator skipDescendents];
        if( [subItem isEqualToString:@"Caches"] ){
            continue;
        }
        NSRange range = [subItem rangeOfString:@"."];
        if( range.location == 0 )
        {
            continue;
        }
        NSString *file = [path stringByAppendingPathComponent:subItem];
        NSData *encodedData = [[CoderHelper helper] decodeData:[NSData dataWithContentsOfFile:file]];
        [encodedData writeToFile:file atomically:YES];
    }
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"decode finished";
    [alert addButtonWithTitle:@"OK"];
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        ;
    }];
}

@end
