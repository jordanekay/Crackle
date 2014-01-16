//
//  CKLAppDelegate.m
//  Crackle
//
//  Created by Jordan Kay on 12/17/13.
//  Copyright (c) 2013 Jordan Kay. All rights reserved.
//

#import "CKLAppDelegate.h"
#import "CKLCampfireAPI.h"
#import "CKLCampfireMessage.h"

#define CLIENT_ID @"YOUR_CLIENT_ID"
#define CLIENT_SECRET @"YOUR_CLIENT_SECRET"
#define REDIRECT_URI @"YOUR_REDIRECT_URI"

@implementation CKLAppDelegate
{
    UIWebView *_webView;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (![[[NSProcessInfo processInfo] environment] objectForKey:@"XCInjectBundle"]) {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.backgroundColor = [UIColor whiteColor];
        self.window.rootViewController = [UIViewController new];
        [self.window makeKeyAndVisible];

        [self _authorizeAccount];
    }

    return YES;
}

- (void)_authorizeAccount
{
    [CKLCampfireAPI setClientID:CLIENT_ID secret:CLIENT_SECRET redirectURI:REDIRECT_URI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didAuthorizeAccount:) name:CKLCampfireAPIDidAuthorizeAccountNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didAuthorizeAccounts:) name:CKLCampfireAPIDidAuthorizeAccountsNotification object:nil];

    CGRect frame = self.window.bounds;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    frame.origin.y += statusBarHeight;
    frame.size.height -= statusBarHeight;

    _webView = [[UIWebView alloc] initWithFrame:frame];
    [CKLCampfireAPI authorizeWithWebView:_webView];
    [self.window addSubview:_webView];
}

- (void)_didAuthorizeAccount:(NSNotification *)notification
{
    CKLCampfireAuthorizedAccount *account = (CKLCampfireAuthorizedAccount *)notification.object;
    
    [_webView removeFromSuperview];
    [self _makeAPICallsWithAccount:account];
}

- (void)_didAuthorizeAccounts:(NSNotification *)notification
{
    NSArray *accounts = notification.object;
    NSLog(@"Authorized %d accounts", [accounts count]);
    
    [_webView removeFromSuperview];
}

- (void)_makeAPICallsWithAccount:(CKLCampfireAuthorizedAccount *)account
{
    // Try out API calls here
}

@end
