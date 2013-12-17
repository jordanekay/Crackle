//
//  CKLSpecHelpers.m
//  Crackle
//
//  Created by Jordan Kay on 1/2/14.
//  Copyright (c) 2014 Jordan Kay. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OHHTTPStubs/OHHTTPStubsResponse+JSON.h>
#import "CKLCampfireAPI.h"
#import "CKLCampfireAPI+Endpoints.h"
#import "CKLCampfireAccount.h"
#import "CKLSpecHelpers.h"

#define CLIENT_ID @"0123456789abcdef0123456789abcdef01234567"
#define CLIENT_SECRET @"fedcba9876543210fedcba9876543210fedcba98"
#define REDIRECT_URI @"https://www.yourco.com/auth"

static CKLCampfireAuthorizedAccount *account;

@interface CKLSpecHelpers ()

@property (nonatomic) UIWebView *webView;

@end

@implementation CKLSpecHelpers

+ (void)setUp
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(verifyAccount:) name:CKLCampfireAPIDidAuthorizeAccountNotification object:nil];
}

+ (void)tearDown
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)setAPICredentials
{
    [CKLCampfireAPI setClientID:CLIENT_ID secret:CLIENT_SECRET redirectURI:REDIRECT_URI];
}

+ (void)clearAPICredentials
{
    [CKLCampfireAPI setClientID:nil secret:nil redirectURI:nil];
}

+ (BOOL)shouldStartLoadWithWebView:(UIWebView *)webView
{
    NSURLRequest *request = [CKLCampfireAPI authorizeWithWebView:webView];
    return [webView.delegate webView:webView shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeOther];
}

+ (void)verifyAccount:(NSNotification *)notification
{
    return;
}

+ (NSDictionary *)accountProperties
{
    return @{
        @"accountID": @"1",
        @"organizationURL": [NSURL URLWithString:@"https://yourco.campfirenow.com"]
    };
}

+ (void)stub:(NSString *)path
{
    NSString *fileName = [path stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    [self stub:path andReturn:fileName];
}

+ (void)stub:(NSString *)path andReturn:(NSString *)fileName
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.path isEqualToString:[NSString stringWithFormat:@"/%@", path]];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return (fileName) ? [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(fileName, nil) statusCode:200 headers:@{@"Content-Type": @"application/xml"}] : [OHHTTPStubsResponse responseWithJSONObject:@{} statusCode:200 headers:nil];
    }];
}

+ (void)stubWithNetworkFailure:(NSString *)path
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.path isEqualToString:[NSString stringWithFormat:@"/%@", path]];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain code:kCFURLErrorNotConnectedToInternet userInfo:nil]];
    }];
}

@end
