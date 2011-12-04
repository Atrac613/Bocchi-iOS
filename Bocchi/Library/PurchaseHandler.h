//
//  PurchaseHandler.h
//  rplt
//
//  Created by Osamu Noguchi on 07/24/11.
//  Copyright 2011 RPLT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol PurchaseHandlerDelegate <NSObject>
- (void)purchaseHandlerDidGetNewProducts:(NSArray *)newProducts;
- (void)purchaseHandlerDidCompletePurchase:(NSData *)content;
- (void)purchaseHandlerDidCancelPurchase:(NSString *)productID;
@end

@interface PurchaseHandler : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    __unsafe_unretained id <PurchaseHandlerDelegate> delegate;
    SKProductsRequest *myRequest;
    NSArray *validProducts;
    NSString *pendingKey;
}

@property (nonatomic, assign) id <PurchaseHandlerDelegate> delegate;
@property (nonatomic, retain) NSArray *validProducts;
@property (nonatomic, retain) NSString *pendingKey;

- (void)initStoreKitObserver;
- (BOOL)canBeginPayment;
- (void)requestProductData:(NSString *)productIdentifier;
- (void)addPayment:(SKProduct *)product;

- (void)notifyDidReceiveProductResponse;
- (void)notifyDidReceivePendingKeyResponse;

- (void)completeTransaction:(SKPaymentTransaction *)transaction;
- (void)failedTransaction:(SKPaymentTransaction *)transaction;
- (void)restoreTransaction:(SKPaymentTransaction *)transaction;

@end
