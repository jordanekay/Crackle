//
//  CKLAuthorizationSpec.m
//  Crackle
//
//  Created by Jordan Kay on 1/2/14.
//  Copyright (c) 2014 Jordan Kay. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "CKLCampfireAPI.h"
#import "CKLCampfireAPI+Endpoints.h"
#import "CKLCampfireAccount.h"
#import "CKLSpecHelpers.h"

#define AUTHORIZATION_TIMEOUT 3

@interface CKLCampfireAPI ()

- (void)_getAccessTokenWithVerificationCode:(NSString *)code;

@end

SPEC_BEGIN(CKLAuthorizationSpec)

describe(@"The API instance", ^{
    __block UIWebView *webView;
    beforeAll(^{
        [CKLSpecHelpers setUp];
        webView = [[UIWebView alloc] init];
    });
    afterAll(^{
        [CKLSpecHelpers tearDown];
    });
    context(@"before setting credentials", ^{
        it(@"should fail to load the login authorization request", ^{
            BOOL shouldStartLoad = [CKLSpecHelpers shouldStartLoadWithWebView:webView];
            [[theValue(shouldStartLoad) should] equal:theValue(NO)];
        });
    });
    context(@"after setting credentials", ^{
        beforeEach(^{
            [CKLSpecHelpers setAPICredentials];
        });
        it(@"should load the login authorization request", ^{
            BOOL shouldStartLoad = [CKLSpecHelpers shouldStartLoadWithWebView:webView];
            [[theValue(shouldStartLoad) should] equal:theValue(YES)];
        });
        it(@"should be able to authorize the account", ^{
            // Stub authorization requests
            [CKLSpecHelpers stub:@"authorization/token" andReturn:nil];
            [CKLSpecHelpers stub:CAMPFIRE_API_AUTHORIZATION];
            [CKLSpecHelpers stub:CAMPFIRE_API_USERS_ME];
            [CKLCampfireAPI stub:@selector(authorizeWithWebView:) withBlock:^id (NSArray *params) {
                [[CKLCampfireAPI sharedInstance] _getAccessTokenWithVerificationCode:nil];
                return nil;
            }];

            // Stub authorized account
            CKLCampfireAuthorizedAccount *account = [CKLCampfireAuthorizedAccount new];
            NSString *apiTokenString = @"0123456789abcdef0123456789abcdef01234567";
            NSMutableDictionary *properties = [@{
                @"firstName": @"Jason",
                @"lastName": @"Fried",
                @"emailAddress": @"jason@37signals.com",
                @"organization": @"Your Company",
            } mutableCopy];
            [properties addEntriesFromDictionary:[CKLSpecHelpers accountProperties]];
            [account setValuesForKeysWithDictionary:properties];
            [CKLCampfireAuthorizedAccount stub:@selector(propertyKeys) andReturn:[properties allKeys]];

            // Authorize
            SEL verifyAccount = @selector(verifyAccount:);
            KWCaptureSpy *spy = [CKLSpecHelpers captureArgument:verifyAccount atIndex:0];
            [[CKLSpecHelpers shouldEventually] receive:verifyAccount];
            [CKLCampfireAPI authorizeWithWebView:webView];

            // Check validity of account authorized
            KWFutureObject *futureAccount = expectFutureValue([spy.argument object]);
            [[futureAccount shouldEventuallyBeforeTimingOutAfter(AUTHORIZATION_TIMEOUT)] equal:account];
            KWFutureObject *futureAPITokenString = expectFutureValue([[spy.argument object]valueForKeyPath:@"accessToken.apiTokenString"]);
            [[futureAPITokenString shouldEventuallyBeforeTimingOutAfter(AUTHORIZATION_TIMEOUT)] equal:apiTokenString];
        });
    });
});

SPEC_END
