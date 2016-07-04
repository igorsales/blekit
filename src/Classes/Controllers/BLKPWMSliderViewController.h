//
//  BLKPWMSliderViewController.h
//  BLEKit
//
//  Created by Igor Sales on 2015-05-15.
//  Copyright (c) 2015 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLKControlViewControllerProtocol.h"

@class BLKJoystick;
@class BLKPWMChannelsPort;

@interface BLKPWMSliderViewController : UIViewController <BLKControlViewControllerProtocol>

@property (nonatomic, readonly)          BLKPWMChannelsPort* PWMPort;
@property (nonatomic, readonly)          BLKPWMChannelsPort* defaultsPWMPort;
@property (nonatomic, weak)     IBOutlet UISlider* slider;
@property (nonatomic, assign)            NSInteger             channel;

- (IBAction)sliderValueChanged:(id)sender;

@end
