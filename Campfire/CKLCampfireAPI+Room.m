//
//  CKLCampfireAPI+Room.m
//  Crackle
//
//  Created by Jordan Kay on 12/25/13.
//  Copyright (c) 2013 Jordan Kay. All rights reserved.
//

#import "CKLCampfireAccount.h"
#import "CKLCampfireAPI+Endpoints.h"
#import "CKLCampfireAPI+Private.h"
#import "CKLCampfireRoom.h"

@interface CKLCampfireRoom ()

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *topic;
@property (nonatomic, getter = isLocked) BOOL locked;

@end

@implementation CKLCampfireAPI (Room)

+ (void)joinRoom:(CKLCampfireRoom *)room responseBlock:(CKLCampfireAPIErrorBlock)responseBlock
{
    NSString *resource = [NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID_JOIN, room.roomID];
    [self _postResource:resource forRoom:room responseBlock:responseBlock];
}

+ (void)leaveRoom:(CKLCampfireRoom *)room responseBlock:(CKLCampfireAPIErrorBlock)responseBlock
{
    NSString *resource = [NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID_LEAVE, room.roomID];
    [self _postResource:resource forRoom:room responseBlock:responseBlock];

    room.viewingAccount = nil;
}

+ (void)lockRoom:(CKLCampfireRoom *)room responseBlock:(CKLCampfireAPIErrorBlock)responseBlock;
{
    if (!room.isLocked) {
        room.locked = YES;
        NSString *resource = [NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID_LOCK, room.roomID];
        [self _postResource:resource forRoom:room responseBlock:^(NSError *error) {
            if (error) {
                room.locked = NO;
            }
            responseBlock(error);
        }];
    }
}

+ (void)unlockRoom:(CKLCampfireRoom *)room responseBlock:(CKLCampfireAPIErrorBlock)responseBlock;
{
    if (room.isLocked) {
        room.locked = NO;
        NSString *resource = [NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID_UNLOCK, room.roomID];
        [self _postResource:resource forRoom:room responseBlock:^(NSError *error) {
            if (error) {
                room.locked = YES;
            }
            responseBlock(error);
        }];
    }
}

+ (void)updateRoom:(CKLCampfireRoom *)room withName:(NSString *)name topic:(NSString *)topic responseBlock:(CKLCampfireAPIErrorBlock)responseBlock
{
    NSString *currentName = room.name;
    NSString *currentTopic = room.topic;
    room.name = name;
    room.topic = topic;

    NSString *resource = [NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID, room.roomID];
    NSDictionary *parameters = @{@"room": [CKLCampfireRoom editParametersForName:name topic:topic]};
    [[self sharedInstance] putResource:resource forAccount:room.viewingAccount withParameters:parameters responseBlock:^(id responseObject, NSError *error) {
        if (error) {
            room.name = currentName;
            room.topic = currentTopic;
        }
        responseBlock(error);
    }];
}

+ (void)getInfoForRoom:(CKLCampfireRoom *)room responseBlock:(CKLCampfireAPIRoomResponseBlock)responseBlock
{
    NSString *resource = [NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID, room.roomID];
    [self _getRoomsForResource:resource multiple:NO account:room.viewingAccount responseBlock:responseBlock];
}

+ (void)getVisibleRoomsForAccount:(CKLCampfireAuthorizedAccount *)account responseBlock:(CKLCampfireAPIArrayResponseBlock)responseBlock
{
    [self _getRoomsForResource:CAMPFIRE_API_ROOMS multiple:YES account:account responseBlock:responseBlock];
}

+ (void)getActiveRoomsForAccount:(CKLCampfireAuthorizedAccount *)account responseBlock:(CKLCampfireAPIArrayResponseBlock)responseBlock
{
    [self _getRoomsForResource:CAMPFIRE_API_PRESENCE multiple:YES account:account responseBlock:responseBlock];
}

+ (void)_getRoomsForResource:(NSString *)resource multiple:(BOOL)multiple account:(CKLCampfireAuthorizedAccount *)account responseBlock:(CKLCampfireAPIResponseBlock)responseBlock

{
    [[self sharedInstance] getResource:resource forAccount:account withParameters:nil responseBlock:^(id responseObject, NSError *error) {
        [self processResponseObject:responseObject ofType:[CKLCampfireRoom class] key:@"room" idKey:@"roomID" multiple:multiple error:error processBlock:^(CKLCampfireRoom *room) {
            room.viewingAccount = account;
        } responseBlock:responseBlock];
    }];
}

+ (void)_postResource:(NSString *)resource forRoom:(CKLCampfireRoom *)room responseBlock:(CKLCampfireAPIErrorBlock)responseBlock
{
    [[self sharedInstance] postResource:resource forAccount:room.viewingAccount withParameters:nil responseBlock:^(id responseObject, NSError *error) {
        responseBlock(error);
    }];
}

@end
