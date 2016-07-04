//
//  BLKDriver.h
//  BLEKit
//
//  Created by Igor Sales on 2014-11-01.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLKPort;

@interface BLKDriver : NSObject

@property (nonatomic, weak) BLKPort* port;

@end
