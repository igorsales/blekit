//
//  BLKLoadsTableViewController.h
//  BLEKit
//
//  Created by Igor Sales on 2014-10-13.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLKLoadManager;
@class BLKDevice;
@class BLKLoadsTableViewController;
@class BLKLoad;

@protocol BLKLoadsTableViewControllerDelegate <NSObject>

- (void)loadsController:(BLKLoadsTableViewController*)controller didSelectLoadToInstall:(BLKLoad*)load;

@end

@interface BLKLoadsTableViewController : UITableViewController

@property (nonatomic, weak)            BLKDevice*      device;
@property (nonatomic, strong) IBOutlet BLKLoadManager* loadsManager;

@property (nonatomic, weak) id<BLKLoadsTableViewControllerDelegate> delegate;

@end
