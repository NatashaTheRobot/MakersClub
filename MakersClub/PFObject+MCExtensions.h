//
//  PFObject+MCExtensions.h
//  MakersClub
//
//  Created by Natasha Murashev on 10/27/13.
//  Copyright (c) 2013 NatashaTheRobot. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFObject (MCExtensions)

- (BOOL)isIncludedInObjectsArray:(NSArray *)parseObjectsArray;

@end
