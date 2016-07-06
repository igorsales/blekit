//
//  UIImage+BLK.h
//  BLEKit
//
//  Created by Igor Sales on 2016-07-06.
//  Copyright © 2016 ble-kit.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (BLK)

+ (UIImage*)BLKImageNamed:(NSString*)imageName;

+ (UIImage*)BLKIconCheckImage;
+ (UIImage*)BLKIconErrorImage;
+ (UIImage*)BLKRedDeleteMinusImage;
+ (UIImage*)BLKDraggingHandleImage;

@end
