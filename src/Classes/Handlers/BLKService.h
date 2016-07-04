//
//  BLKService.h
//  BLEKit
//
//  Created by Igor Sales on 2014-09-24.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "BLKPort.h"

extern NSString* const kBLKServiceCharacteristicUUIDKey;
extern NSString* const kBLKServiceCharacteristicPropertyRootKey;
extern NSString* const kBLKServiceUUIDKey;
extern NSString* const kBLKServiceClassKey;
extern NSString* const kBLKServiceCharacteristicsKey;

@class BLKDevice;

@interface BLKService : NSObject

@property (nonatomic, weak)      CBService* service;
@property (nonatomic, readonly)  CBUUID*    serviceUUID;

@property (nonatomic, readonly, weak)  BLKDevice* device;
@property (nonatomic, readonly)        BOOL         isServiceUsable;

+ (void)registerServicesDescriptorAtPath:(NSString*)path;

+ (NSArray*)servicesDescriptors;

- (id)initWithServiceUUID:(CBUUID*)serviceUUID characteristicDescriptors:(NSArray*)characteristicDescriptors;
- (id)initWithService:(CBService*)service characteristicDescriptors:(NSArray*)descriptors;

// Overrides
- (BOOL)parsePeripheralServices:(CBPeripheral*)peripheral;
- (BOOL)parseServiceCharacteristics:(CBService*)service;
- (BOOL)shouldMakeServiceUsable;
- (id)portOfType:(NSString*)type atIndex:(NSInteger)index subIndex:(NSInteger)subIndex withOptions:(NSDictionary *)options;

// Operations
- (void)registerListener:(id<BLKCharacteristicListener>)listener forCharacteristicUUID:(CBUUID *)UUID;
- (void)unregisterListener:(id<BLKCharacteristicListener>)listener forCharacteristicUUID:(CBUUID *)UUID;

@end
