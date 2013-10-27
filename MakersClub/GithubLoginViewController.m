//
//  GithubLoginViewController.m
//  MakersClub
//
//  Created by Natasha Murashev on 10/26/13.
//  Copyright (c) 2013 NatashaTheRobot. All rights reserved.
//

#import "GithubLoginViewController.h"

@interface GithubLoginViewController ()

@end

@implementation GithubLoginViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGithubTokenRetrieval:) name:sNotificationGithubTokenRetrieved object:nil];
    
	
}

- (void)dealloc
{
    [self removeNotificationObservers];
}

#pragma mark - Notification Selectors

- (void)onGithubTokenRetrieval:(NSNotification *)notification
{
    // token is notification.object
    // save the token in Parse - create user
    // do the request to get user data
    
    //As a test, we'll request the authenticated user data.
    NSString *userInfoURLString = [NSString stringWithFormat:@"https://api.github.com/user?access_token=%@", notification.object];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:userInfoURLString]];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSError *err;
                               id val = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
                               if(!err && !error && val && [NSJSONSerialization isValidJSONObject:val])
                               {
                                   dispatch_sync(dispatch_get_main_queue(), ^{
                                       // save user data in parse!
                                       NSString *username = [val objectForKey:@"name"];
                                       
                                       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"User request complete" message:[NSString stringWithFormat:@"User info retrieved for: %@", username] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                       [alertView show];
                                   });
                               }
                           }];
    
}

- (void)removeNotificationObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:sNotificationGithubTokenRetrieved object:nil];
}

@end
