//
//  BLKJoystick.h
//  BLEKit
//
//  Created by Igor Sales on 2014-10-04.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    BLKAxisX,
    BLKAxisY,
    BLKAxisZ,
} BLKAxis;

typedef enum {
    BLKJoystickTypeHorizontal,
    BLKJoystickTypeVertical,
    BLKJoystickTypeHorizontalAndVertical,
    BLKJoystickTypeWheel
} BLKJoystickType;

@class BLKJoystick;

@interface BLKJoystick : UIControl

- (id)initWithType:(BLKJoystickType)type;

@property (nonatomic, assign) BLKJoystickType type;

@property (nonatomic, assign) BOOL invertHorizontal;
@property (nonatomic, assign) BOOL invertVertical;

@property (nonatomic, assign) BOOL stickyHorizontal;
@property (nonatomic, assign) BOOL stickyVertical;

// transient
@property (nonatomic, assign) CGPoint joystickCentre;
@property (nonatomic, assign) CGFloat joystickWheelPosition;

- (void)moveStickToPosition:(CGPoint)point;
- (void)turnWheelToAngle:(CGFloat)angle;

@end
