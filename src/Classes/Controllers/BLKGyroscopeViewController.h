//
//  BLKGyroscopeViewController.h
//  BLEKit
//
//  Created by Igor Sales on 2014-11-13.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLKControlViewControllerProtocol.h"

@class BLKGyroscopeView;
@class BLKI2CControlPort;

@interface BLKGyroscopeViewController : UIViewController <BLKControlViewControllerProtocol>

@property (nonatomic, readonly)          BLKI2CControlPort* I2CPort;
@property (nonatomic, weak)     IBOutlet BLKGyroscopeView* gyroView;

@end
