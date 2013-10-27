//
//  NSDictionary+MCExtensions.m
//  MakersClub
//
//  Created by Natasha Murashev on 10/26/13.
//  Copyright (c) 2013 NatashaTheRobot. All rights reserved.
//

#import "NSDictionary+MCExtensions.h"

static NSString *toString(id object)
{
    return [NSString stringWithFormat:@"%@", object];
}

static NSString *urlEncode(id object)
{
    NSString *string = toString(object);
    return [string stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
}

@implementation NSDictionary (MCExtensions)

- (NSString *)urlEncodedString
{
    NSMutableArray *parts = [NSMutableArray array];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *part = [NSString stringWithFormat: @"%@=%@", urlEncode(key), urlEncode(value)];
        [parts addObject: part];
    }];
    
    return [parts componentsJoinedByString: @"&"];
}

@end
