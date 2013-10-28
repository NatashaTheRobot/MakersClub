//
//  ClubListViewController.m
//  MakersClub
//
//  Created by Natasha Murashev on 10/26/13.
//  Copyright (c) 2013 NatashaTheRobot. All rights reserved.
//

#import "ClubListViewController.h"
#import "ClubViewCell.h"
#import "GithubLoginViewController.h"
#import <MessageUI/MessageUI.h>
#import "PFUser+MCExtensions.h"
#import "PFObject+MCExtensions.h"
#import "UIAlertView+MCExtensions.h"

NSString * const kSegueClubListToGithubLogin = @"ClubListToGithubLogin";

@interface ClubListViewController () <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) UIAlertView *alertView;

@end

@implementation ClubListViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.parseClassName = sParseClassClub;
        
        self.textKey = sParseClassClubKeyTitle;
        self.pullToRefreshEnabled = YES;
        
        self.paginationEnabled = YES;
        self.objectsPerPage = 50;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.alertView) {
        [self.alertView dismissWithClickedButtonIndex:self.alertView.cancelButtonIndex animated:NO];
    }
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:GithubLoginViewController.class]) {
        GithubLoginViewController *githubLoginViewController = (GithubLoginViewController *)segue.destinationViewController;
        githubLoginViewController.clubObject = [self objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
    }
}

#pragma mark - Parse

- (PFQuery *)queryForTable
{
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByAscending:sParseClassClubKeyTitle];
    
    return query;
}

#pragma mark - Table View Delegate Overwrites

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)clubObject
{
    ClubViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(ClubViewCell.class)];
    cell.clubObject = clubObject;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *club = [self objectAtIndexPath:indexPath];
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) {
        [self performSegueWithIdentifier:kSegueClubListToGithubLogin sender:self];
    } else if (![currentUser isMemberOfClub:club]){
        [self showMailComposerForClub:club];
    } else {
        // if user is member of club, send them to the club page!
    }
}

#pragma mark - Private Methods

- (void)showMailComposerForClub:(PFObject *)club
{
    NSArray *clubOrganizers = [club objectsForRelationKey:sParseClassClubRelationOrganizers];
    NSArray *emailRecipients = [PFUser emailsForUsers:clubOrganizers];
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailerViewController = [[MFMailComposeViewController alloc] init];
        mailerViewController.mailComposeDelegate = self;
        
        [mailerViewController setToRecipients:emailRecipients];
        [mailerViewController setSubject:[NSString stringWithFormat:@"MakersClub - %@ Application", club[sParseClassClubKeyTitle]]];
        
        NSString *emailBody = [NSString stringWithFormat:@"I'm interested in joining the %@ on Makers Club.", club[sParseClassClubKeyTitle]];
        [mailerViewController setMessageBody:emailBody isHTML:NO];
        
        [self presentViewController:mailerViewController animated:YES completion:nil];
    } else {
        self.alertView = [UIAlertView alertForMailerComposerCantSendMailToRecipients:emailRecipients];
        [self.alertView show];
    }
}

@end
