//
//  UIImage+MCExtensions.m
//  MakersClub
//
//  Created by Natasha Murashev on 10/26/13.
//  Copyright (c) 2013 NatashaTheRobot. All rights reserved.
//

#import "UIImage+MCExtensions.h"

@implementation UIImage (MCExtensions)

+ (instancetype)imageFromPFObject:(PFObject *)object key:(NSString *)key
{
    PFFile *imageFile = [object objectForKey:key];
    NSData *imageData = [imageFile getData];
    
    return [UIImage imageWithData:imageData];
}
@end
