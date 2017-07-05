//
//  BLKJoystickViewController.h
//  BLEKit
//
//  Created by Igor Sales on 2014-10-06.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLKControlViewControllerProtocol.h"

typedef enum {
    BLKChannelScaleLinear,
    BLKChannelScaleDivideBy2,
    BLKChannelScaleDivideBy3,
    BLKChannelScaleDivideBy4,
    BLKChannelScaleLogarithmic,
} BLKChannelScale;

@class BLKJoystick;
@class BLKPWMChannelsPort;

@interface BLKJoystickViewController : UIViewController <BLKControlViewControllerProtocol>

@property (nonatomic, readonly)          BLKPWMChannelsPort*   PWMPort;
@property (nonatomic, readonly)          BLKPWMChannelsPort*   defaultsPWMPort;
@property (nonatomic, weak)     IBOutlet BLKJoystick*          joystick;
@property (nonatomic, assign)            NSInteger             horizontalChannel;
@property (nonatomic, assign)            NSInteger             verticalChannel;
@property (nonatomic, assign)            NSInteger             zChannel;

@property (nonatomic, assign)            CGFloat               horizontalTrim;
@property (nonatomic, assign)            CGFloat               verticalTrim;
@property (nonatomic, assign)            CGFloat               zTrim;

@property (nonatomic, assign)            CGFloat               horizontalValueOnDisconnect;
@property (nonatomic, assign)            CGFloat               verticalValueOnDisconnect;
@property (nonatomic, assign)            CGFloat               zValueOnDisconnect;

@property (nonatomic, assign)            BLKChannelScale       horizontalScale;
@property (nonatomic, assign)            BLKChannelScale       verticalScale;
@property (nonatomic, assign)            BLKChannelScale       zScale;

@property (nonatomic, assign)            BOOL                  horizontalTieToControllerAngle;
@property (nonatomic, assign)            BOOL                  verticalTieToControllerAngle;
@property (nonatomic, assign)            BOOL                  zTieToControllerAngle;

@property (nonatomic, assign)            BOOL                  horizontalTieToControllerTilt;
@property (nonatomic, assign)            BOOL                  verticalTieToControllerTilt;
@property (nonatomic, assign)            BOOL                  zTieToControllerTilt;

@property (nonatomic, assign)            NSInteger             horizontalDamperChannelIndex;
@property (nonatomic, assign)            NSInteger             verticalDamperChannelIndex;

- (IBAction)joystickValueChanged:(id)joystick;
- (IBAction)joystickDefaultValueChanged:(BLKJoystick*)joystick;
- (IBAction)apply:(id)sender;

@end
