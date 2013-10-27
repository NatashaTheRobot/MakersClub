//
//  GithubLoginViewController.m
//  MakersClub
//
//  Created by Natasha Murashev on 10/26/13.
//  Copyright (c) 2013 NatashaTheRobot. All rights reserved.
//

#import "GithubLoginViewController.h"
#import "PFUser+MCExtensions.h"
#import "PFObject+MCExtensions.h"
#import "NSString+MCExtensions.h"

@interface GithubLoginViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) UIAlertView *alertView;

@end

@implementation GithubLoginViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // the github web view takes care of handling the token retrieval - see GithubAuthWebView
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGithubTokenRetrieval:) name:sNotificationGithubTokenRetrieved object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.alertView) {
        [self.alertView dismissWithClickedButtonIndex:self.alertView.cancelButtonIndex animated:NO];
    }
}

- (void)dealloc
{
    [self removeNotificationObservers];
}

#pragma mark - Notification Selectors

- (void)onGithubTokenRetrieval:(NSNotification *)notification
{
    NSString *githubToken = notification.object;
    
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:sParseClassUserKeyGithubToken equalTo:githubToken];
    
    __weak GithubLoginViewController *weakSelf = self;
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users.count == 0) {
            [weakSelf retrieveUserDataFromGithubToken:githubToken];
        } else {
            PFUser *user = users[0];
            [weakSelf loginUser:user];
        }
    }];
    
}

- (void)removeNotificationObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:sNotificationGithubTokenRetrieved object:nil];
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private Methods

- (void)retrieveUserDataFromGithubToken:(NSString *)githubToken
{
    NSString *userInfoURLString = [NSString stringWithFormat:@"https://api.github.com/user?access_token=%@", githubToken];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:userInfoURLString]];
    
    __weak GithubLoginViewController *weakSelf = self;
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSError *jsonError;
                               id githubData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                               if(!jsonError && !error && githubData && [NSJSONSerialization isValidJSONObject:githubData])
                               {
                                   PFUser *user = [PFUser userFromGithubData:githubData githubToken:githubToken];
                                   
                                   [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                       if (succeeded) {
                                           [weakSelf loginUser:user];
                                       } else if (error) {
                                           [weakSelf handleError:error];
                                       }
                                   }];
                               }
                           }];
}

- (void)loginUser:(PFUser *)user
{
    __weak GithubLoginViewController *weakSelf;
    [PFUser logInWithUsernameInBackground:user.username password:sParseClassUserDefaultPassword block:^(PFUser *user, NSError *error) {
        if (user) {
            [user updateEmailFromGithub];
            [weakSelf redirectUser:user];
        } else if (error) {
            [weakSelf handleError:error];
        }
    }];
}

- (void)redirectUser:(PFUser *)user
{
    if ([user isMemberOfClub:self.clubObject]) {
        // proceed to club page
    } else {
        // email club organizer
    }
}

- (void)handleError:(NSError *)error
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        self.alertView = [[UIAlertView alloc] initWithTitle:@"Whoops!"
                                                    message:error.description
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
        [self.alertView show];
    });
}

@end
