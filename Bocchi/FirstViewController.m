//
//  FirstViewController.m
//  Bocchi
//
//  Created by 修 野口 on 11/19/11.
//  Copyright (c) 2011 atrac613.io. All rights reserved.
//

#import "FirstViewController.h"
#import "UAirship.h"

@implementation FirstViewController

@synthesize webView;

@synthesize pendingView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [webView setBackgroundColor:[UIColor clearColor]];
    [webView setOpaque:NO];
}

- (IBAction)backButtonPressed:(id)sender {
    [webView stringByEvaluatingJavaScriptFromString: @"iui.goBack();"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    webView.delegate = self;
    
    NSString *url;
    
    if (TARGET_IPHONE_SIMULATOR) {
        url = @"http://localhost:8092/user/welcome";
    } else {
        url = @"http://bocchi-hr.appspot.com/user/welcome";
    }
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return NO;
}

- (void)webViewDidStartLoad:(UIWebView *)wv {
    [self showPendingView];
	
	//self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)wv {	
    [self hidePendingView];
	
	//self.navigationItem.rightBarButtonItem.enabled = YES;	
}

- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSURL *baseUrl = [request URL];
	NSString *url = [baseUrl absoluteString];
	NSString *schema = [baseUrl scheme];
	NSString *path = [baseUrl path];
	
	NSLog(@"path: %@", [path substringFromIndex:1]);
    
    // workaround.
    if ([url rangeOfString:@"google.com"].location != NSNotFound) {
        [webView setBackgroundColor:[UIColor whiteColor]];
        [webView setOpaque:YES];
    } else {
        [webView setBackgroundColor:[UIColor clearColor]];
        [webView setOpaque:NO];
    }
    
	NSRange hostResult	= [url rangeOfString:@"bocchi.atrac613.io"];
    
    if ([schema isEqualToString:@"bocc"] && hostResult.location != NSNotFound) {
        if ([url rangeOfString:@"update/device_token"].location != NSNotFound) {
            NSLog(@"Update device_token action detected.");
            
            [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setDeviceToken('%@')", [UAirship shared].deviceToken]];
            NSLog(@"token %@", [UAirship shared].deviceToken);
            return NO;
        } else if ([url rangeOfString:@"alert/saved"].location != NSNotFound) {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"" message:@"Saved" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] autorelease];
            [alert show];
            
            return NO;
        }
    }
    
    return YES;
}

- (void)showPendingView {
    if (pendingView == nil && ![self.view.subviews containsObject:pendingView]) {
        pendingView = [[PendingView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 40)];
        pendingView.titleLabel.text = @"Please wait...";
        pendingView.userInteractionEnabled = NO;
        [self.view addSubview:pendingView];
    }
    
    [pendingView showPendingView];
}

- (void)hidePendingView {
    if ([self.view.subviews containsObject:pendingView]) {
        [pendingView hidePendingView];
        
        pendingView = nil;
    }
}

@end
