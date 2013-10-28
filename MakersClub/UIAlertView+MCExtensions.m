//
//  UIAlertView+MCExtensions.m
//  MakersClub
//
//  Created by Natasha Murashev on 10/28/13.
//  Copyright (c) 2013 NatashaTheRobot. All rights reserved.
//

#import "UIAlertView+MCExtensions.h"

@implementation UIAlertView (MCExtensions)

+ (instancetype)alertForMailerComposerCantSendMailToRecipients:(NSArray *)recipients
{
    NSString *message = [NSString stringWithFormat:@"Your device doesn't support the mail composer. Please send an email to %@ to complete this action",
                         [recipients componentsJoinedByString:@", "]];
    return [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                      message:message
                                     delegate:nil
                            cancelButtonTitle:@"OK"
                            otherButtonTitles: nil];
}

@end
