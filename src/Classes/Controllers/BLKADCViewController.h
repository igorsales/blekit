//
//  BLKADCViewController.h
//  BLEKit
//
//  Created by Igor Sales on 2015-06-10.
//  Copyright (c) 2015 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLKControlViewControllerProtocol.h"

@class BLKADCPort;

@class BLKGaugeView;

@interface BLKADCViewController : UIViewController <BLKControlViewControllerProtocol>

@property (nonatomic, readonly) BLKADCPort* ADCPort;

@property (nonatomic, weak) IBOutlet UILabel* maxLabel;
@property (nonatomic, weak) IBOutlet UILabel* minLabel;
@property (nonatomic, weak) IBOutlet UIView* gaugesView;

@end
