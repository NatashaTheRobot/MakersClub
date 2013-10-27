//
//  NSString+MCExtensions.m
//  MakersClub
//
//  Created by Natasha Murashev on 10/27/13.
//  Copyright (c) 2013 NatashaTheRobot. All rights reserved.
//

#import "NSString+MCExtensions.h"

@implementation NSString (MCExtensions)

+ (BOOL)isValidString:(NSString *)string
{
    return string && ![string isEqualToString:@""] && [string isKindOfClass:NSString.class];
}

@end
