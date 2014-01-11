//
//  CKLMessageSpec.m
//  Crackle
//
//  Created by Jordan Kay on 1/3/14.
//  Copyright (c) 2014 Jordan Kay. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "CKLCampfireAPI.h"
#import "CKLCampfireAPI+Endpoints.h"
#import "CKLCampfireMessage.h"
#import "CKLCampfireTweet.h"
#import "CKLCampfireRoom.h"
#import "CKLSpecHelpers.h"

#define TEST_MESSAGE_LIMIT 3

@interface CKLCampfireMessageSubclass : CKLCampfireMessage

@end

@implementation CKLCampfireMessageSubclass

@end

SPEC_BEGIN(CKLMessageSpec)

describe(@"The API instance", ^{
    __block NSString *userID;
    __block CKLCampfireAuthorizedAccount *account;
    __block CKLCampfireRoom *room;
    CKLCampfireRoom *nonexistentRoom;
    beforeAll(^{
        [CKLSpecHelpers setUp];

        // Stub authorized account
        account = [CKLCampfireAuthorizedAccount new];
        [account setValuesForKeysWithDictionary:[CKLSpecHelpers accountProperties]];

        // Stub room
        room = [CKLCampfireRoom new];
        [room setValue:@"1" forKey:@"roomID"];

        // Stub user
        userID = @"1";

        // Stub room requests
        [CKLSpecHelpers stub:[NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID, room.roomID]];
        [CKLSpecHelpers stub:[NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID_RECENT, room.roomID]];
    });
    beforeEach(^{
        room.viewingAccount = account;
    });
    afterAll(^{
        [CKLSpecHelpers tearDown];
    });
    context(@"when fetching messages from a room", ^{
        __block NSMutableArray *messages;
        __block NSArray *fetchedMessages;
        __block NSMutableSet *propertyKeys;
        beforeAll(^{
            // Stub tweet
            CKLCampfireTweet *tweet = [CKLCampfireTweet new];
            [tweet setValuesForKeysWithDictionary:@{
                @"tweetID": @"418146128945614848",
                @"authorUsername": @"37signals",
                @"text": @"Nobody will be paying for Campfire this month. We didn't earn a dime after two outages within one week. So sorry for the disruption.",
                @"authorAvatarURL": [NSURL URLWithString:@"https://pbs.twimg.com/profile_images/378800000671235961/eefebfe42c58c73db23d5c8698c6d6c5.png"]
            }];

            // Stub messages properties
            NSArray *messageProperties = @[
                @{
                    @"messageID": @"22",
                    @"creationDate": [[CKLCampfireAPI dateTransformer] transformedValue:@"2010-04-15T11:02:08Z"],
                    @"type": @(CKLCampfireMessageTypeTimestamp),
                },
                @{
                    @"messageID": @"23",
                    @"userID": userID,
                    @"body": @"Hello room!",
                    @"creationDate": [[CKLCampfireAPI dateTransformer] transformedValue:@"2010-04-15T11:03:08Z"],
                    @"type": @(CKLCampfireMessageTypeText),
                    @"starred": @NO
                },
                @{
                    @"messageID": @"24",
                    @"userID": userID,
                    @"creationDate": [[CKLCampfireAPI dateTransformer] transformedValue:@"2010-04-15T11:04:08Z"],
                    @"type": @(CKLCampfireMessageTypeLeave),
                },
                @{
                    @"messageID": @"25",
                    @"userID": userID,
                    @"creationDate": [[CKLCampfireAPI dateTransformer] transformedValue:@"2010-04-15T11:05:08Z"],
                    @"type": @(CKLCampfireMessageTypeEnter),
                },
                @{
                    @"messageID": @"26",
                    @"userID": userID,
                    @"body": @"Nobody will be paying for Campfire this month. We didn't earn a dime after two outages within one week. So sorry for the disruption. -- @37signals, http://twitter.com/37signals/status/11923460649394176",
                    @"creationDate": [[CKLCampfireAPI dateTransformer] transformedValue:@"2010-04-15T11:06:08Z"],
                    @"type": @(CKLCampfireMessageTypeTweet),
                    @"tweet": tweet,
                    @"starred": @NO
                },
                @{
                    @"messageID": @"27",
                    @"userID": userID,
                    @"body": @"trombone",
                    @"creationDate": [[CKLCampfireAPI dateTransformer] transformedValue:@"2010-04-15T11:07:08Z"],
                    @"type": @(CKLCampfireMessageTypeSound),
                    @"starred": @YES,
                    @"eventDescription": @"plays a sad trombone",
                    @"eventURL": [NSURL URLWithString:@"https://123.campfirenow.com/sounds/trombone.mp3"]
                }
            ];
            
            // Stub messages
            messages = [NSMutableArray arrayWithCapacity:[messageProperties count]];
            propertyKeys = [NSMutableSet set];
            for (NSDictionary *properties in messageProperties) {
                CKLCampfireMessage *message = [CKLCampfireMessage new];
                [message setValuesForKeysWithDictionary:properties];
                [messages addObject:message];
                
                [propertyKeys addObjectsFromArray:[properties allKeys]];
            }

            // Fetch messages
            [CKLCampfireAPI getRecentMessagesForRoom:room responseBlock:^(NSArray *array, NSError *error) {
                fetchedMessages = array;
            }];
        });
        beforeEach(^{
            // Stub property keys for isEqual
            [CKLCampfireMessage stub:@selector(propertyKeys) andReturn:[propertyKeys allObjects]];
        });
        it(@"should be able to parse messages returned", ^{
            [[expectFutureValue(fetchedMessages) shouldEventually] equal:messages];
        });
        it(@"should assign the room to all the messages", ^{
            NSSet *fetchedMessageRooms = [NSSet setWithArray:[fetchedMessages valueForKeyPath:@"room"]];
            [[fetchedMessageRooms should] haveCountOf:1];

            // Don’t worry about actual room properties yet
            [[[fetchedMessageRooms valueForKeyPath:@"roomID"] should] contain:room.roomID];
        });
        it(@"should assign the account viewing the room to the room", ^{
            NSSet *fetchedMessageAccounts = [NSSet setWithArray:[fetchedMessages valueForKeyPath:@"viewingAccount"]];
            [[expectFutureValue(fetchedMessageAccounts) shouldEventually] haveCountOf:1];
            [[expectFutureValue(fetchedMessageAccounts) shouldEventually] contain:account];
        });
        context(@"after the penultimate message", ^{
            __block CKLCampfireMessage *penultimateMessage;
            beforeAll(^{
                penultimateMessage = messages[[messages count] - 2];
                [CKLSpecHelpers stub:[NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID_RECENT, room.roomID] andReturn:[NSString stringWithFormat:@"room_%@_recent_since_message_id_%@.xml", room.roomID, penultimateMessage.messageID]];
            });
            it(@"should fetch the last message", ^{
                [CKLCampfireAPI getRecentMessagesForRoom:room sinceMessage:penultimateMessage responseBlock:^(NSArray *array, NSError *error) {
                    fetchedMessages = array;
                }];

                [[expectFutureValue(fetchedMessages) shouldEventually] haveCountOf:1];
                [[expectFutureValue([fetchedMessages lastObject]) shouldEventually] equal:[messages lastObject]];
            });
        });
        context(@"with limit set to n", ^{
            const NSInteger limit = TEST_MESSAGE_LIMIT;
            __block NSArray *lastMessages;
            beforeAll(^{
                lastMessages = [messages subarrayWithRange:NSMakeRange([messages count] - limit, limit)];
                [CKLSpecHelpers stub:[NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID_RECENT, room.roomID] andReturn:[NSString stringWithFormat:@"room_%@_recent_limit_%ld.xml", room.roomID, (long)limit]];
            });
            it(@"should fetch the last n messages", ^{
                [CKLCampfireAPI getRecentMessagesForRoom:room sinceMessage:nil withLimit:limit responseBlock:^(NSArray *array, NSError *error) {
                    fetchedMessages = array;
                }];

                [[expectFutureValue(fetchedMessages) shouldEventually] haveCountOf:limit];
                [[expectFutureValue(fetchedMessages) shouldEventually] equal:lastMessages];
            });
        });
        context(@"from a room that doesn’t exist", ^{
            it(@"should raise an error", ^{
                [[theBlock(^{
                    [CKLCampfireAPI getRecentMessagesForRoom:nonexistentRoom responseBlock:^(NSArray *array, NSError *error) {
                        return;
                    }];
                }) should] raise];
            });
        });
        context(@"without an account authenticated for the room", ^{
            beforeAll(^{
                room.viewingAccount = nil;
            });
            it(@"should raise an error", ^{
                [[theBlock(^{
                    [CKLCampfireAPI getRecentMessagesForRoom:room responseBlock:^(NSArray *array, NSError *error) {
                        return;
                    }];
                }) should] raise];
            });
        });
    });
    context(@"when sending a message", ^{
        __block CKLCampfireMessage *messageToSend;
        beforeAll(^{
            messageToSend = [CKLCampfireMessage postingMessageWithBody:@"Hello" ofType:CKLCampfireMessageTypeText];

            [CKLCampfireMessage stub:@selector(propertyKeys) andReturn:@[@"body", @"type"]];
            [CKLSpecHelpers stub:[NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID_SPEAK, room.roomID]];
        });
        it(@"should make a round trip through the API", ^{
            __block CKLCampfireMessage *sentMessage;
            [CKLCampfireAPI sendMessage:messageToSend toRoom:room responseBlock:^(CKLCampfireMessage *message, NSError *error) {
                sentMessage = message;
            }];
            [[expectFutureValue(sentMessage) shouldEventually] equal:messageToSend];
        });
    });
    context(@"when starring an unstarred message", ^{
        __block CKLCampfireMessage *message;
        beforeAll(^{
            message = [CKLCampfireMessage new];
            [message setValue:@"28" forKey:@"messageID"];
            message.viewingAccount = account;
        });
        beforeEach(^{
            [message setValue:@NO forKey:@"starred"];
        });
        context(@"under successful network conditions", ^{
            beforeAll(^{
                [CKLSpecHelpers stub:[NSString stringWithFormat:CAMPFIRE_API_MESSAGES_MESSAGEID_STAR, message.messageID] andReturn:nil];
            });
            it(@"should become starred", ^{
                [CKLCampfireAPI starMessage:message responseBlock:^(NSError *error) {
                    return;
                }];
                [[theValue(message.starred) should] equal:theValue(YES)];
            });
        });
        context(@"under unsuccessful network conditions", ^{
            beforeAll(^{
                [CKLSpecHelpers stubWithNetworkFailure:[NSString stringWithFormat:CAMPFIRE_API_MESSAGES_MESSAGEID_STAR, message.messageID]];
            });
            it(@"should not become starred", ^{
                [CKLCampfireAPI starMessage:message responseBlock:^(NSError *error) {
                    return;
                }];
                [[expectFutureValue(theValue(message.starred)) shouldEventually] equal:theValue(NO)];
            });
        });
    });
    context(@"when starring a starred message", ^{
        __block CKLCampfireMessage *message;
        beforeAll(^{
            message = [CKLCampfireMessage new];
            [message setValue:@"29" forKey:@"messageID"];
            message.viewingAccount = account;
        });
        beforeEach(^{
            [message setValue:@YES forKey:@"starred"];
        });
        context(@"under successful network conditions", ^{
            beforeAll(^{
                [CKLSpecHelpers stub:[NSString stringWithFormat:CAMPFIRE_API_MESSAGES_MESSAGEID_STAR, message.messageID] andReturn:nil];
            });
            it(@"should become unstarred", ^{
                [CKLCampfireAPI starMessage:message responseBlock:^(NSError *error) {
                    return;
                }];
                [[theValue(message.starred) should] equal:theValue(NO)];
            });
        });
        context(@"under unsuccessful network conditions", ^{
            beforeAll(^{
                [CKLSpecHelpers stubWithNetworkFailure:[NSString stringWithFormat:CAMPFIRE_API_MESSAGES_MESSAGEID_STAR, message.messageID]];
            });
            it(@"should not become unstarred", ^{
                [CKLCampfireAPI starMessage:message responseBlock:^(NSError *error) {
                    return;
                }];
                [[expectFutureValue(theValue(message.starred)) shouldEventually] equal:theValue(YES)];
            });
        });
    });
    context(@"when registering to use a subclass for messages", ^{
        beforeEach(^{
            [CKLCampfireAPI registerSubclass:[CKLCampfireMessageSubclass class] forModelClass:[CKLCampfireMessage class]];
        });
        context(@"after registering", ^{
            it(@"should use that subclass", ^{
                __block NSSet *classes;
                [CKLCampfireAPI getRecentMessagesForRoom:room responseBlock:^(NSArray *array, NSError *error) {
                    classes = [NSSet setWithArray:[array valueForKeyPath:@"class"]];
                }];
                [[expectFutureValue([classes allObjects]) shouldEventually] equal:@[[CKLCampfireMessageSubclass class]]];
            });
        });
        context(@"after deregistering", ^{
            beforeAll(^{
                [CKLCampfireAPI deregisterSubclassForModelClass:[CKLCampfireMessage class]];
            });
            it(@"should not use that subclass", ^{
                __block NSSet *classes;
                [CKLCampfireAPI getRecentMessagesForRoom:room responseBlock:^(NSArray *array, NSError *error) {
                    classes = [NSSet setWithArray:[array valueForKeyPath:@"class"]];
                }];
                [[expectFutureValue([classes allObjects]) shouldNotEventually] equal:@[[CKLCampfireMessageSubclass class]]];
            });
        });
    });
});

SPEC_END
