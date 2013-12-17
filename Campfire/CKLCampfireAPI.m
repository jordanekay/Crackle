//
//  CKLCampfireAPI.m
//  Crackle
//
//  Created by Jordan Kay on 12/25/13.
//  Copyright (c) 2013 Jordan Kay. All rights reserved.
//

#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <XMLDictionary/XMLDictionary.h>
#import "CKLCampfireAccount.h"
#import "CKLCampfireAPI.h"

#define CAMPFIRE_STREAMING_BASE_URL @"https://streaming.campfirenow.com"
#define DATE_FORMAT_XML @"yyyy-MM-dd'T'HH:mm:ssZZZZ"
#define DATE_FORMAT_JSON @"yyyy/MM/dd HH:mm:ss Z"

typedef void (^CKLCampfireAPIStreamingResponseBlock)(NSData *data);

@interface CKLCampfireAPIStreamingOperation : AFHTTPRequestOperation

+ (instancetype)operationWithRequest:(NSURLRequest *)manager manager:(AFHTTPRequestOperationManager *)manager;

@property (nonatomic, copy) CKLCampfireAPIStreamingResponseBlock responseBlock;

@end

@implementation CKLCampfireAPI
{
    NSMutableDictionary *_networkManagers;
}

+ (instancetype)sharedInstance
{
    static CKLCampfireAPI *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (NSValueTransformer *)dateTransformer
{
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:DATE_FORMAT_XML];
    });

    return [MTLValueTransformer transformerWithBlock:^(NSString *string) {
        return [dateFormatter dateFromString:string];
    }];
}

+ (NSValueTransformer *)streamingDateTransformer
{
    static NSDateFormatter *streamingDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        streamingDateFormatter = [[NSDateFormatter alloc] init];
        [streamingDateFormatter setDateFormat:DATE_FORMAT_JSON];
    });

    return [MTLValueTransformer transformerWithBlock:^(NSString *string) {
        return [streamingDateFormatter dateFromString:string];
    }];
}

+ (void)processResponseObject:(id)responseObject ofType:(Class)type error:(NSError *)error processBlock:(CKLCampfireAPIProcessBlock)processBlock responseBlock:(CKLCampfireAPIResponseBlock)responseBlock
{
    NSObject *object;
    if (responseObject) {
        object = [MTLJSONAdapter modelOfClass:type fromJSONDictionary:responseObject error:nil];
        if (processBlock) {
            processBlock(object);
        }
    }
    responseBlock(object, error);
}

+ (void)processResponseObject:(id)responseObject ofType:(Class)type key:(NSString *)key idKey:(NSString *)idKey multiple:(BOOL)multiple error:(NSError *)error processBlock:(CKLCampfireAPIProcessBlock)processBlock responseBlock:(CKLCampfireAPIResponseBlock)responseBlock
{
    if (responseObject) {
        NSArray *array = responseObject[key];
        if (!array) {
            array = @[responseObject];
        }
        if (![array isKindOfClass:[NSArray class]]) {
            array = @[array];
        }

        NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[array count]];
        for (NSDictionary *dictionary in array) {
            NSObject *object = [MTLJSONAdapter modelOfClass:type fromJSONDictionary:dictionary error:nil];
            if ([object valueForKey:idKey]) {
                if (processBlock) {
                    processBlock(object);
                }
                [objects addObject:object];
            }
        }

        responseBlock(multiple ? objects : [objects firstObject], nil);
    } else {
        responseBlock(nil, error);
    }
}

- (void)getResource:(NSString *)resource forAccount:(CKLCampfireAuthorizedAccount *)account withParameters:(NSDictionary *)parameters responseBlock:(CKLCampfireAPIResponseBlock)responseBlock
{
    [self _prepareForRequestWithAccount:account persistent:NO responseBlock:responseBlock];
    [[self _managerForAccount:account authorized:NO] GET:resource parameters:authenticatedParameters
     (parameters, account) success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self _finishRequestWithResponseData:operation.responseData error:nil responseBlock:responseBlock];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self _finishRequestWithResponseData:nil error:error responseBlock:responseBlock];
    }];
}

- (void)streamResource:(NSString *)resource forAccount:(CKLCampfireAuthorizedAccount *)account withParameters:(NSDictionary *)parameters responseBlock:(CKLCampfireAPIResponseBlock)responseBlock
{
    [self _prepareForRequestWithAccount:account persistent:YES responseBlock:responseBlock];

    NSURL *url = [NSURL URLWithString:resource relativeToURL:[NSURL URLWithString:CAMPFIRE_STREAMING_BASE_URL]];
    AFHTTPRequestOperationManager *manager = [self _managerForAccount:account authorized:YES];
    AFHTTPRequestSerializer *serializer = manager.requestSerializer;
    NSMutableURLRequest *request = [serializer requestWithMethod:@"GET" URLString:[url absoluteString] parameters:parameters];

    CKLCampfireAPIStreamingOperation *operation = [CKLCampfireAPIStreamingOperation operationWithRequest:request manager:manager];
    operation.responseBlock = ^(NSData *data) {
        if ([data length] > 1) {
            NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSArray *chunks = [response componentsSeparatedByString:@"\r"];
            chunks = [chunks subarrayWithRange:NSMakeRange(0, [chunks count] - 1)];

            for (NSString *chunk in chunks) {
                NSData *data = [chunk dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                responseBlock(dictionary, nil);
            }
        }
    };
    [operation setCompletionBlockWithSuccess:nil failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        responseBlock(nil, error);
    }];
    [manager.operationQueue addOperation:operation];
}

- (void)postResource:(NSString *)resource forAccount:(CKLCampfireAuthorizedAccount *)account withParameters:(NSDictionary *)parameters responseBlock:(CKLCampfireAPIResponseBlock)responseBlock
{
    [self _prepareForRequestWithAccount:account persistent:NO responseBlock:responseBlock];
    [[self _managerForAccount:account authorized:NO] POST:resource parameters:authenticatedParameters(parameters, account) success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self _finishRequestWithResponseData:operation.responseData error:nil responseBlock:responseBlock];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self _finishRequestWithResponseData:nil error:error responseBlock:responseBlock];
    }];
}

- (void)postResource:(NSString *)resource withFormData:(NSData *)data name:(NSString *)name forAccount:(CKLCampfireAuthorizedAccount *)account withParameters:(NSDictionary *)parameters responseBlock:(CKLCampfireAPIResponseBlock)responseBlock
{
    [self _prepareForRequestWithAccount:account persistent:NO responseBlock:responseBlock];
    [[self _managerForAccount:account authorized:NO] POST:resource parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:name fileName:@"image.jpeg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self _finishRequestWithResponseData:operation.responseData error:nil responseBlock:responseBlock];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self _finishRequestWithResponseData:nil error:error responseBlock:responseBlock];
    }];
}

- (void)putResource:(NSString *)resource forAccount:(CKLCampfireAuthorizedAccount *)account withParameters:(NSDictionary *)parameters responseBlock:(CKLCampfireAPIResponseBlock)responseBlock
{
    [self _prepareForRequestWithAccount:account persistent:NO responseBlock:responseBlock];
    [[self _managerForAccount:account authorized:NO] PUT:resource parameters:authenticatedParameters(parameters, account) success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self _finishRequestWithResponseData:nil error:nil responseBlock:responseBlock];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self _finishRequestWithResponseData:nil error:error responseBlock:responseBlock];
    }];
}

- (void)deleteResource:(NSString *)resource forAccount:(CKLCampfireAuthorizedAccount *)account withParameters:(NSDictionary *)parameters responseBlock:(CKLCampfireAPIResponseBlock)responseBlock
{
    [self _prepareForRequestWithAccount:account persistent:NO responseBlock:responseBlock];
    [[self _managerForAccount:account authorized:NO] DELETE:resource parameters:authenticatedParameters(parameters, account) success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self _finishRequestWithResponseData:nil error:nil responseBlock:responseBlock];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self _finishRequestWithResponseData:nil error:error responseBlock:responseBlock];
    }];
}

- (void)_prepareForRequestWithAccount:(CKLCampfireAuthorizedAccount *)account persistent:(BOOL)persistent responseBlock:(CKLCampfireAPIResponseBlock)responseBlock
{
    NSParameterAssert(account);
    NSParameterAssert(responseBlock);

    if (!persistent) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
}

- (void)_finishRequestWithResponseData:(NSData *)responseData error:(NSError *)error responseBlock:(CKLCampfireAPIResponseBlock)responseBlock
{
    if (responseData) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSDictionary *response = [NSDictionary dictionaryWithXMLData:responseData];
            dispatch_async(dispatch_get_main_queue(), ^{
                responseBlock(response, error);
            });
        });
    } else {
        responseBlock(nil, error);
    }

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (AFHTTPRequestOperationManager *)_managerForAccount:(CKLCampfireAuthorizedAccount *)account authorized:(BOOL)authorized
{
    AFHTTPRequestOperationManager *manager = _networkManagers[account.accountID];
    if (!manager) {
        manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:account.organizationURL];
        manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _networkManagers[account.accountID] = manager;
    }

    [manager.requestSerializer clearAuthorizationHeader];
    if (authorized) {
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:account.accessToken.apiTokenString password:@"X"];
    }
    return manager;
}

NSDictionary *authenticatedParameters(NSDictionary *parameters, CKLCampfireAccount *account)
{
    NSMutableDictionary *mutableParameters = (parameters) ? [parameters mutableCopy] : [NSMutableDictionary dictionary];
    if (account.accessToken.accessTokenString) {
        mutableParameters[@"access_token"] = account.accessToken.accessTokenString;
    }
    return [[mutableParameters allKeys] count] ? mutableParameters : nil;
}

#pragma mark - NSObject

- (instancetype)init
{
    if (self = [super init]) {
        _networkManagers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:CKLCampfireAPIDidAuthorizeAccountNotification];
}

@end

@implementation CKLCampfireAPIStreamingOperation

+ (instancetype)operationWithRequest:(NSURLRequest *)request manager:(AFHTTPRequestOperationManager *)manager
{
    CKLCampfireAPIStreamingOperation *operation = [[CKLCampfireAPIStreamingOperation alloc] initWithRequest:request];
    operation.responseSerializer = manager.responseSerializer;
    operation.shouldUseCredentialStorage = manager.shouldUseCredentialStorage;
    operation.credential = manager.credential;
    operation.securityPolicy = manager.securityPolicy;
    return operation;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [super connection:connection didReceiveData:data];
    if (self.responseBlock) {
        self.responseBlock(data);
    }
}

@end
