//
//  FirstViewController.h
//  Bocchi
//
//  Created by Osamu Noguchi on 11/19/11.
//  Copyright (c) 2011 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "PendingView.h"
#import <StoreKit/StoreKit.h>

@interface FirstViewController : UIViewController <UIWebViewDelegate> {
    IBOutlet UIWebView *webView;
    
    PendingView *pendingView;
    
    SKProduct *currentProduct;
    BOOL clearedForSale;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) PendingView *pendingView;

@property (nonatomic, retain) SKProduct *currentProduct;
@property (nonatomic) BOOL clearedForSale;

- (void)showPendingView;
- (void)hidePendingView;

- (IBAction)backButtonPressed:(id)sender;

- (void)chargeMessageTweet;
- (void)displayText:(NSString *)text;

- (void)startObservation;
- (void)endObservation;

- (void)startPendingObservation;
- (void)endPendingObservation;

@end
