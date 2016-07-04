//
//  BLKLoadsViewController.h
//  BLEKit
//
//  Created by Igor Sales on 2014-09-19.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLKLoadManager;

@interface BLKLoadsViewController : UIViewController

@property (nonatomic, weak)   IBOutlet UIScrollView* scrollView;

@property (nonatomic, strong) IBOutlet BLKLoadManager* loadsManager;

// operations
- (void)reloadData;

@end
