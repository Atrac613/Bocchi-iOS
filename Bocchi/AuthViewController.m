//
//  AuthViewController.m
//  Bocchi
//
//  Created by Osamu Noguchi on 11/26/11.
//  Copyright (c) 2011 atrac613.io. All rights reserved.
//

#import "AuthViewController.h"
#import "UAirship.h"

@implementation AuthViewController

@synthesize navigationBar;
@synthesize navigationItem;
@synthesize webView;
@synthesize pendingView;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:NSLocalizedString(@"AUTHENTICATION", @"")];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)]];
}

- (void)cancelButtonPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    webView.delegate = self;
    
    NSString *url;
    
    if (TARGET_IPHONE_SIMULATOR) {
        url = @"http://localhost:8092/user/auth";
    } else {
        url = @"https://bocchi-hr.appspot.com/user/auth";
    }
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
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
    
	NSRange hostResult	= [url rangeOfString:@"bocchi.atrac613.io"];
    
    if ([schema isEqualToString:@"bocchi"] && hostResult.location != NSNotFound) {
        if ([url rangeOfString:@"update/device_token"].location != NSNotFound) {
            NSLog(@"Update device_token action detected.");
            
            [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setDeviceToken('%@')", [UAirship shared].deviceToken]];
            NSLog(@"token %@", [UAirship shared].deviceToken);
            
            return NO;
        } else if ([url rangeOfString:@"user/auth/success"].location != NSNotFound) {
            NSLog(@"Auth Success action detected.");
            
            [self dismissModalViewControllerAnimated:YES];
            
            return NO;
        } else if ([url rangeOfString:@"user/auth/fail"].location != NSNotFound) {
            NSLog(@"Auth Fail action detected.");
            
            [self dismissModalViewControllerAnimated:YES];
            
            return NO;
        } else if ([url rangeOfString:@"alert/saved"].location != NSNotFound) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Saved" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
