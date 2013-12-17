//
//  CKLAccountSpec.m
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

SPEC_BEGIN(CKLAccountSpec)

describe(@"The API instance", ^{
    __block CKLCampfireAuthorizedAccount *account;
    __block CKLCampfireAccount *infoAccount;
    beforeAll(^{
        [CKLSpecHelpers setUp];

        // Stub authorized account
        account = [CKLCampfireAuthorizedAccount new];
        [account setValuesForKeysWithDictionary:[CKLSpecHelpers accountProperties]];

        // Stub info account
        NSDictionary *properties = @{
            @"userID": @"1",
            @"subdomain": @"yourco",
            @"organization": @"Your Company",
            @"creationDate": [[CKLCampfireAPI dateTransformer] transformedValue:@"2011-01-12T15:00:00Z"],
            @"lastUpdatedDate": [[CKLCampfireAPI dateTransformer] transformedValue:@"2011-01-12T15:00:00Z"],
            @"timeZone": [NSTimeZone timeZoneWithName:@"America/Chicago"],
            @"plan": @(CKLCampfireAccountPlanPremium),
            @"storage": @(17374444)
        };
        infoAccount = [CKLCampfireAccount new];
        [infoAccount setValuesForKeysWithDictionary:properties];
        [CKLCampfireAccount stub:@selector(propertyKeys) andReturn:[properties allKeys]];
    });
    afterAll(^{
        [CKLSpecHelpers tearDown];
    });
    context(@"when getting info for the current account", ^{
        beforeAll(^{
            [CKLSpecHelpers stub:CAMPFIRE_API_ACCOUNT];
        });
        it(@"should be able to parse the account returned", ^{
            __block CKLCampfireAccount *fetchedAccount;
            [CKLCampfireAPI getInfoForAccount:account responseBlock:^(CKLCampfireAccount *account, NSError *error) {
                fetchedAccount = account;
            }];
            [[expectFutureValue(fetchedAccount) shouldEventually] equal:infoAccount];
        });
    });
});

SPEC_END
