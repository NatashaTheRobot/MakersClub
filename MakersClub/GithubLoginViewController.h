//
//  GithubLoginViewController.h
//  MakersClub
//
//  Created by Natasha Murashev on 10/26/13.
//  Copyright (c) 2013 NatashaTheRobot. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ClubControllerDelegate <NSObject>

- (void)redirectCurrentUserToClub:(PFObject *)club;

@end

@interface GithubLoginViewController : UIViewController

@property (strong, nonatomic) PFObject *club;

@property (strong, nonatomic) id<ClubControllerDelegate> delegate;

@end
