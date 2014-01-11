//
//  CKLCampfireUser.m
//  Crackle
//
//  Created by Jordan Kay on 12/26/13.
//  Copyright (c) 2013 Jordan Kay. All rights reserved.
//

#import <Mantle/MTLValueTransformer.h>
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>
#import "CKLCampfireAPI.h"
#import "CKLCampfireAPI+Private.h"
#import "CKLCampfireMessage.h"
#import "CKLCampfireRoom.h"
#import "CKLCampfireTweet.h"
#import "CKLCampfireUser.h"

#define TWITTER_HOST @"twitter.com"
#define TWITTER_STATUS_PATH @"/status"

#define PLAY_SOUND_PREFIX @"/play "
#define PLAYS_SOUND_PREFIX @"/plays "

@interface CKLCampfireMessage ()

@property (nonatomic) CKLCampfireUser *user;
@property (nonatomic, getter = isStarred) BOOL starred;

@end

@implementation CKLCampfireMessage

@synthesize viewingAccount = _viewingAccount;

+ (instancetype)postingMessageWithBody:(NSString *)body ofType:(CKLCampfireMessageType)type
{
    CKLCampfireMessage *message = [CKLCampfireMessage new];

    if ([body hasPrefix:PLAY_SOUND_PREFIX] || [body hasPrefix:PLAYS_SOUND_PREFIX]) {
        NSString *soundName = [[body componentsSeparatedByString:@" "] lastObject];
        if ([[self messageSoundNames] containsObject:soundName]) {
            message->_body = soundName;
            message->_type = CKLCampfireMessageTypeSound;
        }
    } else if ([body rangeOfString:TWITTER_HOST].location != NSNotFound && [body rangeOfString:TWITTER_STATUS_PATH].location != NSNotFound) {
        message->_type = CKLCampfireMessageTypeTweet;
    } else {
        message->_type = type;
    }
    if (!message->_body) {
        message->_body = [body copy];
    }
    
    return message;
}

+ (NSString *)typeNameForPostingMessage:(CKLCampfireMessage *)message
{
    NSString *typeName;
    if (message.type == CKLCampfireMessageTypeSound) {
        typeName = @"SoundMessage";
    } else if ([message.body rangeOfString:TWITTER_HOST].location != NSNotFound && [message.body rangeOfString:TWITTER_STATUS_PATH].location != NSNotFound) {
        typeName = @"TweetMessage";
    } else {
        typeName = @"TextMessage";
    }
    return typeName;
}

+ (NSArray *)postKeys
{
    return @[@"body", @"type"];
}

+ (NSArray *)messageSoundNames
{
    return @[@"56k", @"bueller", @"crickets", @"dangerzone", @"deeper", @"drama", @"greatjob", @"horn", @"horror", @"inconceivable", @"live", @"loggins", @"noooo", @"nyan", @"ohmy", @"ohyeah", @"pushit", @"rimshot", @"sax", @"secret", @"tada", @"tmyk", @"trombone", @"vuvuzela", @"yeah", @"yodel"];
}

- (void)setRoom:(CKLCampfireRoom *)room
{
    if (_room != room) {
        _room = room;
        self.viewingAccount = room.viewingAccount;
        if (self.userID) {
            NSInteger authorIndex = [room.users indexOfObjectPassingTest:^BOOL(CKLCampfireUser *user, NSUInteger idx, BOOL *stop) {
                return [user.userID isEqual:self.userID];
            }];
            if (authorIndex != NSNotFound) {
                self.user = room.users[authorIndex];
            }
        }
    }
}

+ (NSValueTransformer *)bodyJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^(id object) {
        return [object isKindOfClass:[NSString class]] ? object : nil;
    }];
}

+ (NSValueTransformer *)creationDateJSONTransformer
{
    return [CKLCampfireAPI dateTransformer];
}

+ (NSValueTransformer *)typeJSONTransformer
{
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
        @"AdvertisementMessage": @(CKLCampfireMessageTypeAdvertisement),
        @"AllowGuestsMessage": @(CKLCampfireMessageTypeAllowGuests),
        @"ConferenceCreatedMessage": @(CKLCampfireMessageTypeConferenceCreated),
        @"CenferenceFinishedMessage": @(CKLCampfireMessageTypeConferenceFinished),
        @"DisallowGuestsMessage": @(CKLCampfireMessageTypeDisallowGuests),
        @"EnterMessage": @(CKLCampfireMessageTypeEnter),
        @"IdleMessage": @(CKLCampfireMessageTypeIdle),
        @"KickMessage": @(CKLCampfireMessageTypeKick),
        @"LeaveMessage": @(CKLCampfireMessageTypeLeave),
        @"LockMessage": @(CKLCampfireMessageTypeLock),
        @"PasteMessage": @(CKLCampfireMessageTypePaste),
        @"SoundMessage": @(CKLCampfireMessageTypeSound),
        @"SystemMessage": @(CKLCampfireMessageTypeSystem),
        @"TextMessage": @(CKLCampfireMessageTypeText),
        @"TimestampMessage": @(CKLCampfireMessageTypeTimestamp),
        @"TopicChangedMessage": @(CKLCampfireMessageTypeTopicChanged),
        @"TweetMessage": @(CKLCampfireMessageTypeTweet),
        @"UnidleMessage": @(CKLCampfireMessageTypeUnidle),
        @"UnlockMessage": @(CKLCampfireMessageTypeUnlock),
        @"UploadMessage": @(CKLCampfireMessageTypeUpload)
    }];
}

+ (NSValueTransformer *)tweetJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^(NSDictionary *dictionary) {
        Class class = [CKLCampfireAPI subclassForModelClass:[CKLCampfireTweet class]];
        return [MTLJSONAdapter modelOfClass:class fromJSONDictionary:dictionary error:nil];
    }];
}

+ (NSValueTransformer *)eventURLJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^(NSString *string) {
        return [NSURL URLWithString:string];
    }];
}

+ (NSValueTransformer *)starredJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^(id starred) {
        if (![starred isKindOfClass:[NSString class]]) {
            starred = starred[@"__text"];
        }
        return @([starred isEqualToString:@"true"]);
    }];
}

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
        @"messageID": @"id.__text",
        @"userID": @"user-id.__text",
        @"creationDate": @"created-at.__text",
        @"eventDescription": @"description",
        @"eventURL": @"url",
    };
}

@end

@implementation CKLCampfireStreamedMessage

+ (NSValueTransformer *)creationDateJSONTransformer
{
    return [CKLCampfireAPI streamingDateTransformer];
}

+ (NSValueTransformer *)starredJSONTransformer
{
    return nil;
}

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
        @"messageID": @"id",
        @"userID": @"user_id",
        @"creationDate": @"created_at",
        @"eventDescription": @"description",
        @"eventURL": @"url"
    };
}

@end
