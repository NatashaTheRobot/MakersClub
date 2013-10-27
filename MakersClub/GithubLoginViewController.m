//
//  GithubLoginViewController.m
//  MakersClub
//
//  Created by Natasha Murashev on 10/26/13.
//  Copyright (c) 2013 NatashaTheRobot. All rights reserved.
//

#import "GithubLoginViewController.h"
#import "PFUser+MCExtensions.h"
#import "NSString+MCExtensions.h"

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
    // save the token in Parse - create or retrieve user!
    // do the request to get user data
    
    NSString *githubToken = notification.object;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"githubToken = %@", githubToken];
    PFQuery *query = [PFQuery queryWithClassName:sParseClassUserKeyGithubToken predicate:predicate];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users.count == 0) {
            [self retrieveUserDataFromGithubToken:githubToken];
        } else {
            // figure out if the user belongs in this club
                // if yes, proceed to club page
                // if no, show them the email controller to request access!
            
        }
    }];
    
}

- (void)removeNotificationObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:sNotificationGithubTokenRetrieved object:nil];
}

#pragma mark - Private Methods

- (void)retrieveUserDataFromGithubToken:(NSString *)githubToken
{
    //As a test, we'll request the authenticated user data.
    NSString *userInfoURLString = [NSString stringWithFormat:@"https://api.github.com/user?access_token=%@", githubToken];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:userInfoURLString]];
    
    __weak GithubLoginViewController *weakSelf = self;
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSError *err;
                               id githubData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
                               if(!err && !error && githubData && [NSJSONSerialization isValidJSONObject:githubData])
                               {
                                   PFUser *user = [PFUser userFromGithubData:githubData githubToken:githubToken];
                                   
                                   [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                       if (succeeded) {
                                           // redirect them to correct VC
                                       } else if (error) {
                                           if (error.code == 202) {
                                               [PFUser logInWithUsernameInBackground:user.username password:user.password block:^(PFUser *user, NSError *error) {
                                                   if ([user.email isEqualToString:[NSString stringWithFormat:@"%@@email.com", githubToken]]) {
                                                       [weakSelf getEmailForUser:user];
                                                   }
                                               }];
                                           } else {
                                               // display Error message!
                                           }
                                       }
                                   }];
                                   
                                   dispatch_sync(dispatch_get_main_queue(), ^{
                                       // save user data in parse!
                                       NSString *username = [githubData objectForKey:@"name"];
                                       
                                       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"User request complete" message:[NSString stringWithFormat:@"User info retrieved for: %@", username] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                       [alertView show];
                                   });
                               }
                           }];
}

- (void)getEmailForUser:(PFUser *)user
{
    NSString *userEmailURLString = [NSString stringWithFormat:@"https://api.github.com/user/emails?access_token=%@", user[sParseClassUserKeyGithubToken]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:userEmailURLString]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSError *jsonError;
                               id emailsArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                               if(!jsonError && !error && emailsArray && [NSJSONSerialization isValidJSONObject:emailsArray])
                               {
                                   user.email = emailsArray[0];
                                   [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                       if (error) {
                                           if ([NSString isValidString:user.email]) {
                                               [user saveEventually];
                                           }
                                        }
                                   }];
                               }
                           }];
}

@end
