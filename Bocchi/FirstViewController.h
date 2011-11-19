//
//  FirstViewController.h
//  Bocchi
//
//  Created by 修 野口 on 11/19/11.
//  Copyright (c) 2011 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PendingView.h"

@interface FirstViewController : UIViewController <UIWebViewDelegate> {
    IBOutlet UIWebView *webView;
    IBOutlet UIBarButtonItem *backButton;
    
    PendingView *pendingView;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;

@property (nonatomic, retain) PendingView *pendingView;

- (void)showPendingView;
- (void)hidePendingView;

@end
