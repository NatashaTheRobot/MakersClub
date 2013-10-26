//
//  UIImage+MCExtensions.h
//  MakersClub
//
//  Created by Natasha Murashev on 10/26/13.
//  Copyright (c) 2013 NatashaTheRobot. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ImageFromDataBlock)(UIImage *image);

@interface UIImage (MCExtensions)

+ (void)imageFromPFObject:(PFObject *)object
                      key:(NSString *)key
         defaultImageName:(NSString *)defaultImageName
          completionBlock:(ImageFromDataBlock)imageBlock;

@end
