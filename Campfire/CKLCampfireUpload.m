//
//  CKLCampfireUpload.m
//  Crackle
//
//  Created by Jordan Kay on 12/27/13.
//  Copyright (c) 2013 Jordan Kay. All rights reserved.
//

#import <Mantle/MTLValueTransformer.h>
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>
#import "CKLCampfireAPI.h"
#import "CKLCampfireRoom.h"
#import "CKLCampfireUpload.h"
#import "CKLCampfireUser.h"

@interface CKLCampfireUpload ()

@property (nonatomic) CKLCampfireUser *user;

@end

@implementation CKLCampfireUpload

+ (NSValueTransformer *)creationDateJSONTransformer
{
    return [CKLCampfireAPI dateTransformer];
}

+ (NSValueTransformer *)urlJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^(NSString *string) {
        return [NSURL URLWithString:string];
    }];
}

+ (NSValueTransformer *)sizeJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^(NSString *string) {
        return @([string integerValue]);
    }];
}

- (void)setRoom:(CKLCampfireRoom *)room
{
    if (_room != room) {
        _room = room;
        if (self.userID) {
            NSInteger uploaderIndex = [room.users indexOfObjectPassingTest:^BOOL(CKLCampfireUser *user, NSUInteger idx, BOOL *stop) {
                return [user.userID isEqual:self.userID];
            }];
            if (uploaderIndex != NSNotFound) {
                self.user = room.users[uploaderIndex];
            }
        }
    }
}

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
        @"uploadID": @"id.__text",
        @"userID": @"user-id.__text",
        @"contentType": @"content-type",
        @"creationDate": @"created-at.__text",
        @"url": @"full-url",
        @"size": @"byte-size.__text",
        @"starred": @"starred.__text"
    };
}

@end
