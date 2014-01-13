//
//  CKLCampfireUser.m
//  Crackle
//
//  Created by Jordan Kay on 12/26/13.
//  Copyright (c) 2013 Jordan Kay. All rights reserved.
//

#import "CKLCampfireUser.h"

@implementation CKLCampfireUser

+ (NSValueTransformer *)avatarURLJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^(NSString *string) {
        return [NSURL URLWithString:string];
    }];
}

+ (NSValueTransformer *)adminJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^(NSString *string) {
        return @([string isEqualToString:@"true"]);
    }];
}

+ (NSValueTransformer *)typeJSONTransformer
{
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
        @"Member": @(CKLCampfireUserTypeMember),
        @"Guest": @(CKLCampfireUserTypeGuest)
    }];
}

+ (NSValueTransformer *)joinDateJSONTransformer
{
    return [CKLCampfireAPI dateTransformer];
}

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
        @"userID": @"id.__text",
        @"avatarURL": @"avatar-url",
        @"emailAddress": @"email-address",
        @"admin": @"admin.__text",
        @"joinDate": @"created-at.__text",
    };
}

@end
