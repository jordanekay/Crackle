//
//  CKLRoomSpec.m
//  Crackle
//
//  Created by Jordan Kay on 1/5/14.
//  Copyright (c) 2014 Jordan Kay. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "CKLCampfireAPI.h"
#import "CKLCampfireAPI+Endpoints.h"
#import "CKLCampfireRoom.h"
#import "CKLCampfireUser.h"
#import "CKLSpecHelpers.h"

@interface CKLCampfireRoomSubclass : CKLCampfireRoom

@end

@implementation CKLCampfireRoomSubclass

@end

SPEC_BEGIN(CKLRoomSpec)

describe(@"The API instance", ^{
    __block CKLCampfireAuthorizedAccount *account;
    __block CKLCampfireRoom *room;
    beforeAll(^{
        [CKLSpecHelpers setUp];

        // Stub authorized account
        account = [CKLCampfireAuthorizedAccount new];
        [account setValuesForKeysWithDictionary:[CKLSpecHelpers accountProperties]];

        // Stub rooms
        room = [CKLCampfireRoom new];
        room.viewingAccount = account;
        [room setValuesForKeysWithDictionary:@{
            @"roomID": @"1",
            @"name": @"North May St.",
            @"topic": @"37signals HQ",
            @"membershipLimit": @60,
            @"creationDate": [[CKLCampfireAPI dateTransformer] transformedValue:@"2009-11-17T19:41:38Z"],
            @"updatedDate": [[CKLCampfireAPI dateTransformer] transformedValue:@"2009-11-17T19:41:38Z"],
            @"full": @NO,
            @"locked": @NO
        }];
    });
    afterAll(^{
        [CKLSpecHelpers tearDown];
    });
    context(@"when getting the list of visible rooms", ^{
        __block NSArray *rooms;
        beforeAll(^{
            rooms = @[room];
            [CKLSpecHelpers stub:[NSString stringWithFormat:CAMPFIRE_API_ROOMS]];
        });
        it(@"should be able parse the rooms returned", ^{
            __block NSArray *visibleRooms;
            [CKLCampfireAPI getVisibleRoomsForAccount:account responseBlock:^(NSArray *array, NSError *error) {
                visibleRooms = array;
            }];
            [[expectFutureValue(visibleRooms) shouldEventually] equal:rooms];
        });
    });
    context(@"when getting the info for a single room", ^{
        beforeAll(^{
            // Stub user list for room
            CKLCampfireUser *user = [CKLCampfireUser new];
            [user setValuesForKeysWithDictionary:@{
                @"userID": @"1",
                @"name": @"Jason Fried",
                @"emailAddress": @"jason@37signals.com",
                @"avatarURL": [NSURL URLWithString:@"http://asset0.37img.com/global/.../avatar.png"],
                @"joinDate": [[CKLCampfireAPI dateTransformer] transformedValue:@"2009-11-20T16:41:39Z"],
                @"type": @(CKLCampfireUserTypeMember),
                @"admin": @YES
            }];
            [room setValue:@[user] forKey:@"users"];

            // Stub room info request
            [CKLSpecHelpers stub:[NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID, room.roomID]];
        });
        it(@"should be able to parse the info returned", ^{
            __block CKLCampfireRoom *infoRoom;
            [CKLCampfireAPI getInfoForRoom:room responseBlock:^(CKLCampfireRoom *room, NSError *error) {
                infoRoom = room;
            }];
            [[expectFutureValue(infoRoom) shouldEventually] equal:room];
        });
    });
    context(@"when updating a room", ^{
        __block CKLCampfireRoom *room;
        __block NSString *name, *originalName;
        __block NSString *topic, *originalTopic;
        beforeAll(^{
            room = [CKLCampfireRoom new];
            [room setValue:@"1" forKey:@"roomID"];
            room.viewingAccount = account;

            name = @"New Room";
            topic = @"The new topic;";
        });
        beforeEach(^{
            originalName = @"Original Room";
            originalTopic = @"The original topic.";
            [room setValue:originalName forKey:@"name"];
            [room setValue:originalTopic forKey:@"topic"];
        });
        context(@"under successful network conditions", ^{
            beforeAll(^{
                // Stub update room request
                [CKLSpecHelpers stub:[NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID, room.roomID]];
            });
            it(@"should change its name and topic", ^{
                [CKLCampfireAPI updateRoom:room withName:name topic:topic responseBlock:^(NSError *error) {
                    return;
                }];
                [[room.name should] equal:name];
                [[room.topic should] equal:topic];
            });
        });
        context(@"under unsuccessful network conditions", ^{
            beforeAll(^{
                // Stub update room request
                [CKLSpecHelpers stubWithNetworkFailure:[NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID, room.roomID]];
            });
            it(@"should keep its original name and topic", ^{
                [CKLCampfireAPI updateRoom:room withName:name topic:topic responseBlock:^(NSError *error) {
                    return;
                }];
                [[expectFutureValue(room.name) shouldEventually] equal:originalName];
                [[expectFutureValue(room.topic) shouldEventually] equal:originalTopic];
            });
        });
    });
    context(@"when locking an unlocked room", ^{
        __block CKLCampfireRoom *room;
        beforeAll(^{
            room = [CKLCampfireRoom new];
            [room setValue:@"1" forKey:@"roomID"];
            room.viewingAccount = account;
        });
        beforeEach(^{
            [room setValue:@NO forKey:@"locked"];
        });
        context(@"under successful network conditions", ^{
            beforeAll(^{
                // Stub room lock request
                [CKLSpecHelpers stub:[NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID_LOCK, room.roomID] andReturn:nil];
            });
            it(@"should become locked", ^{
                [CKLCampfireAPI lockRoom:room responseBlock:^(NSError *error) {
                    return;
                }];
                [[theValue(room.locked) should] equal:theValue(YES)];
            });
        });
        context(@"under unsuccessful network conditions", ^{
          beforeAll(^{
              // Stub room lock request
              [CKLSpecHelpers stubWithNetworkFailure:[NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID_LOCK, room.roomID]];
          });
          it(@"should not become locked", ^{
              [CKLCampfireAPI lockRoom:room responseBlock:^(NSError *error) {
                  return;
              }];
              [[expectFutureValue(theValue(room.locked)) shouldEventually] equal:theValue(NO)];
          });
        });
    });
    context(@"when unlocking a locked room", ^{
        __block CKLCampfireRoom *room;
        beforeAll(^{
            room = [CKLCampfireRoom new];
            [room setValue:@"29" forKey:@"roomID"];
            room.viewingAccount = account;
        });
        beforeEach(^{
            [room setValue:@YES forKey:@"locked"];
        });
        context(@"under successful network conditions", ^{
            beforeAll(^{
                // Stub room unlock request
                [CKLSpecHelpers stub:[NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID_LOCK, room.roomID] andReturn:nil];
            });
            it(@"should become unlocked", ^{
                [CKLCampfireAPI unlockRoom:room responseBlock:^(NSError *error) {
                    return;
                }];
                [[theValue(room.locked) should] equal:theValue(NO)];
            });
        });
        context(@"under unsuccessful network conditions", ^{
            beforeAll(^{
                // Stub room unlock request
                [CKLSpecHelpers stubWithNetworkFailure:[NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID_LOCK, room.roomID]];
            });
            it(@"should not become unlocked", ^{
                [CKLCampfireAPI lockRoom:room responseBlock:^(NSError *error) {
                    return;
                }];
                [[expectFutureValue(theValue(room.locked)) shouldEventually] equal:theValue(YES)];
            });
        });
    });
    context(@"when registering to use a subclass for rooms", ^{
        beforeAll(^{
            [CKLCampfireAPI registerSubclass:[CKLCampfireRoomSubclass class] forModelClass:[CKLCampfireRoom class]];
        });
        it(@"should use that subclass", ^{
            __block NSSet *classes;
            [CKLCampfireAPI getVisibleRoomsForAccount:account responseBlock:^(NSArray *array, NSError *error) {
                classes = [NSSet setWithArray:[array valueForKeyPath:@"class"]];
            }];
            [[expectFutureValue([classes allObjects]) shouldEventually] equal:@[[CKLCampfireRoomSubclass class]]];
        });
    });
});

SPEC_END
