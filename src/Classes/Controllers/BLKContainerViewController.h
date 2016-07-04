//
//  BLKContainerViewController.h
//  BLEKit
//
//  Created by Igor Sales on 2014-10-18.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLKManager;
@class BLKConfiguration;

@interface BLKContainerViewController : UIViewController

@property (nonatomic, weak)   BLKManager*       manager;
@property (nonatomic, strong) BLKConfiguration* configuration;

- (IBAction)addWidget:(id)sender;
- (IBAction)saveConfiguration:(id)sender;

@end
