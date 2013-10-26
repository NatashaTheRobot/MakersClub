//
//  ClubViewCell.m
//  MakersClub
//
//  Created by Natasha Murashev on 10/26/13.
//  Copyright (c) 2013 NatashaTheRobot. All rights reserved.
//

#import "ClubViewCell.h"
#import "UIImage+MCExtensions.h"

@implementation ClubViewCell


#pragma mark - Getter / Setter Overrides

- (void)setClubObject:(PFObject *)clubObject
{
    _clubObject = clubObject;
    
    self.textLabel.text = [clubObject objectForKey:sParseClassClubTitleKey];
    self.imageView.image = [UIImage imageFromPFObject:clubObject key:sParseClassClubImageKey];
}

# pragma mark - Layout Subviews Override

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(self.imageView.frame.origin.x,
                                      self.frame.size.height - (self.frame.size.height * 3 / 4),
                                      25.0f,
                                      25.0f);
}

@end
