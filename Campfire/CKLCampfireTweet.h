//
//  CKLCampfireTweet.h
//  Crackle
//
//  Created by Jordan Kay on 12/26/13.
//  Copyright (c) 2013 Jordan Kay. All rights reserved.
//

#import <Mantle/MTLModel.h>
#import <Mantle/MTLJSONAdapter.h>

@interface CKLCampfireTweet : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *tweetID;
@property (nonatomic, copy, readonly) NSString *authorUsername;
@property (nonatomic, copy, readonly) NSString *text;
@property (nonatomic, readonly) NSURL *authorAvatarURL;

@end
