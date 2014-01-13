//
//  CKLCampfireTweet.m
//  Crackle
//
//  Created by Jordan Kay on 12/26/13.
//  Copyright (c) 2013 Jordan Kay. All rights reserved.
//

#import "CKLCampfireTweet.h"

@implementation CKLCampfireTweet

+ (NSValueTransformer *)authorAvatarURLJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^(NSString *string) {
        return [NSURL URLWithString:string];
    }];
}

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
        @"tweetID": @"id",
        @"authorUsername": @"author_username",
        @"text": @"message",
        @"authorAvatarURL": @"author_avatar_url",
    };
}

@end
