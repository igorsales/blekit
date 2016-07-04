//
//  BLKDevice+Private.h
//  BLEKit
//
//  Created by Igor Sales on 2014-11-29.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKDevice.h"
#import "BLKFirmwareUpdateOperation.h"

@class BLKService;

@protocol BLKDeviceServiceDiscovery <NSObject>

- (void)device:(BLKDevice*)device finishedDiscoveringService:(BLKService*)service;

@end

@interface BLKDevice()

@property (nonatomic, assign) NSInteger signalStrength;

@property (nonatomic, strong) NSMutableSet* connectionListeners;
@property (nonatomic, strong) BLKFirmwareUpdateOperation* updateOperation;
@property (nonatomic, strong) NSMutableSet* discoveringServices;

- (id)initWithPeripheral:(CBPeripheral*)peripheral;

- (void)addServiceDiscoveryDelegate:(id<BLKDeviceServiceDiscovery>)delegate;
- (void)removeServiceDiscoveryDelegate:(id<BLKDeviceServiceDiscovery>)delegate;

- (void)attachService:(BLKService*)service;
- (void)detachService:(BLKService*)service;

- (id)serviceWithClassName:(NSString*)className;

@end