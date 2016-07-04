//
//  BLKControlViewControllerProtocol.h
//  BLEKit
//
//  Created by Igor Sales on 2014-10-22.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

@class BLKControl;
@class BLKPort;

@protocol BLKControlViewControllerProtocol <NSObject>

@property (nonatomic, strong) BLKPort* port;
@property (nonatomic, strong) BLKControl* control;

@optional

// Use to commit current values from controller
- (IBAction)apply:(id)sender;

@end

@protocol BLKConfigurationDelegate <NSObject>

- (IBAction)saveConfiguration:(id)sender;

@end