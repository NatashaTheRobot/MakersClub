//
//  ClubViewCell.m
//  MakersClub
//
//  Created by Natasha Murashev on 10/26/13.
//  Copyright (c) 2013 NatashaTheRobot. All rights reserved.
//

#import "ClubViewCell.h"
#import "UIImage+MCExtensions.h"

NSString * const kDefaultClubIconName = @"star.png";

@interface ClubViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;

@end

@implementation ClubViewCell

#pragma mark - Getter / Setter Overrides

- (void)setClubObject:(PFObject *)clubObject
{
    _clubObject = clubObject;
    
    self.titleTextLabel.text = [clubObject objectForKey:sParseClassClubTitleKey];
    
    [self getImageData];
}

# pragma mark - Layout Subviews Override

#pragma mark - Private Methods

- (void)getImageData
{
    ClubViewCell *weakSelf = self;
    [UIImage imageFromPFObject:self.clubObject
                           key:sParseClassClubImageKey
              defaultImageName:kDefaultClubIconName
               completionBlock:^(UIImage *image) {
                   weakSelf.iconImageView.image = image;
               }];
}

@end
