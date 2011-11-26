//
//  AppDelegate.m
//  Bocchi
//
//  Created by Osamu Noguchi on 11/19/11.
//  Copyright (c) 2011 atrac613.io. All rights reserved.
//

#import "AppDelegate.h"
#import "UAirship.h"
#import "UAPush.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    //Init Airship launch options
    NSMutableDictionary *takeOffOptions = [[[NSMutableDictionary alloc] init] autorelease];
    [takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
    
    // Create Airship singleton that's used to talk to Urban Airhship servers.
    // Please populate AirshipConfig.plist with your info from http://go.urbanairship.com
    [UAirship takeOff:takeOffOptions];
    
    [[UAPush shared] resetBadge];//zero badge on startup
    
    [[UAPush shared] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeSound |
                                                         UIRemoteNotificationTypeAlert)];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    UALOG(@"Application did become active.");
    [[UAPush shared] resetBadge]; //zero badge when resuming from background (iOS 4+)
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    UALOG(@"APN device token: %@", deviceToken);
    // Updates the device token and registers the token with UA
    [[UAPush shared] registerDeviceToken:deviceToken];
    
    
    /*
     * Some example cases where user notifcation may be warranted
     *
     * This code will alert users who try to enable notifications
     * from the settings screen, but cannot do so because
     * notications are disabled in some capacity through the settings
     * app.
     * 
     */
    
    /*
     
     //Do something when notifications are disabled altogther
     if ([application enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone) {
     UALOG(@"iOS Registered a device token, but nothing is enabled!");
     
     //only alert if this is the first registration, or if push has just been
     //re-enabled
     if ([UAirship shared].deviceToken != nil) { //already been set this session
     NSString* okStr = @"OK";
     NSString* errorMessage =
     @"Unable to turn on notifications. Use the \"Settings\" app to enable notifications.";
     NSString *errorTitle = @"Error";
     UIAlertView *someError = [[UIAlertView alloc] initWithTitle:errorTitle
     message:errorMessage
     delegate:nil
     cancelButtonTitle:okStr
     otherButtonTitles:nil];
     
     [someError show];
     [someError release];
     }
     
     //Do something when some notification types are disabled
     } else if ([application enabledRemoteNotificationTypes] != [UAPush shared].notificationTypes) {
     
     UALOG(@"Failed to register a device token with the requested services. Your notifications may be turned off.");
     
     //only alert if this is the first registration, or if push has just been
     //re-enabled
     if ([UAirship shared].deviceToken != nil) { //already been set this session
     
     UIRemoteNotificationType disabledTypes = [application enabledRemoteNotificationTypes] ^ [UAPush shared].notificationTypes;
     
     
     
     NSString* okStr = @"OK";
     NSString* errorMessage = [NSString stringWithFormat:@"Unable to turn on %@. Use the \"Settings\" app to enable these notifications.", [UAPush pushTypeString:disabledTypes]];
     NSString *errorTitle = @"Error";
     UIAlertView *someError = [[UIAlertView alloc] initWithTitle:errorTitle
     message:errorMessage
     delegate:nil
     cancelButtonTitle:okStr
     otherButtonTitles:nil];
     
     [someError show];
     [someError release];
     }
     }
     
     */
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
    UALOG(@"Failed To Register For Remote Notifications With Error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    UALOG(@"Received remote notification: %@", userInfo);
    
    // Get application state for iOS4.x+ devices, otherwise assume active
    UIApplicationState appState = UIApplicationStateActive;
    if ([application respondsToSelector:@selector(applicationState)]) {
        appState = application.applicationState;
    }
    
    [[UAPush shared] handleNotification:userInfo applicationState:appState];
    [[UAPush shared] resetBadge]; // zero badge after push received
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
