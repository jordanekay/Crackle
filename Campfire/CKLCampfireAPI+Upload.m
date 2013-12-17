//
//  CKLCampfireAPI+Upload.m
//  Crackle
//
//  Created by Jordan Kay on 12/25/13.
//  Copyright (c) 2013 Jordan Kay. All rights reserved.
//

#import "CKLCampfireAPI.h"
#import "CKLCampfireAPI+Endpoints.h"
#import "CKLCampfireAPI+Private.h"
#import "CKLCampfireMessage.h"
#import "CKLCampfireRoom.h"
#import "CKLCampfireUpload.h"

#define IMAGE_COMPRESSION_QUALITY 0.5f

@interface CKLCampfireUpload ()

@property (nonatomic) CKLCampfireRoom *room;

@end

@implementation CKLCampfireAPI (Upload)

+ (void)uploadImage:(UIImage *)image toRoom:(CKLCampfireRoom *)room responseBlock:(CKLCampfireAPIUploadResponseBlock)responseBlock
{
    NSString *resource = [NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID_UPLOADS, room.roomID];
    NSData *imageData = UIImageJPEGRepresentation(image, IMAGE_COMPRESSION_QUALITY);
    [[CKLCampfireAPI sharedInstance] postResource:resource withFormData:imageData name:@"upload" forAccount:room.viewingAccount withParameters:nil responseBlock:^(id responseObject, NSError *error) {
        [CKLCampfireAPI processResponseObject:responseObject ofType:[CKLCampfireUpload class] error:error processBlock:^(CKLCampfireUpload *upload) {
            upload.room = room;
        } responseBlock:responseBlock];
    }];
}

+ (void)getUploadForMessage:(CKLCampfireMessage *)message responseBlock:(CKLCampfireAPIUploadResponseBlock)responseBlock
{
    NSString *resource = [NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID_MESSAGES_MESSAGEID_UPLOAD, message.room.roomID, message.messageID];
    [self _getUploadsForResource:resource multiple:NO account:message.viewingAccount room:nil responseBlock:responseBlock];
}

+ (void)getRecentUploadsForRoom:(CKLCampfireRoom *)room responseBlock:(CKLCampfireAPIArrayResponseBlock)responseBlock
{
    NSString *resource = [NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID_UPLOADS, room.roomID];
    [self _getUploadsForResource:resource multiple:YES account:room.viewingAccount room:room responseBlock:responseBlock];
}

+ (void)_getUploadsForResource:(NSString *)resource multiple:(BOOL)multiple account:(CKLCampfireAuthorizedAccount *)account room:(CKLCampfireRoom *)room responseBlock:(CKLCampfireAPIResponseBlock)responseBlock
{
    if (room.users || !room) {
        [[CKLCampfireAPI sharedInstance] getResource:resource forAccount:account withParameters:nil responseBlock:^(id responseObject, NSError *error) {
            [CKLCampfireAPI processResponseObject:responseObject ofType:[CKLCampfireUpload class] key:@"upload" idKey:@"uploadID" multiple:multiple error:error processBlock:^(CKLCampfireUpload *upload) {
                upload.room = room;
            } responseBlock:responseBlock];
        }];
    } else {
        [self getInfoForRoom:room responseBlock:^(CKLCampfireRoom *room, NSError *error) {
            if (room) {
                [self _getUploadsForResource:resource multiple:multiple account:account room:room responseBlock:responseBlock];
            } else {
                responseBlock(nil, error);
            }
        }];
    }
}

@end
