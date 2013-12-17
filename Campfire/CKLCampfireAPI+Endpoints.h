//
//  CKLCampfireAPI+Endpoints.h
//  Crackle
//
//  Created by Jordan Kay on 12/26/13.
//  Copyright (c) 2013 Jordan Kay. All rights reserved.
//

// Account
#define CAMPFIRE_API_ACCOUNT @"account.xml"

// Authorization
#define CAMPFIRE_API_AUTHORIZATION @"authorization.xml"

// Messages
#define CAMPFIRE_API_MESSAGES_MESSAGEID_STAR @"messages/%@/star.xml"
#define CAMPFIRE_API_ROOM_ROOMID_SPEAK @"room/%@/speak.xml"
#define CAMPFIRE_API_ROOM_ROOMID_RECENT @"room/%@/recent.xml"

// Rooms
#define CAMPFIRE_API_PRESENCE @"presence.xml"
#define CAMPFIRE_API_ROOMS @"rooms.xml"
#define CAMPFIRE_API_ROOM_ROOMID @"room/%@.xml"
#define CAMPFIRE_API_ROOM_ROOMID_JOIN @"room/%@/join.xml"
#define CAMPFIRE_API_ROOM_ROOMID_LEAVE @"room/%@/leave.xml"
#define CAMPFIRE_API_ROOM_ROOMID_LOCK @"room/%@/lock.xml"
#define CAMPFIRE_API_ROOM_ROOMID_UNLOCK @"room/%@/unlock.xml"

// Search
#define CAMPFIRE_API_SEARCH @"search"

// Streaming
#define CAMPFIRE_API_ROOM_ROOMID_LIVE @"room/%@/live.json"

// Transcripts
#define CAMPFIRE_API_ROOM_ROOMID_TRANSCRIPT @"room/%@/transcript.xml"
#define CAMPFIRE_API_ROOM_ROOMID_TRANSCRIPT_YEAR_MONTH_DAY @"room/%@/transcript/%ld/%ld/%ld.xml"

// Uploads
#define CAMPFIRE_API_ROOM_ROOMID_UPLOADS @"room/%@/uploads.xml"
#define CAMPFIRE_API_ROOM_ROOMID_MESSAGES_MESSAGEID_UPLOAD @"room/%@/messages/%@/upload.xml"

// Users
#define CAMPFIRE_API_USERS_USERID @"users/%@.xml"
#define CAMPFIRE_API_USERS_ME @"users/me.xml"
