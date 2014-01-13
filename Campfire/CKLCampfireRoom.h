//
//  CKLCampfireRoom.h
//  Crackle
//
//  Created by Jordan Kay on 12/26/13.
//  Copyright (c) 2013 Jordan Kay. All rights reserved.
//

#import "CKLCampfireAPI.h"

@interface CKLCampfireRoom : MTLModel <MTLJSONSerializing, CKLCampfireAPIAuthenticatedAccess>

+ (NSDictionary *)editParametersForName:(NSString *)name topic:(NSString *)topic;

@property (nonatomic, copy, readonly) NSString *roomID;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *topic;
@property (nonatomic, readonly) NSInteger membershipLimit;
@property (nonatomic, readonly) NSDate *creationDate;
@property (nonatomic, readonly) NSDate *updatedDate;
@property (nonatomic, copy, readonly) NSArray *users;
@property (nonatomic, readonly, getter = isFull) BOOL full;
@property (nonatomic, readonly, getter = isLocked) BOOL locked;

@end
