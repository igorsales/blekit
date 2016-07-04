//
//  BLKDevicesViewController.h
//  BLEKit
//
//  Created by Igor Sales on 2014-10-05.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BLKDiscoveryOperation.h"

@class BLKDevice;
@class BLKDevicesViewController;
@class BLKLoadManager;

@protocol BLKDevicesViewControllerDelegate <NSObject>

- (void)devicesViewController:(BLKDevicesViewController*)controller didSelectDevice:(BLKDevice*)device;

@end

@class BLKManager;

@interface BLKDevicesViewController : UITableViewController <BLKDiscoveryOperationDelegate>

@property (nonatomic, strong) BLKManager* manager;
@property (nonatomic, strong) BLKDiscoveryOperation* discoveryOperation;

@property (nonatomic, weak)   IBOutlet id<BLKDevicesViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet BLKLoadManager* loadsManager;

@end
