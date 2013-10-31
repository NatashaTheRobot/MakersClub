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

@interface ClubListViewController () <MFMailComposeViewControllerDelegate, ClubControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIAlertView *alertView;

@property (strong, nonatomic) MFMailComposeViewController *clubMembershipMailComposeViewController;

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

#pragma mark - Actions

- (IBAction)onAddClubButtonTap:(id)sender
{
    [self showMailComposerForAddingClub];
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:GithubLoginViewController.class]) {
        GithubLoginViewController *githubLoginViewController = (GithubLoginViewController *)segue.destinationViewController;
        githubLoginViewController.club = [self objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        githubLoginViewController.delegate = self;
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

#pragma mark - Table View Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)clubObject
{
    ClubViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(ClubViewCell.class)];
    cell.clubObject = clubObject;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *club = [self objectAtIndexPath:indexPath];
    
    [self redirectCurrentUserToClub:club];
}

#pragma mark - Club Controller Delegate

- (void)redirectCurrentUserToClub:(PFObject *)club
{
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) {
        [self performSegueWithIdentifier:kSegueClubListToGithubLogin sender:self];
    } else if (![currentUser isMemberOfClub:club]){
        [self showMailComposerForClubMembership:club];
    } else {
        // if user is member of club, send them to the club page!
    }
}

#pragma mark - Private Methods

- (void)showMailComposerForClubMembership:(PFObject *)club
{
    NSArray *clubOrganizers = [club objectsForRelationKey:sParseClassClubRelationOrganizers];
    NSArray *emailRecipients = [PFUser emailsForUsers:clubOrganizers];
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailerViewController = [[MFMailComposeViewController alloc] init];
        mailerViewController.mailComposeDelegate = self;
        
        [mailerViewController setToRecipients:emailRecipients];
        [mailerViewController setSubject:[NSString stringWithFormat:@"Application for %@ on Makers Club", club[sParseClassClubKeyTitle]]];
        
        NSString *emailBody = [NSString stringWithFormat:@"I'm interested in joining the %@ on Makers Club.", club[sParseClassClubKeyTitle]];
        [mailerViewController setMessageBody:emailBody isHTML:NO];
        
        self.clubMembershipMailComposeViewController = mailerViewController;
        
        [self presentViewController:self.clubMembershipMailComposeViewController animated:YES completion:nil];
    } else {
        self.alertView = [UIAlertView alertForMailerComposerCantSendMailToRecipients:emailRecipients];
        [self.alertView show];
    }
}

- (void)showMailComposerForAddingClub
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailerViewController = [[MFMailComposeViewController alloc] init];
        mailerViewController.mailComposeDelegate = self;
        
        [mailerViewController setToRecipients:@[sEmailAddressToAddClub]];
        [mailerViewController setSubject:@"Add Club on Makers Club"];
        
        NSString *emailBody = [NSString stringWithFormat:@"I'm interested in creating a club on Makers Club!"];
        [mailerViewController setMessageBody:emailBody isHTML:NO];
        
        [self presentViewController:mailerViewController animated:YES completion:nil];
    } else {
        self.alertView = [UIAlertView alertForMailerComposerCantSendMailToRecipients:@[sEmailAddressToAddClub]];
        [self.alertView show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    if (controller == self.clubMembershipMailComposeViewController) {
        [self onClubMembershipRequestCompletionForMailController:controller result:result];
    } else {
        [self onAddClubRequestCompletionForMailerController:controller result:result];
    }
}

- (void)onClubMembershipRequestCompletionForMailController:(MFMailComposeViewController*)controller result:(MFMailComposeResult)result
{
    __weak  ClubListViewController *weakSelf = self;
    [controller dismissViewControllerAnimated:YES completion:^{
        
        if (result == MFMailComposeResultSent) {
            weakSelf.alertView = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                            message:@"Your email was sent to the club organizer. The organizer will get back to you with further application instructions."
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        } else {
            weakSelf.alertView = [[UIAlertView alloc] initWithTitle:@"Whoops!"
                                                            message:@"Your email was not sent! Try again to apply for membership to this club!"
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        }
        [weakSelf.alertView show];
        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
    }];
}

- (void)onAddClubRequestCompletionForMailerController:(MFMailComposeViewController*)controller result:(MFMailComposeResult)result
{
    __weak  ClubListViewController *weakSelf = self;
    [controller dismissViewControllerAnimated:YES completion:^{
        
        if (result == MFMailComposeResultSent) {
            weakSelf.alertView = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                            message:@"Your email was sent to the Makers Club organizers. We will get back to you shortly!"
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        } else {
            weakSelf.alertView = [[UIAlertView alloc] initWithTitle:@"Whoops!"
                                                            message:@"Your email was not sent! Try again to create your very own Makers Club club!"
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        }
        [weakSelf.alertView show];
    }];
}

@end
