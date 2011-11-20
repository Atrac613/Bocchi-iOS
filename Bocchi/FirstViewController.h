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
    
    PendingView *pendingView;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;

@property (nonatomic, retain) PendingView *pendingView;

- (void)showPendingView;
- (void)hidePendingView;

- (IBAction)backButtonPressed:(id)sender;

@end
