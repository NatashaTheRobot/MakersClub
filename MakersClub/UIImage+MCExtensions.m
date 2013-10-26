//
//  UIImage+MCExtensions.m
//  MakersClub
//
//  Created by Natasha Murashev on 10/26/13.
//  Copyright (c) 2013 NatashaTheRobot. All rights reserved.
//

#import "UIImage+MCExtensions.h"

@implementation UIImage (MCExtensions)

+ (void)imageFromPFObject:(PFObject *)object
                      key:(NSString *)key
         defaultImageName:(NSString *)defaultImageName
          completionBlock:(ImageFromDataBlock)imageBlock;
{
    PFFile *imageFile = [object objectForKey:key];
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage *image;
        if (!error) {
            image = [UIImage imageWithData:data];
        } else {
            image = [UIImage imageNamed:defaultImageName];
        }
        imageBlock(image);
    }];
}
@end
