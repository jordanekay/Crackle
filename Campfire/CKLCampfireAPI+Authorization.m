//
//  CKLCampfireAPI+Authorization.m
//  Crackle
//
//  Created by Jordan Kay on 12/25/13.
//  Copyright (c) 2013 Jordan Kay. All rights reserved.
//

#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <Lockbox/Lockbox.h>
#import <objc/runtime.h>
#import <XMLDictionary/XMLDictionary.h>
#import "CKLCampfireAccount.h"
#import "CKLCampfireAPI.h"
#import "CKLCampfireAPI+Endpoints.h"
#import "CKLCampfireAPI+Private.h"
#import "NSString+CKLURLExtensions.h"

#define AUTHORIZATION_URL @"https://launchpad.37signals.com/authorization/"
#define QUERY_STRING @"type=web_server&client_id=%@&redirect_uri=%@"
#define ACCESS_TOKEN_QUERY_STRING @"client_secret=%@&code=%@"

#define REQUEST_TOKEN_PATH @"new"
#define ACCESS_TOKEN_PATH @"token"

static NSString *clientID;
static NSString *clientSecret;
static NSString *redirectURI;

NSString *CKLCampfireAPIAccessTokenKey = @"CKLCampfireAPIAccessTokenKey";
NSString *CKLCampfireAPIDidAuthorizeAccountNotification = @"CKLCampfireAPIDidAuthorizeAccountNotification";

@interface CKLCampfireToken () <MTLJSONSerializing, NSSecureCoding>

@property (nonatomic, copy) NSString *accessTokenString;
@property (nonatomic, copy) NSString *apiTokenString;
@property (nonatomic, copy) NSString *refreshToken;
@property (nonatomic) NSDate *expirationDate;

@end

@implementation CKLCampfireToken

+ (NSValueTransformer *)expirationDateJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^(NSString *secondsString) {
        NSTimeInterval seconds = [secondsString doubleValue];
        return [NSDate dateWithTimeInterval:seconds sinceDate:[NSDate date]];
    }];
}

#pragma mark - MTLJSONSerialization

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
        @"accessTokenString": @"access_token",
        @"refreshToken": @"refresh_token",
        @"expirationDate": @"expires_in"
    };
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

@end

@interface CKLCampfireAccount ()

@property (nonatomic, readonly) NSString *accessTokenKey;

@end

@implementation CKLCampfireAccount (Authorization)

- (CKLCampfireToken *)accessToken
{
    CKLCampfireToken *accessToken = objc_getAssociatedObject(self, @selector(accessToken));
    if (!accessToken) {
        accessToken = (CKLCampfireToken *)[Lockbox secureObjectForKey:self.accessTokenKey];
        objc_setAssociatedObject(self, @selector(accessToken), accessToken, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return accessToken;
}

- (void)setAccessToken:(CKLCampfireToken *)accessToken
{
    CKLCampfireToken *currentToken = objc_getAssociatedObject(self, @selector(accessToken));
    if (currentToken != accessToken) {
        [Lockbox setSecureObject:accessToken forKey:self.accessTokenKey];
        objc_setAssociatedObject(self, @selector(accessToken), accessToken, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (NSString *)accessTokenKey
{
    return [CKLCampfireAPIAccessTokenKey stringByAppendingString:self.accountID];
}

@end

@interface CKLCampfireAPI () <UIWebViewDelegate>

@end

@implementation CKLCampfireAPI (Authorization)

+ (NSURLRequest *)authorizeWithWebView:(UIWebView *)webView
{
    NSString *authURLFormat = [AUTHORIZATION_URL stringByAppendingFormat:@"%@?%@", REQUEST_TOKEN_PATH, QUERY_STRING];
    NSURL *authURL = [NSURL URLWithString:[NSString stringWithFormat:authURLFormat, clientID, redirectURI]];
    NSURLRequest *authRequest = [NSURLRequest requestWithURL:authURL];

    if (!webView.delegate) {
        webView.delegate = [self sharedInstance];
    }
    [webView loadRequest:authRequest];
    return authRequest;
}

+ (void)deauthorizeAccount:(CKLCampfireAuthorizedAccount *)account
{
    account.accessToken = nil;
}

+ (void)setClientID:(NSString *)id secret:(NSString *)secret redirectURI:(NSString *)uri
{
    clientID = [id copy];
    clientSecret = [secret copy];
    redirectURI = [uri copy];
}

- (void)_getAccessTokenWithVerificationCode:(NSString *)code
{
    NSString *accessTokenURLString = [AUTHORIZATION_URL stringByAppendingString:ACCESS_TOKEN_PATH];
    NSString *queryStringFormat = [NSString stringWithFormat:@"%@&%@", QUERY_STRING, ACCESS_TOKEN_QUERY_STRING];
    NSString *queryString = [NSString stringWithFormat:queryStringFormat, clientID, redirectURI, clientSecret, code];
    NSDictionary *parameters = [queryString ckl_queryParameters];

    [[AFHTTPRequestOperationManager manager] POST:accessTokenURLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        CKLCampfireToken *token = [MTLJSONAdapter modelOfClass:[CKLCampfireToken class] fromJSONDictionary:responseObject error:nil];
        [self _setupAccountWithToken:token];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Authorization failed: %@", error.localizedDescription);
    }];
}

- (void)_setupAccountWithToken:(CKLCampfireToken *)token
{
    NSString *authorizationPath = [[AUTHORIZATION_URL substringToIndex:[AUTHORIZATION_URL length] - 1] stringByAppendingString:@".xml"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (token.accessTokenString) {
        parameters[@"access_token"] = token.accessTokenString;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFXMLParserResponseSerializer new];
    [manager GET:authorizationPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *accounts = [CKLCampfireAuthorizedAccount accountsFromAuthorizationDictionary:[NSDictionary dictionaryWithXMLData:operation.responseData]];
        for (CKLCampfireAuthorizedAccount *account in accounts) {
            account.accessToken = token;
            [self _finishAuthorizationForAccount:account];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Authorization failed: %@", error.localizedDescription);
    }];
}

- (void)_finishAuthorizationForAccount:(CKLCampfireAuthorizedAccount *)account
{
    [[CKLCampfireAPI sharedInstance] getResource:CAMPFIRE_API_USERS_ME forAccount:account withParameters:nil responseBlock:^(id responseObject, NSError *error) {
        if (responseObject) {
            account.accessToken.apiTokenString = responseObject[@"api-auth-token"];
            [[NSNotificationCenter defaultCenter] postNotificationName:CKLCampfireAPIDidAuthorizeAccountNotification object:account];
        }
    }];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL shouldStartLoad = YES;
    NSArray *parameters = [[[request URL] query] componentsSeparatedByString:@"="];

    if ([request.URL.absoluteString rangeOfString:@"(null)"].location != NSNotFound) {
        shouldStartLoad = NO;
    } else if ([parameters count] == 2 && [parameters[0] isEqualToString:@"code"]) {
        NSString *code = parameters[1];
        [self _getAccessTokenWithVerificationCode:code];
        shouldStartLoad = NO;
    }

    return shouldStartLoad;
}

@end
