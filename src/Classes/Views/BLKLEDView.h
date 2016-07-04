//
//  BLKLEDView.h
//  BLEKit
//
//  Created by Igor Sales on 2015-05-15.
//  Copyright (c) 2015 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLKLEDView : UIControl

@property (nonatomic, strong) UIColor*  LEDColour;
@property (nonatomic, assign) BOOL      on;
@property (nonatomic, assign) NSInteger number;

- (void)toggle;

@end
