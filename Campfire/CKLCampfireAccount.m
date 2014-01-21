//
//  CKLCampfireAccount.m
//  Crackle
//
//  Created by Jordan Kay on 12/26/13.
//  Copyright (c) 2013 Jordan Kay. All rights reserved.
//

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

+ (NSArray *)accountsFromAuthorizationDictionary:(NSDictionary * )dictionary
{
    NSArray *accountDictionaries = dictionary[@"accounts"][@"account"];
    if (![accountDictionaries isKindOfClass:[NSArray class]]) {
        accountDictionaries = @[accountDictionaries];
    }

    NSMutableArray *accounts = [NSMutableArray arrayWithCapacity:[accountDictionaries count]];
    for (NSDictionary *accountDictionary in accountDictionaries) {
        if ([accountDictionary[@"_product"] isEqualToString:@"campfire"]) {
            NSMutableDictionary *mutableDictionary = [dictionary mutableCopy];
            [mutableDictionary removeObjectForKey:@"accounts"];
            mutableDictionary[@"organization"] = accountDictionary[@"_name"];
            mutableDictionary[@"organizationURL"] = accountDictionary[@"_href"];

            CKLCampfireAuthorizedAccount *account = [MTLJSONAdapter modelOfClass:[CKLCampfireAuthorizedAccount class] fromJSONDictionary:mutableDictionary error:nil];
            [accounts addObject:account];
        }
    }
    return accounts;
}

+ (NSValueTransformer *)organizationURLJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^(NSString *string) {
        return [NSURL URLWithString:string];
    }];
}

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
        @"accountID": @"identity._id",
        @"firstName": @"identity._first_name",
        @"lastName": @"identity._last_name",
        @"emailAddress": @"identity._email_address",
    };
}

@end
