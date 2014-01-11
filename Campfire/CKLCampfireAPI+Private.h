//
//  CKLCampfireAPI+Private.h
//  Crackle
//
//  Created by Jordan Kay on 12/25/13.
//  Copyright (c) 2013 Jordan Kay. All rights reserved.
//

#import "CKLCampfireAPI.h"

@class CKLCampfireAccount;

@interface CKLCampfireAPI (Private)

+ (instancetype)sharedInstance;
+ (Class)subclassForModelClass:(Class)class;

+ (void)processResponseObject:(id)responseObject ofType:(Class)type error:(NSError *)error processBlock:(CKLCampfireAPIProcessBlock)processBlock responseBlock:(CKLCampfireAPIResponseBlock)responseBlock;
+ (void)processResponseObject:(id)responseObject ofType:(Class)type key:(NSString *)key idKey:(NSString *)idKey multiple:(BOOL)multiple error:(NSError *)error processBlock:(CKLCampfireAPIProcessBlock)processBlock responseBlock:(CKLCampfireAPIResponseBlock)responseBlock;

- (void)getResource:(NSString *)resource forAccount:(CKLCampfireAuthorizedAccount *)account withParameters:(NSDictionary *)parameters responseBlock:(CKLCampfireAPIResponseBlock)responseBlock;
- (void)streamResource:(NSString *)resource forAccount:(CKLCampfireAuthorizedAccount *)account withParameters:(NSDictionary *)parameters responseBlock:(CKLCampfireAPIResponseBlock)responseBlock;
- (void)postResource:(NSString *)resource forAccount:(CKLCampfireAuthorizedAccount *)account withParameters:(NSDictionary *)parameters responseBlock:(CKLCampfireAPIResponseBlock)responseBlock;
- (void)postResource:(NSString *)resource withFormData:(NSData *)data name:(NSString *)name forAccount:(CKLCampfireAuthorizedAccount *)account withParameters:(NSDictionary *)parameters responseBlock:(CKLCampfireAPIResponseBlock)responseBlock;
- (void)putResource:(NSString *)resource forAccount:(CKLCampfireAuthorizedAccount *)account withParameters:(NSDictionary *)parameters responseBlock:(CKLCampfireAPIResponseBlock)responseBlock;
- (void)deleteResource:(NSString *)resource forAccount:(CKLCampfireAuthorizedAccount *)account withParameters:(NSDictionary *)parameters responseBlock:(CKLCampfireAPIResponseBlock)responseBlock;

@end
