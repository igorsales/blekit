//
//  BLKManager.h
//  BLEKit
//
//  Created by Igor Sales on 2014-09-14.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class BLKManager;
@class BLKDevice;
@class BLKConfiguration;

@protocol BLKDeviceDiscovery <NSObject>

- (void)managerDidUpdateState:(BLKManager*)manager;
- (void)manager:(BLKManager*)manager didDiscoverDevice:(BLKDevice*)device;

@end

@protocol BLKDeviceConnection <NSObject>

- (void)deviceDidConnect:(BLKDevice*)device;
- (void)deviceDidDisconnect:(BLKDevice*)device;
- (void)deviceAlreadyConnected:(BLKDevice*)device;
- (void)device:(BLKDevice*)device connectionFailedWithError:(NSError*)error;

@end


@interface BLKManager : NSObject

@property (nonatomic, readonly) CBCentralManager* centralManager;

// operations
- (void)serializeConfiguration:(BLKConfiguration*)configuration;
- (BLKConfiguration*)deserializedConfigurationForDevice:(BLKDevice*)device;

- (void)attachDiscoverer:(id<BLKDeviceDiscovery>)discoverer;
- (void)detachDiscoverer:(id<BLKDeviceDiscovery>)discoverer;

- (void)attach:(id<BLKDeviceConnection>)conn toDevice:(BLKDevice*)device;
- (void)detach:(id<BLKDeviceConnection>)conn fromDevice:(BLKDevice*)device;

- (BLKDevice*)deviceForPeripheral:(CBPeripheral*)peripheral;

@end
