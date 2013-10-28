//
//  UIAlertView+MCExtensions.h
//  MakersClub
//
//  Created by Natasha Murashev on 10/28/13.
//  Copyright (c) 2013 NatashaTheRobot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (MCExtensions)

+ (instancetype)alertForMailerComposerCantSendMailToRecipients:(NSArray *)recipients;

@end
