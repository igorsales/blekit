//
//  BLKGPOutputsViewController.h
//  BLEKit
//
//  Created by Igor Sales on 2015-05-15.
//  Copyright (c) 2015 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLKControlViewControllerProtocol.h"

@class BLKGPIOPort;

@interface BLKGPIOsViewController : UIViewController <BLKControlViewControllerProtocol>

@property (nonatomic, readonly) BLKGPIOPort* GPIOPort;

@end

@interface BLKGPInputsViewController : BLKGPIOsViewController

@end

@interface BLKGPOutputsViewController : BLKGPIOsViewController

@end
