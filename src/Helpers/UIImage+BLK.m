//
//  UIImage+BLK.m
//  BLEKit
//
//  Created by Igor Sales on 2016-07-06.
//  Copyright © 2016 ble-kit.org. All rights reserved.
//

#import "UIImage+BLK.h"
#import "BLKManager.h"

@implementation UIImage (BLK)

+ (UIImage*)BLKImageNamed:(NSString*)imageName
{
    return [UIImage imageNamed:imageName
                      inBundle:[NSBundle bundleForClass:[BLKManager class]]
 compatibleWithTraitCollection:nil];
}

+ (UIImage*)BLKIconCheckImage
{
    return [self BLKImageNamed:@"icon_check"];
}

+ (UIImage*)BLKIconErrorImage
{
    return [self BLKImageNamed:@"icon_error"];
}

+ (UIImage*)BLKRedDeleteMinusImage
{
    return [self BLKImageNamed:@"red_delete_minus"];
}

+ (UIImage*)BLKDraggingHandleImage
{
    return [self BLKImageNamed:@"dragging_handle"];
}

@end
