//
//  FirstViewController.m
//  Bocchi
//
//  Created by Osamu Noguchi on 11/19/11.
//  Copyright (c) 2011 atrac613.io. All rights reserved.
//

#import "FirstViewController.h"
#import "UAirship.h"
#import "AuthViewController.h"

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
    [webView goBack];
    //[webView stringByEvaluatingJavaScriptFromString: @"iui.goBack();"];
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
        url = @"https://bocchi-hr.appspot.com/user/welcome";
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
    
	NSRange hostResult	= [url rangeOfString:@"bocchi.atrac613.io"];
    
    if ([schema isEqualToString:@"bocchi"] && hostResult.location != NSNotFound) {
        if ([url rangeOfString:@"user/auth"].location != NSNotFound) {
            NSLog(@"Auth action detected.");
            
            AuthViewController *authViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AuthView"];
            [self presentModalViewController:authViewController animated:YES];
            
            return NO;
        } else if ([url rangeOfString:@"store/tweet"].location != NSNotFound) {
            
            [self chargeMessageTweet];
            
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

- (void)chargeMessageTweet {
    if ([TWTweetComposeViewController canSendTweet]) {
        
        // Create an account store object.
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        
        // Create an account type that ensures Twitter accounts are retrieved.
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        // Request access from the user to use their Twitter accounts.
        [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
            if(granted) {
                // Get the list of Twitter accounts.
                NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
                
                // For the sake of brevity, we'll assume there is only one Twitter account present.
                // You would ideally ask the user which account they want to tweet from, if there is more than one Twitter account present.
                if ([accountsArray count] > 0) {
                    // Grab the initial Twitter account to tweet from.
                    ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                    
                    // Create a request, which in this example, posts a tweet to the user's timeline.
                    // This example uses version 1 of the Twitter API.
                    // This may need to be changed to whichever version is currently appropriate.
                    TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"https://api.twitter.com/1/statuses/update.json"] parameters:[NSDictionary dictionaryWithObject:NSLocalizedString(@"CHARGE_MESSAGE", @"") forKey:@"status"] requestMethod:TWRequestMethodPOST];
                    
                    // Set the account used to post the tweet.
                    [postRequest setAccount:twitterAccount];
                    
                    // Perform the request created above and create a handler block to handle the response.
                    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        //NSString *output = [NSString stringWithFormat:@"HTTP response status: %i", [urlResponse statusCode]];
                        NSString *output;
                        if ([urlResponse statusCode] == 200) {
                            output = NSLocalizedString(@"CHARGE_SUCCESS", @"");
                        } else {
                            output = NSLocalizedString(@"CHARGE_FAILED", @"");
                        }
                        
                        [self performSelectorOnMainThread:@selector(displayText:) withObject:output waitUntilDone:NO];
                    }];
                }
            }
        }];

    } else {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"CAN_NOT_SEND_TWITTER", @"") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] autorelease];
        [alert show];
    }
}

- (void)displayText:(NSString *)text {
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"" message:text delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] autorelease];
    [alert show];
}

@end
