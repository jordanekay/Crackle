//
//  CKLUploadSpec.m
//  Crackle
//
//  Created by Jordan Kay on 1/4/14.
//  Copyright (c) 2014 Jordan Kay. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "CKLCampfireAPI.h"
#import "CKLCampfireAPI+Endpoints.h"
#import "CKLCampfireMessage.h"
#import "CKLCampfireRoom.h"
#import "CKLCampfireUpload.h"
#import "CKLSpecHelpers.h"

@interface CKLCampfireUploadSubclass : CKLCampfireUpload

@end

@implementation CKLCampfireUploadSubclass

@end

SPEC_BEGIN(CKLUploadSpec)

describe(@"The API instance", ^{
    __block CKLCampfireAuthorizedAccount *account;
    __block CKLCampfireRoom *room;
    beforeAll(^{
        [CKLSpecHelpers setUp];

        // Stub authorized account
        account = [CKLCampfireAuthorizedAccount new];
        [account setValuesForKeysWithDictionary:[CKLSpecHelpers accountProperties]];

        // Stub room
        room = [CKLCampfireRoom new];
        [room setValue:@"1" forKey:@"roomID"];
        room.viewingAccount = account;
    });
    afterAll(^{
        [CKLSpecHelpers tearDown];
    });
    context(@"when uploading an image", ^{
        __block CKLCampfireUpload *upload;
        beforeAll(^{
            // Stub upload
            upload = [CKLCampfireUpload new];
            [upload setValuesForKeysWithDictionary:@{
                @"uploadID": @"1",
                @"userID": @"1",
                @"name": @"me.jpg",
                @"contentType": @"image/jpeg",
                @"creationDate": [[CKLCampfireAPI dateTransformer] transformedValue:@"2009-11-20T23:26:51Z"],
                @"url": [NSURL URLWithString:@"https://account.campfirenow.com/room/1/uploads/1/me.jpg"],
                @"size": @(8922),
                @"room": room
            }];

            // Stub create upload request
            [CKLSpecHelpers stub:[NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID_UPLOADS, room.roomID] andReturn:[NSString stringWithFormat:@"room_%@_uploads_create.xml", room.roomID]];
        });
        it(@"should be able to parse the response as an upload", ^{
            __block CKLCampfireUpload *postedUpload;
            UIImage *image = [UIImage imageNamed:@"image"];
            [CKLCampfireAPI uploadImage:image toRoom:room responseBlock:^(CKLCampfireUpload *upload, NSError *error) {
                postedUpload = upload;
            }];
            [[expectFutureValue(postedUpload) shouldEventually] equal:upload];
        });
    });
    context(@"when getting uploads from a room", ^{
        __block NSArray *uploads;
        beforeAll(^{
            // Stub uploads
            NSDictionary *properties = @{
                @"uploadID": @"1",
                @"userID": @"1",
                @"name": @"char.rb",
                @"contentType": @"application/octet-stream",
                @"creationDate": [[CKLCampfireAPI dateTransformer] transformedValue:@"2009-11-20T23:26:51Z"],
                @"url": [NSURL URLWithString:@"https://account.campfirenow.com/room/1/uploads/4/char.rb"],
                @"size": @(135),
            };
            uploads = @[[CKLCampfireUpload new]];
            [[uploads firstObject] setValuesForKeysWithDictionary:properties];
            [CKLCampfireUpload stub:@selector(propertyKeys) andReturn:[properties allKeys]];
        });
        context(@"when fetching recent across all messages", ^{
            beforeAll(^{
                // Stub room info and upload requests
                [CKLSpecHelpers stub:[NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID, room.roomID]];
                [CKLSpecHelpers stub:[NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID_UPLOADS, room.roomID]];
            });
            it(@"should be able to parse the uploads returned", ^{
                __block NSArray *fetchedUploads;
                [CKLCampfireAPI getRecentUploadsForRoom:room responseBlock:^(NSArray *array, NSError *error) {
                    fetchedUploads = array;
                }];
                [[expectFutureValue(fetchedUploads) shouldEventually] equal:uploads];
            });
        });
        context(@"when getting the upload for a message", ^{
            __block CKLCampfireMessage *message;
            beforeAll(^{
                // Stub message
                message = [CKLCampfireMessage new];
                [message setValue:room forKey:@"room"];
                [message setValue:@"28" forKey:@"messageID"];
                [CKLSpecHelpers stub:[NSString stringWithFormat:CAMPFIRE_API_ROOM_ROOMID_MESSAGES_MESSAGEID_UPLOAD, room.roomID, message.messageID]];
            });
            it(@"should be able to parse the upload returned", ^{
                __block CKLCampfireUpload *fetchedUpload;
                [CKLCampfireAPI getUploadForMessage:message responseBlock:^(CKLCampfireUpload *upload, NSError *error) {
                    fetchedUpload = upload;
                }];
                [[expectFutureValue(fetchedUpload) shouldEventually] equal:[uploads firstObject]];
            });
        });
    });
    context(@"when registering to use a subclass for uploads", ^{
        beforeAll(^{
            [CKLCampfireAPI registerSubclass:[CKLCampfireUploadSubclass class] forModelClass:[CKLCampfireUpload class]];
        });
        it(@"should use that subclass", ^{
            __block NSSet *classes;
            [CKLCampfireAPI getRecentUploadsForRoom:room responseBlock:^(NSArray *array, NSError *error) {
                classes = [NSSet setWithArray:[array valueForKeyPath:@"class"]];
            }];
            [[expectFutureValue([classes allObjects]) shouldEventually] equal:@[[CKLCampfireUploadSubclass class]]];
        });
    });
});

SPEC_END
