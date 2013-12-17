//
//  CKLCampfireMessage.h
//  Crackle
//
//  Created by Jordan Kay on 12/26/13.
//  Copyright (c) 2013 Jordan Kay. All rights reserved.
//

#import <Mantle/MTLModel.h>
#import <Mantle/MTLJSONAdapter.h>
#import "CKLCampfireAPI.h"

@class CKLCampfireRoom;
@class CKLCampfireTweet;
@class CKLCampfireUser;

typedef NS_ENUM(NSUInteger, CKLCampfireMessageType) {
    CKLCampfireMessageTypeAdvertisement,
    CKLCampfireMessageTypeAllowGuests,
    CKLCampfireMessageTypeConferenceCreated,
    CKLCampfireMessageTypeConferenceFinished,
    CKLCampfireMessageTypeDisallowGuests,
    CKLCampfireMessageTypeEnter,
    CKLCampfireMessageTypeIdle,
    CKLCampfireMessageTypeKick,
    CKLCampfireMessageTypeLeave,
    CKLCampfireMessageTypeLock,
    CKLCampfireMessageTypePaste,
    CKLCampfireMessageTypeSound,
    CKLCampfireMessageTypeSystem,
    CKLCampfireMessageTypeText,
    CKLCampfireMessageTypeTimestamp,
    CKLCampfireMessageTypeTopicChanged,
    CKLCampfireMessageTypeTweet,
    CKLCampfireMessageTypeUnidle,
    CKLCampfireMessageTypeUnlock,
    CKLCampfireMessageTypeUpload
};

@interface CKLCampfireMessage : MTLModel <MTLJSONSerializing, CKLCampfireAPIAuthenticatedAccess>

+ (instancetype)postingMessageWithBody:(NSString *)body ofType:(CKLCampfireMessageType)type;

+ (NSArray *)postKeys;
+ (NSArray *)messageSoundNames;

@property (nonatomic, copy, readonly) NSString *messageID;
@property (nonatomic, copy, readonly) NSString *userID;
@property (nonatomic, copy, readonly) NSString *body;
@property (nonatomic, readonly) NSDate *creationDate;
@property (nonatomic, readonly) CKLCampfireRoom *room;
@property (nonatomic, readonly) CKLCampfireUser *user;
@property (nonatomic, readonly) CKLCampfireMessageType type;
@property (nonatomic, readonly) CKLCampfireTweet *tweet;
@property (nonatomic, copy, readonly) NSString *eventDescription;
@property (nonatomic, readonly) NSURL *eventURL;
@property (nonatomic, readonly, getter = isStarred) BOOL starred;

@end

@interface CKLCampfireStreamedMessage : CKLCampfireMessage

@end
