//
//  FirstViewController.h
//  Bocchi
//
//  Created by 修 野口 on 11/19/11.
//  Copyright (c) 2011 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstViewController : UIViewController {
    IBOutlet UIWebView *webView;
    IBOutlet UIBarButtonItem *backButton;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;

@end
