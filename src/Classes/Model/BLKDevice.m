//
//  BLKDevice.m
//  BLEKit
//
//  Created by Igor Sales on 2014-09-26.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKDevice.h"
#import "BLKOTAUpdateService.h"
#import "BLKDeviceInfoService.h"
#import "BLKPortsService.h"
#import "BLKDevice+Private.h"
#import "BLKService+Private.h"
#import "BLKPort+Private.h"
#import "BLKLog.h"

#import "NSDictionary+TypedAccessors.h"

@interface BLKDevice() <NSCoding, CBPeripheralDelegate>

@property (nonatomic, strong) NSMutableSet* serviceDiscoveryDelegates;
@property (nonatomic, strong) NSMutableSet* services;

@property (nonatomic, strong) CBPeripheral* peripheral;
@property (nonatomic, strong) NSString*     peripheralId;

@property (nonatomic, strong) NSMutableDictionary* portMap;
@property (nonatomic, weak)   NSTimer*             RSSITimer;

@end

@implementation BLKDevice

#pragma mark - Class accessors

+ (NSSet*)keyPathsForValuesAffectingState
{
    return [NSSet setWithObjects:@"peripheral.state", nil];
}

#pragma mark - Setup/teardown

- (void)setup
{
    self.peripheral.delegate       = self;
    self.serviceDiscoveryDelegates = [NSMutableSet new];
    self.signalStrength            = NSNotFound;
    self.connectionListeners       = [NSMutableSet new];
    self.portMap                   = [NSMutableDictionary new];
    self.services                  = [NSMutableSet new];
    self.RSSITimer                 = [NSTimer scheduledTimerWithTimeInterval:2.5
                                                                      target:self
                                                                    selector:@selector(readRSSITimerFired:)
                                                                    userInfo:nil
                                                                     repeats:YES];
}

- (id)initWithPeripheral:(CBPeripheral *)peripheral
{
    if ((self = [super init])) {
        self.peripheral = peripheral;
        [self.peripheral addObserver:self forKeyPath:@"state" options:0 context:nil];
        [self setup];
    }

    return self;
}

- (void)dealloc
{
    [self.RSSITimer invalidate];
    self.RSSITimer = nil;
    [self.peripheral removeObserver:self forKeyPath:@"state" context:nil];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init])) {
        self.peripheralId = [aDecoder decodeObjectForKey:@"peripheralIdentifier"];
        [self setup];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.peripheralIdentifier.UUIDString forKey:@"peripheralIdentifier"];
}

#pragma mark - Accessors

- (BLKDeviceState)state
{
    switch (self.peripheral.state) {
        case CBPeripheralStateDisconnecting:
        case CBPeripheralStateDisconnected: return BLKDeviceStateDisconnected;
        case CBPeripheralStateConnecting: return BLKDeviceStateConnecting;
        case CBPeripheralStateConnected:
            if (self.discoveringServices.count) {
                return BLKDeviceStateUnavailable;
            }
            if (self.updateOperation) {
                return BLKDeviceStateUpdatingFirmware;
            }
            return BLKDeviceStateConnected;
    }
    
    return BLKDeviceStateDisconnected;
}

- (NSUUID*)peripheralIdentifier
{
    if (self.peripheral) {
        return self.peripheral.identifier;
    }
    
    if (self.peripheralId) {
        return [[NSUUID alloc] initWithUUIDString:self.peripheralId];
    }

    return nil;
}

#pragma mark - Private

- (void)readRSSITimerFired:(NSTimer*)timer
{
    if (self.peripheral.state == CBPeripheralStateConnected) {
        [self.peripheral readRSSI];
    }
}

- (void)addServiceDiscoveryDelegate:(id<CBPeripheralDelegate>)delegate
{
    [self.serviceDiscoveryDelegates addObject:delegate];
}

- (void)removeServiceDiscoveryDelegate:(id<CBPeripheralDelegate>)delegate
{
    [self.serviceDiscoveryDelegates removeObject:delegate];
}

- (void)attachService:(BLKService *)service
{
    NSString* key = [service serviceKeyForDevice:self];

    if (key) {
        [self willChangeValueForKey:key];
    }
    if (![self.services containsObject:service]) {
        BLK_LOG(@"Attached useful service %@ to device %@ ", service, self.peripheral.name);
        [self.services addObject:service];
    } else {
        [self reapplyCharacteristicsFromService:service toPortMap:self.portMap];
    }
    service.device = self;
    if (key) {
        [self didChangeValueForKey:key];
    }
}

- (void)detachService:(BLKService *)service
{
    NSString* key = [service serviceKeyForDevice:self];

    if (key) {
        [self willChangeValueForKey:key];
    }
    service.device = nil;
    [self.services removeObject:service];
    if (key) {
        [self didChangeValueForKey:key];
    }
}

- (void)reapplyCharacteristicsFromService:(BLKService*)service toPortMap:(NSDictionary*)map
{
    for (BLKPort* port in map.allValues) {
        if (port.service == service && ![port refreshCharacteristics:service.service.characteristics]) {
            BLK_LOG(@"Error refreshing port characteristics");
        }
    }
}

- (id)serviceWithClassName:(NSString *)className
{
    // TODO: Improve this so the service can be found by ID, and
    //       multiple instances of the same service can be done
    for (BLKService* service in self.services) {
        if ([NSStringFromClass([service class]) isEqualToString:className]) {
            return service;
        }
    }

    return nil;
}

- (id)portOfType:(NSString*)type atIndex:(NSInteger)index subIndex:(NSInteger)subIndex withOptions:(NSDictionary*)options
{
    NSString* portMapKey = [NSString stringWithFormat:@"%@_%@_%@", type, @(index), @(subIndex)];
    __block BLKPort* port = [self.portMap valueForKey:portMapKey];
    if (port) {
        return port;
    }
    
    [self.services enumerateObjectsUsingBlock:^(BLKService* service, BOOL *stop) {
        port = [service portOfType:type atIndex:index subIndex:subIndex withOptions:options];
        if (port) {
            *stop = YES;
            port.peripheral = self.peripheral;
            port.service = service;
        }
    }];
    
    if (port) {
        [self.portMap setValue:port forKey:portMapKey];
    }
    
    return port;
}

- (BLKService*)serviceForCBService:(CBService*)service
{
    CBUUID* serviceUUID = service.UUID;
    
    for (BLKService* existingService in self.services) {
        if ([existingService.serviceUUID isEqual:serviceUUID]) {
            return existingService;
        }
    }
    
    NSPredicate* pred  = [NSPredicate predicateWithFormat:@"%K ==[c] %@", kBLKServiceUUIDKey, serviceUUID.UUIDString];
    NSArray*     descs = [[BLKService servicesDescriptors] filteredArrayUsingPredicate:pred];
    
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
    
    return [[serviceClass alloc] initWithService:service characteristicDescriptors:descriptors];
}

- (void)handlePeripheralStateChange
{
    switch (self.peripheral.state) {
        case CBPeripheralStateConnected: // device got connected, so re-discover services & characteristics
            [self.peripheral discoverServices:nil];
            break;
            
        default:
            break;
    }
}

#pragma mark - CBPeripheralDelegate

#if 0 // deprecated
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (peripheral.RSSI && !error) {
        // TODO: Find better correlation between signal strength and NSInteger
        self.signalStrength = [peripheral.RSSI integerValue];
    }
}
#endif

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    if (RSSI && !error) {
        // TODO: Find better correlation between signal strength and NSInteger
        self.signalStrength = [RSSI integerValue];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        BLK_LOG(@"Error discovering services %@", error);
        return;
    }
    
    self.discoveringServices = [NSMutableSet setWithArray:peripheral.services];
    for (CBService* service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    [self.discoveringServices removeObject:service];
    
    if (error) {
        BLK_LOG(@"Error discovering characteristics %@", error);
        return;
    }
    
    BLKService* BLKService = [self serviceForCBService:service];
    if ([BLKService parsePeripheralServices:peripheral] && BLKService.service) {
        if ([BLKService parseServiceCharacteristics:service]) {
            BLKService.isServiceUsable = [BLKService shouldMakeServiceUsable];
            if (BLKService.isServiceUsable) {
                [self attachService:BLKService];
            } else {
                [self detachService:BLKService];
            }
            
            for (id<BLKDeviceServiceDiscovery> listener in self.serviceDiscoveryDelegates) {
                [listener device:self finishedDiscoveringService:BLKService];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        BLK_LOG(@"error: %@", error);
        return;
    }

    for (BLKService* service in self.services) {
        [service device:self didUpdateNotificationStateForCharacteristic:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        BLK_LOG(@"error: %@", error);
        for (BLKService* service in self.services) {
            [service device:self didFailToUpdateValueForCharacteristic:characteristic withError:error];
        }
        return;
    }
    
    for (BLKService* service in self.services) {
        [service device:self didUpdateValueForCharacteristic:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        BLK_LOG(@"error: %@", error);
        for (BLKService* service in self.services) {
            [service device:self didFailToWriteValueForCharacteristic:characteristic withError:error];
        }
        return;
    }

    for (BLKService* service in self.services) {
        [service device:self didWriteValueForCharacteristic:characteristic];
    }
}

#pragma mark - KVO 

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.peripheral && [keyPath isEqualToString:@"state"]) {
        [self handlePeripheralStateChange];
    }
}

@end
