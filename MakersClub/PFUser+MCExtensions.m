//
//  PFUser+MCExtensions.m
//  MakersClub
//
//  Created by Natasha Murashev on 10/27/13.
//  Copyright (c) 2013 NatashaTheRobot. All rights reserved.
//

#import "PFUser+MCExtensions.h"
#import "PFObject+MCExtensions.h"
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

+ (NSArray *)emailsForUsers:(NSArray *)users
{
    NSMutableArray *emailsArray = [[NSMutableArray alloc] initWithCapacity:users.count];
    
    [users enumerateObjectsUsingBlock:^(PFUser *user, NSUInteger idx, BOOL *stop) {
        [emailsArray addObject:user.email];
    }];
    
    return [emailsArray copy];
}

- (BOOL)isMemberOfClub:(PFObject *)club
{
    BOOL isMemberOfClub = NO;
    
    if ([club isIncludedInObjectsArray:[self objectsForRelationKey:sParseClassUserRelationClubs]]) {
        isMemberOfClub = YES;
    }
    
    return isMemberOfClub;
}

- (void)updateEmailFromGithub
{
    if (self[sParseClassUserKeyGithubToken] && [self.email isEqualToString:[NSString stringWithFormat:@"%@@email.com", self[sParseClassUserKeyGithubToken]]]) {
        NSString *userEmailURLString = [NSString stringWithFormat:@"https://api.github.com/user/emails?access_token=%@", self[sParseClassUserKeyGithubToken]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:userEmailURLString]];
        
        __weak PFUser *weakSelf = self;
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   NSError *jsonError;
                                   id emailsArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                                   if(!jsonError && !error && emailsArray && [NSJSONSerialization isValidJSONObject:emailsArray])
                                   {
                                       weakSelf.email = emailsArray[0];
                                       [weakSelf saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                           if (error && [NSString isValidString:weakSelf.email]) {
                                               [weakSelf saveEventually];
                                           }
                                       }];
                                   }
                               }];
    }
}

@end
