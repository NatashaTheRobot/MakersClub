//
//  PFObject+MCExtensions.m
//  MakersClub
//
//  Created by Natasha Murashev on 10/27/13.
//  Copyright (c) 2013 NatashaTheRobot. All rights reserved.
//

#import "PFObject+MCExtensions.h"

@implementation PFObject (MCExtensions)

- (BOOL)isIncludedInObjectsArray:(NSArray *)parseObjectsArray
{
    __block BOOL includedInArray = NO;
    
    [parseObjectsArray enumerateObjectsUsingBlock:^(PFObject *parseObject, NSUInteger idx, BOOL *stop) {
        if ([parseObject.objectId isEqualToString:self.objectId]) {
            includedInArray = YES;
            *stop = YES;
        }
    }];
    
    return includedInArray;
}

- (NSArray *)objectsForRelationKey:(NSString *)relationKey
{
    PFRelation *relation = [self relationforKey:relationKey];
    PFQuery *relationQuery = [relation query];
    return [relationQuery findObjects];
}

@end
