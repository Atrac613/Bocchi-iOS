//
//  PendingView.m
//  kesikesi
//
//  Created by Osamu Noguchi on 11/05/07.
//  Copyright 2011 atrac613.io. All rights reserved.
//

#import "PendingView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PendingView

@synthesize pendingView;
@synthesize maskView;
@synthesize titleLabel;
@synthesize indicatorView;
@synthesize progressView;
@synthesize pendingViewEnabled;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //NSLog(@"Center: %f, %f", (self.frame.size.width/2), (self.frame.size.height/2));
        
        pendingView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 250)] autorelease];
        [pendingView setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2-30)];
        [self addSubview:pendingView];
        
        maskView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 250)] autorelease];
        [maskView setBackgroundColor:[UIColor blackColor]];
        [maskView setAlpha:0.0f];
        [maskView.layer setCornerRadius:20.f];
        [maskView setClipsToBounds:YES];
        [pendingView addSubview:maskView];
        
        indicatorView = [[UIActivityIndicatorView alloc] init];
        [indicatorView setFrame:CGRectMake(85,60,40,40)];
        [indicatorView setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2-45)];
        [indicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [indicatorView setHidesWhenStopped:YES];
        [indicatorView setAlpha:0.0f];
        [self addSubview:indicatorView];
        [indicatorView stopAnimating];
        
        progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(50, 160, 150, 10)];
        [progressView setProgress:0];
        [progressView setHidden:YES];
        [progressView setAlpha:0.5f];
        [pendingView addSubview:progressView];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 180, 250, 33)];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:27]];
        [titleLabel setTextAlignment:UITextAlignmentCenter];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setText:@"Now Loading..."];
        [pendingView addSubview:titleLabel];
        
        pendingView.transform = CGAffineTransformScale(pendingView.transform, 0.6, 0.6);
    }
    return self;
}

- (void)showPendingView {
    if (!pendingViewEnabled) {
        pendingViewEnabled = YES;
        
        [indicatorView startAnimating];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        [indicatorView setAlpha:1.f];
        
        [maskView setAlpha:0.5f];
        //pendingView.transform = CGAffineTransformScale(pendingView.transform, 0.6, 0.6);
        
        [UIView commitAnimations];
    }
}

- (void)hidePendingView {
    if (pendingViewEnabled) {
        pendingViewEnabled = NO;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        [indicatorView setAlpha:0.0f];
        [pendingView setAlpha:0.0f];
        //pendingView.transform = CGAffineTransformScale(pendingView.transform, 0.1, 0.1);
        
        [UIView commitAnimations];
        
        [indicatorView stopAnimating];
        
        [self performSelector:@selector(removePendingView) withObject:nil afterDelay:0.4];
    }
}

-(void)removePendingView {
    //NSLog(@"removePendingView");
    [indicatorView stopAnimating];
    [self removeFromSuperview];
}

- (void)dealloc
{
    [super dealloc];
    
    indicatorView = nil;
    titleLabel = nil;
    maskView = nil;
    pendingView = nil;
    
    [indicatorView release];
    [titleLabel release];
    [maskView release];
    [pendingView release];
}

@end
