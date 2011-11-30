//
//  BocchiService.h
//  Bocchi
//
//  Created by Osamu Noguchi on 11/30/11.
//  Copyright (c) 2011 atrac613.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BocchiService : NSObject {
    
}

- (id)verifyReceipt:(NSString *)receiptData debug:(BOOL)debug;

- (NSString *)getJsonString:(NSString *)urlString;

@end
