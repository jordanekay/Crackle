//
//  CKLCampfireUpload.h
//  Crackle
//
//  Created by Jordan Kay on 12/27/13.
//  Copyright (c) 2013 Jordan Kay. All rights reserved.
//

#import <Mantle/MTLModel.h>
#import <Mantle/MTLJSONAdapter.h>

@interface CKLCampfireUpload : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *uploadID;
@property (nonatomic, copy, readonly) NSString *userID;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *contentType;
@property (nonatomic, readonly) NSDate *creationDate;
@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSInteger size;
@property (nonatomic, readonly) CKLCampfireRoom *room;
@property (nonatomic, readonly) CKLCampfireUser *user;

@end
