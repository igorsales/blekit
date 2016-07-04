//
//  BLKJoystickSettingsViewController.h
//  BLEKit
//
//  Created by Igor Sales on 2014-10-21.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BLEKit/BLKJoystick.h>

@class BLKJoystickViewController;

@interface BLKJoystickSettingsViewController : UITableViewController

@property (nonatomic, assign) BLKAxis                    axis;
@property (nonatomic, weak)   BLKJoystickViewController* joystickViewController;

@end
