//
//  AppDelegate.h
//  Bocchi
//
//  Created by Osamu Noguchi on 11/19/11.
//  Copyright (c) 2011 atrac613.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PurchaseHandler.h"
#import "BocchiService.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    BocchiService *bocchiService;
    NSOperationQueue *operationQueue;
    PurchaseHandler *purchaseHandler;
    BOOL isLoading;
}

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) BocchiService *bocchiService;
@property (retain) PurchaseHandler *purchaseHandler;
@property (nonatomic, retain) NSOperationQueue *operationQueue;
@property (nonatomic) BOOL isLoading;

- (void)showDialog:(NSString *)msg;

@end
