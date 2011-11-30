//
//  PurchaseHandler.m
//  rplt
//
//  Created by Osamu Noguchi on 07/24/11.
//  Copyright 2011 RPLT. All rights reserved.
//

#import "PurchaseHandler.h"
#import "AppDelegate.h"

@implementation PurchaseHandler

@synthesize delegate;
@synthesize validProducts;
@synthesize pendingKey;

- (void)dealloc {
    self.delegate = nil;
    myRequest = nil;
    [super dealloc];
}

- (BOOL)canBeginPayment {
    if ([SKPaymentQueue canMakePayments]) {
        NSLog(@"ペアレンタルコントロールはオフ");
        return YES;
    } else {
        NSLog(@"ペアレンタルコントロールはオン");
        //[self alertWithMessage:@"設定アプリで購入に制限がかかっています"];
        return NO;
    }
}

- (void)requestProductData:(NSString *)productIdentifier {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSSet *identifiers = [NSSet setWithObject:productIdentifier];
    myRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:identifiers];
    myRequest.delegate = self;
    [myRequest start];
}

// プロダクト情報リクエストが終了した時にコールされる
- (void)productsRequest:(SKProductsRequest *)request 
     didReceiveResponse:(SKProductsResponse *)response
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSArray *products = response.products;
    NSArray *invalidProducts = response.invalidProductIdentifiers;
    
    NSLog(@"iTunes Storeに登録されていないプロダクト:%d:%@", [invalidProducts count], invalidProducts);
    NSLog(@"iTunes Storeに登録されているプロダクト:%d:%@", [products count], products);
    
    // App Storeに登録されていると認識されたプロダクトをさらにチェック
    for (SKProduct *product in products) {
        if (!product) {
            NSLog(@"正しいプロダクト情報がApp Storeより得られませんでした");
            return;
        }
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    appDelegate.isLoading = NO;
    
    validProducts = response.products;
    [self notifyDidReceiveProductResponse];
    [request release];
}

// プロダクト情報リクエストが終了した事を通知する
- (void)notifyDidReceiveProductResponse {
    
    NSDictionary *productInfo;
    productInfo = [NSDictionary dictionaryWithObject:validProducts 
                                              forKey:@"validProducts"];
    
    // NSNotificationを作成する
    NSNotification* notification;
    notification = [NSNotification notificationWithName:@"kProductRequestFinish" 
                                                 object:self 
                                               userInfo:productInfo];
    
    // NSNotificationCenterを取得する
    NSNotificationCenter* center;
    center = [NSNotificationCenter defaultCenter];
    
    // 通知を行う（通知先はRootViewController）
    [center postNotification:notification];
}

- (void)notifyDidReceivePendingKeyResponse {
    
    NSDictionary *productInfo;
    productInfo = [NSDictionary dictionaryWithObject:pendingKey 
                                              forKey:@"pendingKey"];
    
    // NSNotificationを作成する
    NSNotification* notification;
    notification = [NSNotification notificationWithName:@"kPendingKeyRequestFinish" 
                                                 object:self 
                                               userInfo:productInfo];
    
    // NSNotificationCenterを取得する
    NSNotificationCenter* center;
    center = [NSNotificationCenter defaultCenter];
    
    // 通知を行う（通知先はRootViewController）
    [center postNotification:notification];
}

// トランザクションオブザーバをペイメントキューに登録します。
- (void)initStoreKitObserver {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    UIApplication *application = [UIApplication sharedApplication];
    SEL sel = @selector(myApplicationWillTerminate:);
    id defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self 
                      selector:sel
                          name:UIApplicationWillTerminateNotification 
                        object:application];
}

// アプリケーション終了時に呼ばれます。
// オブザーバートランザクションオブザーバーを削除します。
-(void)myApplicationWillTerminate:(NSNotification*)notification
{
    NSLog(@"myApplicationWillTerminate");
    if ([[[SKPaymentQueue defaultQueue] transactions] count] > 0) {
        [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    } else {
        NSLog(@"トランザクションはキューに残っていない");
    }
}

- (void)addPayment:(SKProduct *)product {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    SKPayment *payment= [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    BOOL isFinished = YES;
    
    NSLog(@"updatedTransactions");
    NSLog(@"%d 件のキューが存在します。", [[[SKPaymentQueue defaultQueue] transactions] count]);
    
	for (SKPaymentTransaction *transaction in transactions) {
		switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"購入中です");
                break;
            case SKPaymentTransactionStatePurchased:
                NSLog(@"購入しました");
                isFinished = NO;
                [self completeTransaction:transaction];
                
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"購入が失敗しました。（キャンセル含む）");
                isFinished = NO;
                [self failedTransaction:transaction];
                
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"購入をリストアされました");
                isFinished = NO;
                [self restoreTransaction:transaction];
                
                break;
		}
	}
    if (isFinished == NO) {
        appDelegate.isLoading = NO;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

// オブザーバは、ユーザが正常にアイテムを購入したときにプロダクトを提供します。
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSString *receiptStr = [[[NSString alloc] initWithData:transaction.transactionReceipt encoding:NSUTF8StringEncoding] autorelease];
    
    NSLog(@"completeTransaction");
    NSLog(@"receiptStrLen: %d", [receiptStr length]);
    
    NSInvocationOperation *operation = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchronizeVerifyReceipt:) object:receiptStr] autorelease];
    [appDelegate.operationQueue addOperation:operation];
    
    NSLog(@"finishTransaction");
    // ペイメントキューからトランザクションを削除する
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"error: %d: %@", [transaction.error code], transaction.error.localizedDescription);
    
    switch ([transaction.error code]) {
        case SKErrorUnknown:
            //[self alertWithMessage:@"未知のエラーが発生しました"];
            NSLog(@"未知のエラーが発生しました");
            break;
        case SKErrorClientInvalid:
            //[self alertWithMessage:@"不正なクライアントです"];
            NSLog(@"不正なクライアントです");
            break;
        case SKErrorPaymentCancelled:
            //[self alertWithMessage:@"購入がキャンセルされました"];
            NSLog(@"購入がキャンセルされました");
            break;
        case SKErrorPaymentInvalid:
            //[self alertWithMessage:@"不正な購入です"];
            NSLog(@"不正な購入です");
            break;
        case SKErrorPaymentNotAllowed:
            //[self alertWithMessage:@"購入が許可されていません"];
            NSLog(@"購入が許可されていません");
            break;
        default:
            //[self alertWithMessage:transaction.error.localizedDescription];
            NSLog(@"Other: %@", transaction.error.localizedDescription);
            break;
    }

    NSLog(@"finishTransaction");
    // ペイメントキューからトランザクションを削除する
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}


// 消耗型、購読型プロダクトの場合、アプリ自身がイベントを起こす必要がある。
- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"finishTransaction");
    // ペイメントキューからトランザクションを削除する
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)synchronizeVerifyReceipt:(NSString*)receiptStr {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDictionary *result;
    @try {
        result = [appDelegate.bocchiService verifyReceipt:receiptStr debug:YES];
    } @catch (NSException *exception) {
        NSLog(@"Error: %@", [exception reason]);
    }
    
    [self performSelectorOnMainThread:@selector(completedVerifyReceiptOperation:) withObject:result waitUntilDone:NO];
}

- (void)completedVerifyReceiptOperation:(NSDictionary*)result {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([[result valueForKey:@"status"] intValue] == 1) {
        //[appDelegate showDialog:@"購入手続きを完了しました。ありがとうございました！"];
        pendingKey = [result valueForKey:@"key"];
        [self notifyDidReceivePendingKeyResponse];
    } else {
        [appDelegate showDialog:@"Purchase is failed."];
    }
}

@end
