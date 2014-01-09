//
//  CKLCampfireAPI+Account.m
//  Crackle
//
//  Created by Jordan Kay on 12/25/13.
//  Copyright (c) 2013 Jordan Kay. All rights reserved.
//

#import "CKLCampfireAccount.h"
#import "CKLCampfireAPI.h"
#import "CKLCampfireAPI+Endpoints.h"
#import "CKLCampfireAPI+Private.h"

@implementation CKLCampfireAPI (Account)

+ (void)getInfoForAccount:(CKLCampfireAuthorizedAccount *)account responseBlock:(CKLCampfireAPIAccountResponseBlock)responseBlock
{
    [[self sharedInstance] getResource:CAMPFIRE_API_ACCOUNT forAccount:account withParameters:nil responseBlock:^(id responseObject, NSError *error) {
        [self processResponseObject:responseObject ofType:[CKLCampfireAccount class] error:error processBlock:nil responseBlock:responseBlock];
    }];
}

@end
