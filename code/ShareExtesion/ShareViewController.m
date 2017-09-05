//
//  ShareViewController.m
//  ShareExtesion
//
//  Created by McKee on 2017/4/5.
//  Copyright © 2017年 mckeelin. All rights reserved.
//

#import "ShareViewController.h"
#import "dataHelper.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ShareViewController ()
{
    UIWebView *_web;
    NSOperationQueue *_queue;
}

@end

@implementation ShareViewController

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    if( !_queue )
    {
        _queue = [[NSOperationQueue alloc] init];
    }
    if( self.extensionContext.inputItems.count > 0 )
    {
        for( NSExtensionItem *item in self.extensionContext.inputItems )
        {
            NSLog(@"==>count:%ld\n%@", item.attachments.count, item);
            for( NSItemProvider *provider in item.attachments )
            {
                NSString *type;
                if ([provider hasItemConformingToTypeIdentifier:(NSString*)kUTTypeURL])
                {
                    type = (NSString*)kUTTypeURL;
                }
                else if( [provider hasItemConformingToTypeIdentifier:(NSString*)kUTTypeJPEG] )
                {
                    type = (NSString*)kUTTypeJPEG;
                }
                else if( [provider hasItemConformingToTypeIdentifier:(NSString*)kUTTypeJPEG2000] )
                {
                    type = (NSString*)kUTTypeJPEG2000;
                }
                else if( [provider hasItemConformingToTypeIdentifier:(NSString*)kUTTypeGIF] )
                {
                    type = (NSString*)kUTTypeGIF;
                }
                else if( [provider hasItemConformingToTypeIdentifier:(NSString*)kUTTypePNG] )
                {
                    type = (NSString*)kUTTypePNG;
                }
                else if( [provider hasItemConformingToTypeIdentifier:(NSString*)kUTTypeQuickTimeImage] )
                {
                    type = (NSString*)kUTTypeQuickTimeImage;
                }
                else if( [provider hasItemConformingToTypeIdentifier:(NSString*)kUTTypeBMP] )
                {
                    type = (NSString*)kUTTypeBMP;
                }
                else if( [provider hasItemConformingToTypeIdentifier:(NSString*)kUTTypeICO] )
                {
                    type = (NSString*)kUTTypeICO;
                }
                else if( [provider hasItemConformingToTypeIdentifier:(NSString*)kUTTypeLivePhoto] )
                {
                    type = (NSString*)kUTTypeLivePhoto;
                }
                else if( [provider hasItemConformingToTypeIdentifier:(NSString*)kUTTypeAudiovisualContent] )
                {
                    type = (NSString*)kUTTypeAudiovisualContent;
                }
                else if( [provider hasItemConformingToTypeIdentifier:(NSString*)kUTTypeImage] )
                {
                    type = (NSString*)kUTTypeImage;
                }
                
                if( type )
                {
                    [provider loadItemForTypeIdentifier:type
                                                options:nil
                                      completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                                          
                                          if ([(NSObject *)item isKindOfClass:[NSURL class]])
                                          {
                                              NSLog(@"分享的URL = %@", item);
                                              NSURL *url = (NSURL*)item;
                                              dataHelper *helper = [dataHelper helper];
                                              [helper saveShareFile:url];
                                          }
                                          else
                                          {
                                              NSLog(@"分享的 [obj] = %@", item);
                                          }
                                          if( error )
                                          {
                                              NSLog(@"***error:\n%@", error);
                                          }
                                      }];
                }
                else
                {
                    NSLog(@"====> unknown provider:\n%@", provider);
                }
            }
        }
    }
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

@end
