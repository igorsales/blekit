//
//  BLKFirmwareUpdateViewController.h
//  BLEKit
//
//  Created by Igor Sales on 2014-09-14.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLKManager;
@class BLKDiscoveryOperation;
@class BLKLoadManager;
@class BLKLoadsViewController;

@interface BLKFirmwareUpdateViewController : UIViewController

@property (nonatomic, weak)   IBOutlet UITableView* tableView;

@property (nonatomic, strong) IBOutlet BLKManager* manager;
@property (nonatomic, strong) IBOutlet BLKLoadManager* loadManager;
@property (nonatomic, strong)          BLKDiscoveryOperation* discoveryAction;

@property (nonatomic, strong) IBOutlet BLKLoadsViewController* loadsController;

+ (BLKFirmwareUpdateViewController*)firmwareUpdateViewController;

@end
