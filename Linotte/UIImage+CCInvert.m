//
//  UIImage+CCInvert.m
//  Linotte
//
//  Created by stant on 17/05/14.
//  Copyright (c) 2014 CCSAS. All rights reserved.
//

#import "UIImage+CCInvert.h"
#import <CoreImage/CoreImage.h>

@implementation UIImage (CCInvert)

+ (UIImage *)inverseColor:(UIImage *)image
{
    CIImage *coreImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorInvert"];
    [filter setValue:coreImage forKey:kCIInputImageKey];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    return [UIImage imageWithCIImage:result scale:image.scale orientation:image.imageOrientation];
}

@end
