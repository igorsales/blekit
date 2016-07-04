//
//  BLKDeviceRotationManager.h
//  BLEKit
//
//  Created by Igor Sales on 2015-04-14.
//  Copyright (c) 2015 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BLKControllerRotationObserver <NSObject>

- (void)observeAngle:(CGFloat)angle tilt:(CGFloat)tilt;

@end

@class BLKControllerRotationManager;

@protocol BLKControllerRotationManagerDelegate <NSObject>

- (void)manager:(BLKControllerRotationManager*)manager userDidTiltToDegrees:(CGFloat)title angle:(CGFloat)angle;

@end

@interface BLKControllerRotationManager : NSObject

@property (nonatomic, assign) UIDeviceOrientation orientation;

@property (nonatomic, weak) IBOutlet id<BLKControllerRotationManagerDelegate> delegate;

- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;

@end
