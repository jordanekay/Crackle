//
//  CKLCampfirem
//  Crackle
//
//  Created by Jordan Kay on 12/26/13.
//  Copyright (c) 2013 Jordan Kay. All rights reserved.
//

#import <Mantle/MTLValueTransformer.h>
#import "CKLCampfireAPI+Private.h"
#import "CKLCampfireRoom.h"
#import "CKLCampfireUser.h"

@interface CKLCampfireRoom ()

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *topic;
@property (nonatomic, getter = isLocked) BOOL locked;

@end

@implementation CKLCampfireRoom

@synthesize viewingAccount = _viewingAccount;

+ (NSDictionary *)editParametersForName:(NSString *)name topic:(NSString *)topic
{
    return @{
        @"name": name ?: @"",
        @"topic": topic ?: @""
    };
}

+ (NSValueTransformer *)membershipLimitJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^(NSString *string) {
        return @([string integerValue]);
    }];
}

+ (NSValueTransformer *)creationDateJSONTransformer
{
    return [CKLCampfireAPI dateTransformer];
}

+ (NSValueTransformer *)updatedDateJSONTransformer
{
    return [CKLCampfireAPI dateTransformer];
}

+ (NSValueTransformer *)usersJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^(NSArray *dictionaries) {
        if (![dictionaries isKindOfClass:[NSArray class]]) {
            dictionaries = @[dictionaries];
        }
        NSMutableArray *users = [NSMutableArray arrayWithCapacity:[dictionaries count]];
        for (NSDictionary *dictionary in dictionaries) {
            Class class = [CKLCampfireAPI subclassForModelClass:[CKLCampfireUser class]];
            CKLCampfireUser *user = [MTLJSONAdapter modelOfClass:class fromJSONDictionary:dictionary error:nil];
            [users addObject:user];
        }
        return users;
    }];
}

+ (NSValueTransformer *)fullJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^(NSString *string) {
        return @([string isEqualToString:@"true"]);
    }];
}

+ (NSValueTransformer *)lockedJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^(NSString *string) {
        return @([string isEqualToString:@"false"]);
    }];
}

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
        @"roomID": @"id.__text",
        @"membershipLimit": @"membership-limit.__text",
        @"creationDate": @"created-at.__text",
        @"updatedDate": @"updated-at.__text",
        @"users": @"users.user",
        @"full": @"full.__text",
        @"locked": @"open-to-guests.__text"
    };
}

@end
