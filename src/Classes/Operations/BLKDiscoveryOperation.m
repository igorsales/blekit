//
//  BLKDiscoveryOperation.m
//  BLEKit
//
//  Created by Igor Sales on 2014-10-05.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKDiscoveryOperation.h"
#import "BLKPortsService.h"
#import "BLKOperation+Private.h"
#import "BLKDevice+Private.h"
#import "BLKManager.h"
#import "BLKUUIDs.h"
#import "BLKLog.h"

#import "NSDictionary+TypedAccessors.h"

@interface BLKDiscoveryOperation() <BLKDeviceDiscovery, BLKDeviceConnection, BLKDeviceServiceDiscovery>

@property (nonatomic, weak)     BLKManager* manager;
@property (nonatomic, strong)   NSMutableSet* discovered;
@property (nonatomic, readonly) NSArray* servicesDescriptors;
@property (nonatomic, assign)   BOOL isScanning;

@property (nonatomic, strong)   NSMutableDictionary* discoveredPeripheralServiceUUIDs;

@end


@implementation BLKDiscoveryOperation

#pragma mark - Setup/teardown

- (id)initWithManager:(BLKManager *)manager
{
    if ((self = [super init])) {
        self.manager = manager;
        self.discoveredPeripheralServiceUUIDs = [NSMutableDictionary new];
        self.advertisingUUIDs = @[ [CBUUID UUIDWithString:kBLKPortsServiceUUID] ];
    }

    return self;
}

#pragma mark - Accessors

- (NSArray*)discoveredDevices
{
    return [self.discovered allObjects];
}

@synthesize servicesDescriptors = _servicesDescriptors;

- (NSArray*)servicesDescriptors
{
    if (!_servicesDescriptors) {
        NSString* descriptorsFile = [[NSBundle bundleForClass:[self class]] pathForResource:@"BLKServices.plist" ofType:nil];
        _servicesDescriptors = [NSArray arrayWithContentsOfFile:descriptorsFile];
    }

    return _servicesDescriptors;
}

#pragma mark - Operations

- (void)start
{
    [self.manager attachDiscoverer:self];
    
    // scan all devices, and connect to devices advertising the BLK Ports service
    self.isScanning = YES;
    self.discovered = [NSMutableSet new];
    
    [self scan];
}

- (void)stop
{
    self.isScanning = NO;
    [self.manager.centralManager stopScan];
    [self.manager detachDiscoverer:self];
}

#pragma mark - Private

- (void)scan
{
    [self.manager.centralManager scanForPeripheralsWithServices:self.advertisingUUIDs
                                                        options:nil];
}

- (BLKService*)serviceForCBService:(CBService*)service
{
    CBUUID* serviceUUID = service.UUID;

    NSPredicate* pred = [NSPredicate predicateWithFormat:@"%K ==[c] %@", kBLKServiceUUIDKey, serviceUUID];
    NSArray* descs = [self.servicesDescriptors filteredArrayUsingPredicate:pred];
    
    if (descs.count < 1) {
        return nil;
    }

    NSDictionary* desc = descs[0];
    Class serviceClass = NSClassFromString([desc stringForKey:kBLKServiceClassKey]);
    if (!serviceClass) {
        serviceClass = [BLKService class];
    }
    
    NSArray* descriptors = [desc arrayForKey:kBLKServiceCharacteristicsKey];
    if (!descriptors) {
        return nil;
    }
    
    BLKService* serv = [[serviceClass alloc] initWithServiceUUID:serviceUUID characteristicDescriptors:descriptors];
    return serv;
}

#pragma mark - BLKDeviceDiscovery

- (void)managerDidUpdateState:(BLKManager *)manager
{
    BLK_LOG(@"centraManagerDidUpdateState: %d", (int)manager.centralManager.state);
    
    switch (manager.centralManager.state) {
        case CBCentralManagerStatePoweredOn:
            if (self.isScanning) {
                [self scan];
            }
            break;
            
        default:
            break;
    }
}

- (void)manager:(BLKManager *)manager didDiscoverDevice:(BLKDevice *)device
{
    if ([self.discovered containsObject:device]) {
        return;
    }

    [self.manager attach:self toDevice:device];
    
    [self.discovered addObject:device];
    
    // notify delegate of discovery
    [self.delegate discoveryOperationDidUpdateDiscoveredPeripherals:self];
}

#pragma mark - BLKDeviceConnection

- (void)deviceDidConnect:(BLKDevice*)device
{
    if (device.peripheral.services.count == 0) {
        [device addServiceDiscoveryDelegate:self];
        [device.peripheral discoverServices:nil];
        [device.peripheral readRSSI];
    }
}

- (void)deviceDidDisconnect:(BLKDevice*)device
{
    [device removeServiceDiscoveryDelegate:self];
    [self.manager detach:self fromDevice:device];
}

- (void)deviceAlreadyConnected:(BLKDevice*)device
{
    if (device.peripheral.services.count == 0) {
        [device addServiceDiscoveryDelegate:self];
        [device.peripheral discoverServices:nil];
    }
}

- (void)device:(BLKDevice*)device connectionFailedWithError:(NSError*)error
{
    [device removeServiceDiscoveryDelegate:self];
    [self.manager detach:self fromDevice:device];
}

#pragma mark - BLKDeviceServiceDiscovery

- (void)device:(BLKDevice*)device finishedDiscoveringService:(BLKService*)service
{
    //[self.delegate discoveryOperation:self didUpdateDevice:device];
    
    if (device.discoveringServices.count == 0) {
        // We went through all services, ready to let go.
        [device removeServiceDiscoveryDelegate:self];
        [self.manager detach:self fromDevice:device];
        
        BOOL removed = NO;
        if ([self.delegate respondsToSelector:@selector(discoveryOperation:shouldKeepDevice:)]) {
            if (![self.delegate discoveryOperation:self shouldKeepDevice:device]) {
                [self.discovered removeObject:device];
                [self.delegate discoveryOperationDidUpdateDiscoveredPeripherals:self];
                removed = YES;
            }
        }
        
        if (!removed) {
            [self.delegate discoveryOperation:self didUpdateDevice:device];
        }
    }
}

@end
