//
//  CKLSpecHelpers.h
//  Crackle
//
//  Created by Jordan Kay on 1/2/14.
//  Copyright (c) 2014 Jordan Kay. All rights reserved.
//

@class CKLCampfireAuthorizedAccount;

@interface CKLSpecHelpers : NSObject

+ (void)setUp;
+ (void)tearDown;

+ (void)setAPICredentials;
+ (void)clearAPICredentials;

+ (BOOL)shouldStartLoadWithWebView:(UIWebView *)webView;
+ (void)verifyAccount:(NSNotification *)notification;
+ (NSDictionary *)accountProperties;

+ (void)stub:(NSString *)path;
+ (void)stub:(NSString *)path andReturn:(NSString *)fileName;
+ (void)stubWithNetworkFailure:(NSString *)path;

@end
