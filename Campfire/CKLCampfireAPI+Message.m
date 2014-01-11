//
//  CKLCampfireAPI+Message.m
//  Crackle
//
//  Created by Jordan Kay on 12/26/13.
//  Copyright (c) 2013 Jordan Kay. All rights reserved.
//

#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "CKLCampfireAPI.h"
#import "CKLCampfireAPI+Endpoints.h"
#import "CKLCampfireAPI+Private.h"
#import "CKLCampfireMessage.h"
#import "CKLCampfireRoom.h"

#define MAX_MESSAGE_LIMIT 100

@interface CKLCampfireMessage ()

@property (nonatomic) CKLCampfireRoom *room;
@property (nonatomic, getter = isStarred) BOOL starred;

@end

@implementation CKLCampfireAPI (Message)

+ (void)getRecentMessagesForRoom:(CKLCampfireRoom *)room responseBlock:(CKLCampfireAPIArrayResponseBlock)responseBlock
{
    [self getRecentMessagesForRoom:room sinceMessage:nil responseBlock:responseBlock];
}

+ (void)getRecentMessagesForRoom:(CKLCampfireRoom *)room sinceMessage:(CKLCampfireMessage *)message responseBlock:(CKLCampfireAPIArrayResponseBlock)responseBlock
{
    [self getRecentMessagesForRoom:room sinceMessage:message withLimit:MAX_MESSAGE_LIMIT responseBlock:responseBlock];
}

+ (void)getRecentMessagesForRoom:(CKLCampfireRoom *)room sinceMessage:(CKLCampfireMessage *)message withLimit:(NSInteger)limit responseBlock:(CKLCampfireAPIArrayResponseBlock)responseBlock
{
    NSString *resource = [NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID_RECENT, room.roomID];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"limit": [NSString stringWithFormat:@"%ld", (long)limit]}];
    if (message) {
        parameters[@"since_message_id"] = message.messageID;
    }
    [self _getMessagesForResource:resource account:room.viewingAccount room:room parameters:parameters responseBlock:responseBlock];
}

+ (void)getTodaysMessagesForRoom:(CKLCampfireRoom *)room responseBlock:(CKLCampfireAPIArrayResponseBlock)responseBlock
{
    NSString *resource = [NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID_TRANSCRIPT, room.roomID];
    [self _getMessagesForResource:resource room:room responseBlock:responseBlock];
}

+ (void)getMessagesForRoom:(CKLCampfireRoom *)room fromDate:(NSDate *)date responseBlock:(CKLCampfireAPIArrayResponseBlock)responseBlock
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSString *resource = [NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID_TRANSCRIPT_YEAR_MONTH_DAY, room.roomID, (long)components.year, (long)components.month, (long)components.day];
    [self _getMessagesForResource:resource room:room responseBlock:responseBlock];
}

+ (void)getMessagesWithQuery:(NSString *)query account:(CKLCampfireAuthorizedAccount *)account responseBlock:(CKLCampfireAPIArrayResponseBlock)responseBlock
{
    NSDictionary *parameters = @{@"q": query, @"format": @"xml"};
    [self _getMessagesForResource:CAMPFIRE_API_SEARCH account:account room:nil parameters:parameters responseBlock:responseBlock];
}

+ (void)streamMessagesInRoom:(CKLCampfireRoom *)room responseBlock:(CKLCampfireAPIMessageResponseBlock)responseBlock
{
    NSString *resource = [NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID_LIVE, room.roomID];
    [[self sharedInstance] streamResource:resource forAccount:room.viewingAccount withParameters:nil responseBlock:^(id responseObject, NSError *error) {
        if (responseBlock) {
            CKLCampfireMessage *message;
            if (responseObject) {
                Class class = [self subclassForModelClass:[CKLCampfireStreamedMessage class]];
                message = [MTLJSONAdapter modelOfClass:class fromJSONDictionary:responseObject error:nil];
                message.room = room;
            }
            responseBlock(message, error);
        }
    }];
}

+ (void)sendMessage:(CKLCampfireMessage *)message toRoom:(CKLCampfireRoom *)room responseBlock:(CKLCampfireAPIMessageResponseBlock)responseBlock
{
    NSString *resource = [NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID_SPEAK, room.roomID];
    NSDictionary *dictionary = [MTLJSONAdapter JSONDictionaryFromModel:message];
    NSDictionary *parameters = @{@"message": [dictionary dictionaryWithValuesForKeys:[CKLCampfireMessage postKeys]]};

    [[self sharedInstance] postResource:resource forAccount:room.viewingAccount withParameters:parameters responseBlock:^(id responseObject, NSError *error) {
        if (responseBlock) {
            [self processResponseObject:responseObject ofType:[CKLCampfireMessage class] error:error processBlock:^(CKLCampfireMessage *object) {
                message.room = room;
            } responseBlock:responseBlock];
        }
    }];
}

+ (void)starMessage:(CKLCampfireMessage *)message responseBlock:(CKLCampfireAPIErrorBlock)responseBlock
{
    NSString *resource = [NSString stringWithFormat:CAMPFIRE_API_MESSAGES_MESSAGEID_STAR, message.messageID];
    if (!message.starred) {
        message.starred = YES;
        [[self sharedInstance] postResource:resource forAccount:message.viewingAccount withParameters:nil responseBlock:^(id responseObject, NSError *error) {
            if (error) {
                message.starred = NO;
            }
            responseBlock(error);
        }];
    } else {
        message.starred = NO;
        [[self sharedInstance] deleteResource:resource forAccount:message.viewingAccount withParameters:nil responseBlock:^(id responseObject, NSError *error) {
            if (error) {
                message.starred = YES;
            }
            responseBlock(error);
        }];
    }
}

+ (void)_getMessagesForResource:(NSString *)resource room:(CKLCampfireRoom *)room responseBlock:(CKLCampfireAPIArrayResponseBlock)responseBlock
{
    [self _getMessagesForResource:resource account:room.viewingAccount room:room parameters:nil responseBlock:responseBlock];
}

+ (void)_getMessagesForResource:(NSString *)resource account:(CKLCampfireAuthorizedAccount *)account room:(CKLCampfireRoom *)room parameters:(NSDictionary *)parameters responseBlock:(CKLCampfireAPIArrayResponseBlock)responseBlock
{
    if (room.users || !room) {
        [[self sharedInstance] getResource:resource forAccount:account withParameters:parameters responseBlock:^(id responseObject, NSError *error) {
            [self processResponseObject:responseObject ofType:[CKLCampfireMessage class] key:@"message" idKey:@"messageID" multiple:YES error:error processBlock:^(CKLCampfireMessage *message) {
                message.viewingAccount = account;
                message.room = room;
            } responseBlock:responseBlock];
        }];
    } else {
        [self getInfoForRoom:room responseBlock:^(CKLCampfireRoom *room, NSError *error) {
            if (room) {
                [self _getMessagesForResource:resource account:account room:room parameters:parameters responseBlock:responseBlock];
            } else {
                responseBlock(nil, error);
            }
        }];
    }
}

@end
