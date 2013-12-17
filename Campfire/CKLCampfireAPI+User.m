//
//  CKLCampfireAPI+User.m
//  Crackle
//
//  Created by Jordan Kay on 12/25/13.
//  Copyright (c) 2013 Jordan Kay. All rights reserved.
//

#import "CKLCampfireAPI.h"
#import "CKLCampfireAPI+Endpoints.h"
#import "CKLCampfireAPI+Private.h"
#import "CKLCampfireUser.h"

@implementation CKLCampfireAPI (User)

+ (void)getInfoForUserForCurrentAccount:(CKLCampfireAuthorizedAccount *)account responseBlock:(CKLCampfireAPIUserResponseBlock)responseBlock
{
    [self _getResource:CAMPFIRE_API_USERS_ME forAccount:account responseBlock:responseBlock];
}

+ (void)getInfoForUser:(CKLCampfireUser *)user viewedByCurrentAccount:(CKLCampfireAuthorizedAccount *)account responseBlock:(CKLCampfireAPIUserResponseBlock)responseBlock
{
    NSString *resource = [NSString stringWithFormat:CAMPFIRE_API_USERS_USERID, user.userID];
    [self _getResource:resource forAccount:account responseBlock:responseBlock];
}

+ (void)_getResource:(NSString *)resource forAccount:(CKLCampfireAuthorizedAccount *)account responseBlock:(CKLCampfireAPIUserResponseBlock)responseBlock
{
    [[CKLCampfireAPI sharedInstance] getResource:resource forAccount:account withParameters:nil responseBlock:^(id responseObject, NSError *error) {
        [CKLCampfireAPI processResponseObject:responseObject ofType:[CKLCampfireUser class] error:error processBlock:nil responseBlock:responseBlock];
    }];
}

@end
