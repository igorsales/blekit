//
//  BLKOperation.h
//  BLEKit
//
//  Created by Igor Sales on 2014-10-06.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLKManager;

@interface BLKOperation : NSObject

@property (nonatomic, weak) BLKManager* deviceManager;

- (void)start;
- (void)stop;

@end
