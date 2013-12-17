//
//  CKLUserSpec.m
//  Crackle
//
//  Created by Jordan Kay on 1/4/14.
//  Copyright (c) 2014 Jordan Kay. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "CKLCampfireAPI.h"
#import "CKLCampfireAPI+Endpoints.h"
#import "CKLCampfireAccount.h"
#import "CKLCampfireUser.h"
#import "CKLSpecHelpers.h"

SPEC_BEGIN(CKLUserSpec)

describe(@"The API instance", ^{
    __block CKLCampfireAuthorizedAccount *account;;
    __block CKLCampfireUser *user;
    CKLCampfireUser *nonexistentUser ;
    beforeAll(^{
        [CKLSpecHelpers setUp];

        // Stub authorized account
        account = [CKLCampfireAuthorizedAccount new];
        [account setValuesForKeysWithDictionary:[CKLSpecHelpers accountProperties]];

        // Stub user
        user = [CKLCampfireUser new];
        [user setValuesForKeysWithDictionary:@{
            @"userID": @"1",
            @"name": @"Jason Fried",
            @"emailAddress": @"jason@37signals.com",
            @"avatarURL": [NSURL URLWithString:@"https://asset0.37img.com/global/.../avatar.png"],
            @"joinDate": [[CKLCampfireAPI dateTransformer] transformedValue:@"2009-11-20T16:41:39Z"],
            @"type": @(CKLCampfireUserTypeMember),
            @"admin": @YES
        }];
    });
    afterAll(^{
        [CKLSpecHelpers tearDown];
    });
    context(@"when getting info for the user for the current account", ^{
        beforeAll(^{
            [CKLSpecHelpers stub:CAMPFIRE_API_USERS_ME];
        });
        it(@"should be able to parse the user returned", ^{
            __block CKLCampfireUser *fetchedUser;
            [CKLCampfireAPI getInfoForUserForCurrentAccount:account responseBlock:^(CKLCampfireUser *user, NSError *error) {
                fetchedUser = user;
            }];
            [[expectFutureValue(fetchedUser) shouldEventually] equal:user];
        });
    });
    context(@"when getting info for a specific user", ^{
        beforeAll(^{
            [CKLSpecHelpers stub:[NSString stringWithFormat:CAMPFIRE_API_USERS_USERID, user.userID]];
        });
        it(@"should be able to parse the user returned", ^{
            __block CKLCampfireUser *fetchedUser;
            [CKLCampfireAPI getInfoForUser:user viewedByCurrentAccount:account responseBlock:^(CKLCampfireUser *user, NSError *error) {
                fetchedUser = user;
            }];
            [[expectFutureValue(fetchedUser) shouldEventually] equal:user];
        });
        context(@"without an account authenticated to see it", ^{
            it(@"should raise an error", ^{
                __block CKLCampfireUser *fetchedUser;
                [[theBlock(^{
                    [CKLCampfireAPI getInfoForUser:user viewedByCurrentAccount:nil responseBlock:^(CKLCampfireUser *user, NSError *error) {
                        fetchedUser = user;
                    }];
                }) should] raise];
            });
        });
    });
    context(@"when getting info for a user that doesn’t exist", ^{
        beforeAll(^{
            [CKLSpecHelpers stub:[NSString stringWithFormat:CAMPFIRE_API_USERS_USERID, nonexistentUser.userID] andReturn:nil];
        });
        it(@"should be able to parse the user returned", ^{
            __block CKLCampfireUser *fetchedUser;
            [CKLCampfireAPI getInfoForUser:nonexistentUser viewedByCurrentAccount:account responseBlock:^(CKLCampfireUser *user, NSError *error) {
                fetchedUser = user;
            }];
            [[expectFutureValue(fetchedUser) shouldEventually] beNil];
        });
    });
});

SPEC_END
