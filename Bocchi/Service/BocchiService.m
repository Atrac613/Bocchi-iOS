//
//  BocchiService.m
//  Bocchi
//
//  Created by Osamu Noguchi on 11/30/11.
//  Copyright (c) 2011 atrac613.io. All rights reserved.
//

#import "BocchiService.h"
#import "JSON.h"
#import "SBJSON.h"

@implementation BocchiService

-(id)verifyReceipt:(NSString *)receiptData debug:(BOOL)debug {
    id resultDictionary	= [[NSDictionary alloc] init];
    
    NSString *baseUrlString;
    if (TARGET_IPHONE_SIMULATOR) {
        baseUrlString = @"http://localhost:8092/store_api/verify_receipt";
    } else {
        baseUrlString = @"https://bocchi-hr.appspot.com/store_api/verify_receipt";
    }
    
    NSString *urlEscaped = [baseUrlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // create the URL
    NSURL *postURL = [NSURL URLWithString:urlEscaped];
    
    // create the connection
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:postURL
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:30.0];
    
    // change type to POST (default is GET)
    [postRequest setHTTPMethod:@"POST"];
    
    [postRequest setHTTPShouldHandleCookies:YES];
    
    // just some random text that will never occur in the body
    NSString *stringBoundary = @"0xKhTmLbOuNdArY---This_Is_ThE_BoUnDaRyy---pqo";
    
    // header value
    NSString *headerBoundary = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",
                                stringBoundary];
    
    // set header
    [postRequest addValue:headerBoundary forHTTPHeaderField:@"Content-Type"];
    
    // create data
    NSMutableData *postBody = [NSMutableData data];
    
    // status part
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"receipt_data\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[receiptData dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (debug) {
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"debug\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[[NSNumber numberWithInt:1] stringValue] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // final boundary
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // add body to post
    [postRequest setHTTPBody:postBody];
    
    NSError *error	= nil;
    NSURLResponse *response = nil;
    
    NSData *contentData = [NSURLConnection sendSynchronousRequest: postRequest returningResponse: &response error: &error];
    
    if (error) {
        NSException *exception = [NSException exceptionWithName:@"Exception" reason:NSLocalizedString(@"internet_error", @"") userInfo:nil];
        @throw exception;
    } else {
        NSString *jsonData	= [[NSString alloc] initWithData:contentData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", jsonData);
        id jsonTmpDic = [jsonData JSONValue];
        
        if ([jsonTmpDic isKindOfClass:[NSDictionary class]]) {
            resultDictionary = jsonTmpDic;
        }
        
        jsonTmpDic = nil;
        //[jsonTmpDic release];
    }
    
    contentData	= nil;
    //[contentData release];
    
    return resultDictionary;
}

-(NSString *)getJsonString:(NSString *)urlString {
	NSLog(@"urlString: %@", urlString);
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:urlString]];
	//[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
	[request setHTTPShouldHandleCookies:YES];
	[request setHTTPMethod:@"GET"];
    
	NSError *error	= nil;
	NSURLResponse *response = nil;
	
	NSData *contentData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NSString *jsonString;
	
	if (error) {
		NSLog(@"error: %@", [error localizedDescription]);
		NSException *exception = [NSException exceptionWithName:@"Exception" reason:[error localizedDescription] userInfo:nil];
		@throw exception;
	} else {
		jsonString	= [[NSString alloc] initWithData:contentData encoding:NSUTF8StringEncoding];
	}
	
    NSLog(@"jsonString: %@", jsonString);
    
	return jsonString;
}

@end
