//
//  PFUser+MCExtensions.m
//  MakersClub
//
//  Created by Natasha Murashev on 10/27/13.
//  Copyright (c) 2013 NatashaTheRobot. All rights reserved.
//

#import "PFUser+MCExtensions.h"
#import "NSString+MCExtensions.h"

@implementation PFUser (MCExtensions)

+ (instancetype)userFromGithubData:(NSDictionary *)githubData githubToken:(NSString *)githubToken
{
    PFUser *user = [PFUser user];
    
    user.username = githubData[@"login"];
    user.password = sParseClassUserDefaultPassword;
    user.email = [NSString isValidString:githubData[@"email"]] ? githubData[@"email"] : [NSString stringWithFormat:@"%@@email.com", githubToken];
    
    user[sParseClassUserKeyGithubToken] = githubToken;
    user[sParseClassUserKeyAvatarURL] = githubData[@"avatar_url"];
    
    return user;
}

@end
