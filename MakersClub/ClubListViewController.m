//
//  ClubListViewController.m
//  MakersClub
//
//  Created by Natasha Murashev on 10/26/13.
//  Copyright (c) 2013 NatashaTheRobot. All rights reserved.
//

#import "ClubListViewController.h"

@interface ClubListViewController ()

@end

@implementation ClubListViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.parseClassName = sParseClassClub;
        
        self.textKey = sParseClassClubTitleKey;
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

#pragma mark - Parse

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByAscending:@"title"];
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)clubObject
{
    static NSString *CellIdentifier = @"clubCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.textLabel.text = [clubObject objectForKey:sParseClassClubTitleKey];
    
    return cell;
}

@end
