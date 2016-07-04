//
//  BLKAccelerometerViewController.h
//  BLEKit
//
//  Created by Igor Sales on 2014-11-13.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLKControlViewControllerProtocol.h"

@class BLKAccelerometerView;
@class BLKI2CControlPort;

@interface BLKAccelerometerViewController : UIViewController <BLKControlViewControllerProtocol>

@property (nonatomic, readonly) IBOutlet BLKI2CControlPort* I2CPort;
@property (nonatomic, weak)     IBOutlet BLKAccelerometerView* accelView;

@end
