//
//  AuthViewController.h
//  Bocchi
//
//  Created by Osamu Noguchi on 11/26/11.
//  Copyright (c) 2011 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PendingView.h"

@interface AuthViewController : UIViewController <UIWebViewDelegate, UINavigationBarDelegate> {
    IBOutlet UINavigationBar *navigationBar;
    IBOutlet UINavigationItem *navigationItem;
    IBOutlet UIWebView *webView;
    
    PendingView *pendingView;
}

@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, retain) IBOutlet UINavigationItem *navigationItem;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) PendingView *pendingView;

- (void)showPendingView;
- (void)hidePendingView;

- (void)cancelButtonPressed:(id)sender;

@end
