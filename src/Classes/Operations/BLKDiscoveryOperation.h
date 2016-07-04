//
//  BLKDiscoveryOperation.h
//  BLEKit
//
//  Created by Igor Sales on 2014-10-05.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <BLEKit/BLKOperation.h>

@class BLKDiscoveryOperation;
@class BLKDevice;
@class BLKManager;

@protocol BLKDiscoveryOperationDelegate <NSObject>

- (void)discoveryOperationDidUpdateDiscoveredPeripherals:(BLKDiscoveryOperation*)action;
- (void)discoveryOperation:(BLKDiscoveryOperation*)operation didUpdateDevice:(BLKDevice*)device;

@optional
- (BOOL)discoveryOperation:(BLKDiscoveryOperation*)operation shouldKeepDevice:(BLKDevice*)device;

@end


@interface BLKDiscoveryOperation : BLKOperation

@property (nonatomic, strong)             NSArray* advertisingUUIDs;

@property (nonatomic, readonly)           BOOL isScanning;
@property (nonatomic, weak)     IBOutlet  id<BLKDiscoveryOperationDelegate> delegate;
@property (nonatomic, readonly)           NSArray* discoveredDevices;

- (id)initWithManager:(BLKManager*)manager;

// Operations
- (void)start;
- (void)stop;

@end
