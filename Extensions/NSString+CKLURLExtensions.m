//
//  NSString+CKLURLExtensions.m
//  Crackle
//
//  Created by Jordan Kay on 12/25/13.
//  Copyright (c) 2013 Jordan Kay. All rights reserved.
//

#import "NSString+CKLURLExtensions.h"

@implementation NSString (CKLURLExtensions)

- (NSDictionary *)ckl_queryParameters
{
    NSArray *components = [self componentsSeparatedByString:@"&"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:[components count]];
    [components enumerateObjectsUsingBlock:^(NSString *component, NSUInteger idx, BOOL *stop) {
        NSArray *values = [component componentsSeparatedByString:@"="];
        if ([values count] == 2) {
            parameters[values[0]] = values[1];
        }
    }];
    return parameters;
}

@end
