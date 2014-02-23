//
//  CKLCampfireAPI.h
//  Crackle
//
//  Created by Jordan Kay on 12/25/13.
//  Copyright (c) 2013 Jordan Kay. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "CKLCampfireAccount.h"

@class CKLCampfireMessage;
@class CKLCampfireRoom;
@class CKLCampfireUpload;
@class CKLCampfireUser;

@protocol CKLCampfireAPIAuthenticatedAccess;

typedef void (^CKLCampfireAPIErrorBlock)(NSError *error);
typedef void (^CKLCampfireAPIResponseBlock)(id responseObject, NSError *error);
typedef void (^CKLCampfireAPIProcessBlock)(id object);

typedef void (^CKLCampfireAPIAccountResponseBlock)(CKLCampfireAccount *account, NSError *error);
typedef void (^CKLCampfireAPIArrayResponseBlock)(NSArray *array, NSError *error);
typedef void (^CKLCampfireAPIMessageResponseBlock)(CKLCampfireMessage *message, NSError *error);
typedef void (^CKLCampfireAPIRoomResponseBlock)(CKLCampfireRoom *room, NSError *error);
typedef void (^CKLCampfireAPIUploadResponseBlock)(CKLCampfireUpload *upload, NSError *error);
typedef void (^CKLCampfireAPIUserResponseBlock)(CKLCampfireUser *user, NSError *error);

extern NSString *CKLCampfireAPIAccessTokenKey;
extern NSString *CKLCampfireAPIWebViewWillLoadAuthorizationRequestNotification;
extern NSString *CKLCampfireAPIWebViewDidLoadAuthorizationRequestNotification;
extern NSString *CKLCampfireAPIDidAuthorizeAccountNotification;

@interface CKLCampfireAPI : NSObject

+ (void)registerSubclass:(Class)subclass forModelClass:(Class)class;
+ (void)deregisterSubclassForModelClass:(Class)class;

+ (NSValueTransformer *)dateTransformer;
+ (NSValueTransformer *)streamingDateTransformer;

@end

@interface CKLCampfireAPI (Account)

+ (void)getInfoForAccount:(CKLCampfireAuthorizedAccount *)account responseBlock:(CKLCampfireAPIAccountResponseBlock)responseBlock;

@end

@interface CKLCampfireAccount (Authorization)

@property (nonatomic) CKLCampfireToken *accessToken;

@end

@interface CKLCampfireToken : MTLModel <NSSecureCoding>

@property (nonatomic, copy, readonly) NSString *accessTokenString;
@property (nonatomic, copy, readonly) NSString *apiTokenString;

@end

@protocol CKLCampfireAPIAuthenticatedAccess <NSObject>

@property (nonatomic) CKLCampfireAuthorizedAccount *viewingAccount;

@end

@interface CKLCampfireAPI (Authorization)

+ (NSURLRequest *)authorizeWithWebView:(UIWebView *)webView;
+ (void)deauthorizeAccount:(CKLCampfireAuthorizedAccount *)account;
+ (void)setClientID:(NSString *)key secret:(NSString *)secret redirectURI:(NSString *)uri;

@end

@interface CKLCampfireAPI (Message)

+ (void)getRecentMessagesForRoom:(CKLCampfireRoom *)room responseBlock:(CKLCampfireAPIArrayResponseBlock)responseBlock;
+ (void)getRecentMessagesForRoom:(CKLCampfireRoom *)room sinceMessage:(CKLCampfireMessage *)message responseBlock:(CKLCampfireAPIArrayResponseBlock)responseBlock;
+ (void)getRecentMessagesForRoom:(CKLCampfireRoom *)room sinceMessage:(CKLCampfireMessage *)message withLimit:(NSInteger)limit responseBlock:(CKLCampfireAPIArrayResponseBlock)responseBlock;

+ (void)getTodaysMessagesForRoom:(CKLCampfireRoom *)room responseBlock:(CKLCampfireAPIArrayResponseBlock)responseBlock;
+ (void)getMessagesForRoom:(CKLCampfireRoom *)room fromDate:(NSDate *)date responseBlock:(CKLCampfireAPIArrayResponseBlock)responseBlock;
+ (void)getMessagesWithQuery:(NSString *)query account:(CKLCampfireAuthorizedAccount *)account responseBlock:(CKLCampfireAPIArrayResponseBlock)responseBlock;

+ (void)sendMessage:(CKLCampfireMessage *)message toRoom:(CKLCampfireRoom *)room responseBlock:(CKLCampfireAPIMessageResponseBlock)responseBlock;
+ (void)starMessage:(CKLCampfireMessage *)message responseBlock:(CKLCampfireAPIErrorBlock)responseBlock;

+ (void)streamMessagesInRoom:(CKLCampfireRoom *)room responseBlock:(CKLCampfireAPIMessageResponseBlock)responseBlock;

@end

@interface CKLCampfireAPI (Room)

+ (void)joinRoom:(CKLCampfireRoom *)room responseBlock:(CKLCampfireAPIErrorBlock)responseBlock;
+ (void)leaveRoom:(CKLCampfireRoom *)room responseBlock:(CKLCampfireAPIErrorBlock)responseBlock;
+ (void)lockRoom:(CKLCampfireRoom *)room responseBlock:(CKLCampfireAPIErrorBlock)responseBlock;
+ (void)unlockRoom:(CKLCampfireRoom *)room responseBlock:(CKLCampfireAPIErrorBlock)responseBlock;
+ (void)updateRoom:(CKLCampfireRoom *)room withName:(NSString *)name topic:(NSString *)topic responseBlock:(CKLCampfireAPIErrorBlock)responseBlock;

+ (void)getInfoForRoom:(CKLCampfireRoom *)room responseBlock:(CKLCampfireAPIRoomResponseBlock)responseBlock;
+ (void)getVisibleRoomsForAccount:(CKLCampfireAuthorizedAccount *)account responseBlock:(CKLCampfireAPIArrayResponseBlock)responseBlock;
+ (void)getActiveRoomsForAccount:(CKLCampfireAuthorizedAccount *)account responseBlock:(CKLCampfireAPIArrayResponseBlock)responseBlock;

@end

@interface CKLCampfireAPI (Upload)

+ (void)uploadImage:(UIImage *)image toRoom:(CKLCampfireRoom *)room responseBlock:(CKLCampfireAPIUploadResponseBlock)responseBlock;
+ (void)getUploadForMessage:(CKLCampfireMessage *)message responseBlock:(CKLCampfireAPIUploadResponseBlock)responseBlock;
+ (void)getRecentUploadsForRoom:(CKLCampfireRoom *)room responseBlock:(CKLCampfireAPIArrayResponseBlock)responseBlock;

@end

@interface CKLCampfireAPI (User)

+ (void)getInfoForUserForCurrentAccount:(CKLCampfireAuthorizedAccount *)account responseBlock:(CKLCampfireAPIUserResponseBlock)responseBlock;
+ (void)getInfoForUser:(CKLCampfireUser *)user viewedByCurrentAccount:(CKLCampfireAuthorizedAccount *)account responseBlock:(CKLCampfireAPIUserResponseBlock)responseBlock;

@end
