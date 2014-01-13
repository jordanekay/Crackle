//
//  CKLCampfireAPICacheable.h
//  Crackle
//
//  Created by Jordan Kay on 1/13/14.
//  Copyright (c) 2014 Jordan Kay. All rights reserved.
//

@protocol CKLCampfireAPICacheable <NSObject>

+ (instancetype)cachedObjectWithID:(NSString *)objectID;

@end
