//
//  UIImage+MCExtensions.h
//  MakersClub
//
//  Created by Natasha Murashev on 10/26/13.
//  Copyright (c) 2013 NatashaTheRobot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MCExtensions)

+ (instancetype)imageFromPFObject:(PFObject *)object key:(NSString *)key;

@end
