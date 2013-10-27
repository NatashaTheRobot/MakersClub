//
//  PFUser+MCExtensions.h
//  MakersClub
//
//  Created by Natasha Murashev on 10/27/13.
//  Copyright (c) 2013 NatashaTheRobot. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFUser (MCExtensions)

+ (instancetype)userFromGithubData:(NSDictionary *)githubData githubToken:(NSString *)githubToken;
- (void)updateEmailFromGithub;

- (NSArray *)clubs;
- (BOOL)isMemberOfClub:(PFObject *)clubObject;

@end
