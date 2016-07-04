//
//  BLKConfiguration.h
//  BLEKit
//
//  Created by Igor Sales on 2014-10-21.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLKControl;
@class BLKDevice;

@interface BLKConfiguration : NSObject

@property (nonatomic, weak)     BLKDevice* device;
@property (nonatomic, readonly) NSArray* controls;

- (void)addControl:(BLKControl*)control;
- (void)removeControl:(BLKControl*)control;

@end
