//
//  BLKCompassViewController.h
//  BLEKit
//
//  Created by Igor Sales on 2014-10-30.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLKControlViewControllerProtocol.h"

@class BLKCompassView;
@class BLKI2CControlPort;

@interface BLKCompassViewController : UIViewController <BLKControlViewControllerProtocol>

@property (nonatomic, readonly) IBOutlet BLKI2CControlPort*  I2CPort;
@property (nonatomic, weak)     IBOutlet BLKCompassView* compassView;


@end
