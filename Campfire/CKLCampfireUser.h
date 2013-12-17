//
//  CKLCampfireUser.h
//  Crackle
//
//  Created by Jordan Kay on 12/26/13.
//  Copyright (c) 2013 Jordan Kay. All rights reserved.
//

#import <Mantle/MTLModel.h>
#import <Mantle/MTLJSONAdapter.h>

typedef NS_ENUM(NSUInteger, CKLCampfireUserType) {
    CKLCampfireUserTypeMember,
    CKLCampfireUserTypeGuest
};

@interface CKLCampfireUser : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *userID;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *emailAddress;
@property (nonatomic, readonly) NSURL *avatarURL;
@property (nonatomic, readonly) NSDate *joinDate;
@property (nonatomic, readonly) CKLCampfireUserType type;
@property (nonatomic, readonly, getter = isAdmin) BOOL admin;

@end
