//
//  BLKManager.m
//  BLEKit
//
//  Created by Igor Sales on 2014-09-14.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKManager.h"
#import "BLKDevice.h"
#import "BLKLog.h"
#import "BLKOperation.h"
#import "BLKOperation+Private.h"
#import "BLKService.h"
#import "BLKConfiguration.h"
#import "BLKDevice+Private.h"
#import "BLKDeviceInfoService.h"

#import "NSOperationQueue+BLEKit.h"
#import "NSFileManager+Dirs.h"

@interface BLKManager() <CBCentralManagerDelegate, NSCoding>

@property (nonatomic, strong) CBCentralManager* centralManager;
@property (nonatomic, strong) NSMutableDictionary* devices;
@property (nonatomic, strong) NSMutableSet* discoverers;

@end

@implementation BLKManager

#pragma mark - Setup/teardown

- (void)setup
{
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    self.centralManager.delegate = self;
    self.discoverers = [NSMutableSet new];
}

- (id)init
{
    if ((self = [super init])) {
        [self setup];
        self.devices = [NSMutableDictionary new];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init])) {
        [self setup];
        self.devices = [[aDecoder decodeObjectForKey:@"devices"] mutableCopy];
        if (!self.devices) {
            self.devices = [NSMutableDictionary new];
        }
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.devices forKey:@"devices"];
}

#pragma mark - Operations

- (NSString*)configurationFilenameForDevice:(BLKDevice*)device
{
    return [NSString stringWithFormat:@"configuration-%@-%@.blekitcfg",
            device.peripheralId ? device.peripheralId : @"placeholder",
            device.info.firmwareID ? device.info.firmwareID : @"(null)"];
}

- (NSString*)configurationPathForDevice:(BLKDevice*)device
{
    return [[NSFileManager documentsDirectoryPath] stringByAppendingPathComponent:[self configurationFilenameForDevice:device]];
}

- (void)serializeConfiguration:(BLKConfiguration*)configuration
{
    NSString* filename = [self configurationPathForDevice:configuration.device];

    [NSKeyedArchiver archiveRootObject:configuration toFile:filename];
}

- (BLKConfiguration*)deserializedConfigurationForDevice:(BLKDevice*)device
{
    NSString* filename = [self configurationPathForDevice:device];

    BLKConfiguration* configuration = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
    
    configuration.device = device;
    
    return configuration;
}

- (void)attachDiscoverer:(id<BLKDeviceDiscovery>)discoverer
{
    [self.discoverers addObject:discoverer];
}

- (void)detachDiscoverer:(id<BLKDeviceDiscovery>)discoverer
{
    [self.discoverers removeObject:discoverer];
}

- (void)attach:(id<BLKDeviceConnection>)conn toDevice:(BLKDevice*)device
{
    if ([device.connectionListeners containsObject:conn]) {
        [conn deviceAlreadyConnected:device];
        return;
    }

    [device.connectionListeners addObject:conn];
    
    if (device.connectionListeners.count == 1) { // 1 => This device has only 1 connection
        switch (device.peripheral.state) {
            case CBPeripheralStateConnected:
                [conn deviceAlreadyConnected:device];
                break;
                
            case CBPeripheralStateConnecting:
                // do nothing, wait until connection finishes
                break;
                
            case CBPeripheralStateDisconnecting: // treat disconnecting as disconnected for now
            case CBPeripheralStateDisconnected:
                [self.centralManager connectPeripheral:device.peripheral options:nil];
        }
    }
}

- (void)detach:(id<BLKDeviceConnection>)conn fromDevice:(BLKDevice*)device
{
    if (![device.connectionListeners containsObject:conn]) {
        return;
    }

    [device.connectionListeners removeObject:conn];
    
    [conn deviceDidDisconnect:device];
    
    if (device.connectionListeners.count == 0) { // 0 => The last listener was let go
        switch (device.peripheral.state) {
            case CBPeripheralStateConnected:
            case CBPeripheralStateConnecting:
                [self.centralManager cancelPeripheralConnection:device.peripheral];
                break;
                
            case CBPeripheralStateDisconnecting: // treat as disconnected
            case CBPeripheralStateDisconnected:
                // do nothing, already disconnected
                break;
        }
    }
}

- (BLKDevice*)deviceForPeripheral:(CBPeripheral *)peripheral
{
    NSString* deviceId = peripheral.identifier.UUIDString;

    BLKDevice* device = [self.devices valueForKey:deviceId];
    if (!device) {
        NSArray* peripherals = [self.centralManager retrievePeripheralsWithIdentifiers:@[peripheral.identifier]];
        if (peripherals.count) {
            CBPeripheral* peripheral = peripherals[0];
            device = [[BLKDevice alloc] initWithPeripheral:peripheral];
            [self.devices setObject:device forKey:deviceId];
        } else {
            BLK_LOG(@"Cannot find peripheral from another CentralManager.");
        }
    }

    return device;
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager*)central
{
    for (id<BLKDeviceDiscovery> discoverer in self.discoverers) {
        [discoverer managerDidUpdateState:self];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    BLKDevice* device = [self deviceForPeripheral:peripheral];

    for (id<BLKDeviceDiscovery> discoverer in self.discoverers) {
        [discoverer manager:self didDiscoverDevice:device];
    }
    
    device.signalStrength = [RSSI integerValue];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    BLKDevice* dev = self.devices[peripheral.identifier.UUIDString];
    
    dev.signalStrength = BLKSignalStrengthUnknown;

    [peripheral readRSSI];
    
    for (id<BLKDeviceConnection> conn in dev.connectionListeners) {
        [conn deviceDidConnect:dev];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    BLKDevice* dev = self.devices[peripheral.identifier.UUIDString];

    dev.signalStrength = BLKSignalStrengthUnknown;

    for (id<BLKDeviceConnection> conn in [dev.connectionListeners copy]) {
        [conn deviceDidDisconnect:dev];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    BLKDevice* dev = self.devices[peripheral.identifier.UUIDString];
    
    dev.signalStrength = BLKSignalStrengthUnknown;

    for (id<BLKDeviceConnection> conn in dev.connectionListeners) {
        [conn device:dev connectionFailedWithError:error];
    }
}

@end
