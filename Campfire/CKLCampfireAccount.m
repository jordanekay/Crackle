//
//  CKLCampfireAccount.m
//  Crackle
//
//  Created by Jordan Kay on 12/26/13.
//  Copyright (c) 2013 Jordan Kay. All rights reserved.
//

#import <Mantle/MTLValueTransformer.h>
#import "CKLCampfireAccount.h"
#import "CKLCampfireAPI.h"

@implementation CKLCampfireAccount

+ (NSValueTransformer *)creationDateJSONTransformer
{
    return [CKLCampfireAPI dateTransformer];
}

+ (NSValueTransformer *)lastUpdatedDateJSONTransformer
{
    return [CKLCampfireAPI dateTransformer];
}

+ (NSValueTransformer *)timeZoneJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^(NSString *name) {
        return [NSTimeZone timeZoneWithName:name];
    }];
}

+ (NSValueTransformer *)planJSONTransformer
{
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
        @"basic": @(CKLCampfireAccountPlanBasic),
        @"plus": @(CKLCampfireAccountPlanPlus),
        @"premium": @(CKLCampfireAccountPlanPremium),
        @"max": @(CKLCampfireAccountPlanMax)
    }];
}

+ (NSValueTransformer *)storageJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^(NSString *string) {
        return @([string longLongValue]);
    }];
}

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
        @"accountID": @"id.__text",
        @"userID": @"owner-id.__text",
        @"organization": @"name",
        @"creationDate": @"created-at.__text",
        @"lastUpdatedDate": @"updated-at.__text",
        @"timeZone": @"time-zone",
        @"storage": @"storage.__text"
    };
}

@end

@implementation CKLCampfireAuthorizedAccount

+ (NSValueTransformer *)organizationJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^(NSArray *accounts) {
        NSDictionary *account = campfireAccountFromAccounts(accounts);
        return account[@"_name"];
    }];
}

+ (NSValueTransformer *)organizationURLJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^(NSArray *accounts) {
        NSDictionary *account = campfireAccountFromAccounts(accounts);
        return [NSURL URLWithString:account[@"_href"]];
    }];
}

NSDictionary *campfireAccountFromAccounts(NSArray *accounts)
{
    __block NSDictionary *campfireAccount;
    if (![accounts isKindOfClass:[NSArray class]]) {
        accounts = @[accounts];
    }
    [accounts enumerateObjectsUsingBlock:^(NSDictionary *account, NSUInteger idx, BOOL *stop) {
        if ([account[@"_product"] isEqualToString:@"campfire"]) {
            campfireAccount = account;
            *stop = YES;
        }
    }];
    return campfireAccount;
}

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
        @"accountID": @"identity._id",
        @"firstName": @"identity._first_name",
        @"lastName": @"identity._last_name",
        @"emailAddress": @"identity._email_address",
        @"organization": @"accounts.account",
        @"organizationURL": @"accounts.account"
    };
}

@end
