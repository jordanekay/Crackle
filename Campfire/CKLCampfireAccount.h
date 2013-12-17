//
//  CKLCampfireAccount.h
//  Crackle
//
//  Created by Jordan Kay on 12/26/13.
//  Copyright (c) 2013 Jordan Kay. All rights reserved.
//

#import <Mantle/MTLModel.h>
#import <Mantle/MTLJSONAdapter.h>

@class CKLCampfireToken;

typedef NS_ENUM(NSUInteger, CKLCampfireAccountPlan) {
    CKLCampfireAccountPlanBasic,
    CKLCampfireAccountPlanPlus,
    CKLCampfireAccountPlanPremium,
    CKLCampfireAccountPlanMax
};

@interface CKLCampfireAccount : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *accountID;
@property (nonatomic, copy, readonly) NSString *userID;
@property (nonatomic, copy, readonly) NSString *subdomain;
@property (nonatomic, copy, readonly) NSString *organization;
@property (nonatomic, readonly) NSDate *creationDate;
@property (nonatomic, readonly) NSDate *lastUpdatedDate;
@property (nonatomic, readonly) NSTimeZone *timeZone;
@property (nonatomic, readonly) CKLCampfireAccountPlan plan;
@property (nonatomic, readonly) long long storage;

@end

@interface CKLCampfireAuthorizedAccount : CKLCampfireAccount

@property (nonatomic, copy, readonly) NSString *firstName;
@property (nonatomic, copy, readonly) NSString *lastName;
@property (nonatomic, copy, readonly) NSString *emailAddress;
@property (nonatomic, readonly) NSURL *organizationURL;

@end
