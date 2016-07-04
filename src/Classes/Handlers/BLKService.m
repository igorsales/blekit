//
//  BLKService.m
//  BLEKit
//
//  Created by Igor Sales on 2014-09-24.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKService.h"
#import "NSString+CapitalizedSelector.h"
#import "BLKLog.h"
#import "BLKDevice.h"
#import "BLKService+Private.h"
#import "NSDictionary+TypedAccessors.h"

NSString* const kBLKServiceCharacteristicUUIDKey         = @"kBLKServiceCharacteristicUUID";
NSString* const kBLKServiceCharacteristicPropertyRootKey = @"kBLKServiceCharacteristicPropertyRoot";
NSString* const kBLKServiceUUIDKey                       = @"kBLKServiceUUID";
NSString* const kBLKServiceClassKey                      = @"kBLKServiceClass";
NSString* const kBLKServiceCharacteristicsKey            = @"kBLKServiceCharacteristics";

@interface BLKService() <CBPeripheralDelegate>

@property (nonatomic, strong) CBUUID*  serviceUUID;
@property (nonatomic, strong) NSArray* characteristicUUIDs;
@property (nonatomic, strong) NSArray* propertyRoots;

@property (nonatomic, strong) NSMutableDictionary* characteristicListeners;

@end

static NSArray* sServicesDescriptors = nil;
static NSMutableSet* sAdditionalServiceDescriptorPaths = nil;

@implementation BLKService

#pragma mark - Class accessors

+ (NSArray*)servicesDescriptors
{
    if (!sServicesDescriptors) {
        NSString* descriptorsFile = [[NSBundle bundleForClass:[self class]] pathForResource:@"BLKServices.plist" ofType:nil];
        sServicesDescriptors = [NSArray arrayWithContentsOfFile:descriptorsFile];
        
        for (NSString* path in sAdditionalServiceDescriptorPaths) {
            @try {
                NSArray* descriptors = [NSArray arrayWithContentsOfFile:path];
                
                sServicesDescriptors = [sServicesDescriptors arrayByAddingObjectsFromArray:descriptors];
            }
            @catch (NSException *exception) {
                NSLog(@"Couldn't handle BLKService descriptors from file %@", path);
            }
        }
    }
    
    return sServicesDescriptors;
}

#pragma mark - Class methods

+ (void)registerServicesDescriptorAtPath:(NSString *)path
{
    if (!sAdditionalServiceDescriptorPaths) {
        sAdditionalServiceDescriptorPaths = [NSMutableSet new];
    }
    
    [sAdditionalServiceDescriptorPaths addObject:path];

    // reset service descriptors
    sServicesDescriptors = nil;
}

#pragma mark - Setup/teardown

- (id)initWithServiceUUID:(CBUUID*)serviceUUID characteristicDescriptors:(NSArray*)characteristicDescriptors
{
    if ((self = [super init])) {
        self.serviceUUID = serviceUUID;
        
        NSMutableArray* characteristicUUIDs = [NSMutableArray new];
        NSMutableArray* propertyRoots       = [NSMutableArray new];

        for (NSDictionary* desc in characteristicDescriptors) {
            NSString* characteristicUUIDString = [desc stringForKey:kBLKServiceCharacteristicUUIDKey];
            NSString* propertyRoot             = [desc stringForKey:kBLKServiceCharacteristicPropertyRootKey];
            NSString* UUIDSetterName           = [NSString stringWithFormat:@"set%@UUID:", propertyRoot.capitalizedSelectorString];
            NSString* charSetterName           = [NSString stringWithFormat:@"set%@Characteristic:", propertyRoot.capitalizedSelectorString];
            SEL UUIDSetterSel = NSSelectorFromString(UUIDSetterName);
            SEL charSetterSel = NSSelectorFromString(charSetterName);
            
            if ([self respondsToSelector:UUIDSetterSel] && [self respondsToSelector:charSetterSel]) {
                CBUUID* UUID = [CBUUID UUIDWithString:characteristicUUIDString];
                
                //NOTE: below is equiv to [self performSelector:selector withObject:uuidAdd];
                IMP imp = [self methodForSelector:UUIDSetterSel];
                void (*func)(id, SEL, id) = (void *)imp;
                func(self, UUIDSetterSel, UUID);
                
                [characteristicUUIDs addObject:UUID];
                [propertyRoots addObject:propertyRoot];
            } else {
                BLK_LOG(@"Invalid UUID property name specified: %@", UUIDSetterName);
            }
        }

        self.propertyRoots        = propertyRoots;
        self.characteristicUUIDs  = characteristicUUIDs;
        
        self.characteristicListeners = [NSMutableDictionary new];
    }

    return self;
}

- (id)initWithService:(CBService *)service characteristicDescriptors:(NSArray *)descriptors
{
    if ((self = [self initWithServiceUUID:service.UUID characteristicDescriptors:descriptors])) {
        self.service = service;
    }

    return self;
}

#pragma mark - Overrides

- (BOOL)parsePeripheralServices:(CBPeripheral*)peripheral
{
    for (CBService* service in peripheral.services) {
        if ([service.UUID isEqual:self.serviceUUID]) {
            self.service = service;
            
            return YES;
        }
    }

    return NO;
}

- (BOOL)parseServiceCharacteristics:(CBService*)service
{
    BOOL foundCharacteristics = NO;

    for (CBCharacteristic* c in service.characteristics) {
        NSInteger idx = [self.characteristicUUIDs indexOfObject:c.UUID];
        if (idx != NSNotFound) {
            if (idx < self.propertyRoots.count) {
                NSString* propertyName = [self.propertyRoots objectAtIndex:idx];
                NSString* selectorName = [NSString stringWithFormat:@"set%@Characteristic:", propertyName.capitalizedSelectorString];
                SEL selector = NSSelectorFromString(selectorName);
                
                if ([self respondsToSelector:selector]) {
                    // the code below is equivalent to [self performSelector:selector withObject:uuidAdd];
                    
                    IMP imp = [self methodForSelector:selector];
                    void (*func)(id, SEL, id) = (void *)imp;
                    func(self, selector, c);
                    
                    foundCharacteristics = YES;
                    
                    if (c.properties & (CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify | CBCharacteristicPropertyIndicate |
                                        CBCharacteristicPropertyIndicateEncryptionRequired |
                                        CBCharacteristicPropertyNotifyEncryptionRequired)
                        && c.value.length) {
                        // Property already has a value, so just parse it
                        [self device:self.device didUpdateValueForCharacteristic:c];
                    }
                } else {
                    BLK_LOG(@"Invalid characteristic property name specified: %@", selectorName);
                }
            }
        }
    }
    
    return foundCharacteristics;
}

- (BOOL)shouldMakeServiceUsable
{
    // Override this
    return NO;
}

- (id)portOfType:(NSString*)type atIndex:(NSInteger)index subIndex:(NSInteger)subIndex withOptions:(NSDictionary *)options
{
    // Override
    return nil;
}

#pragma mark - Operations

- (void)registerListener:(id)listener forCharacteristicUUID:(CBUUID *)UUID
{
    self.characteristicListeners[UUID.UUIDString] = @{ @"listener": listener };
}

- (void)unregisterListener:(id)listener forCharacteristicUUID:(CBUUID *)UUID
{
    [self.characteristicListeners removeObjectForKey:UUID.UUIDString];
}

#pragma mark - Private

- (NSString*)serviceKeyForDevice:(BLKDevice*)device
{
    return nil;
}

- (void)device:(BLKDevice*)device didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
{
    id listener = self.characteristicListeners[characteristic.UUID.UUIDString][@"listener"];
    
    if ([listener respondsToSelector:@selector(service:didUpdateNotificationStateForCharacteristic:)]) {
        [listener service:self didUpdateNotificationStateForCharacteristic:characteristic];
    }
}

- (void)device:(BLKDevice*)device didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
{
    id listener = self.characteristicListeners[characteristic.UUID.UUIDString][@"listener"];

    if ([listener respondsToSelector:@selector(service:didUpdateValueForCharacteristic:)]) {
        [listener service:self didUpdateValueForCharacteristic:characteristic];
    }
}

- (void)device:(BLKDevice*)device didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
{
    id listener = self.characteristicListeners[characteristic.UUID.UUIDString][@"listener"];

    if ([listener respondsToSelector:@selector(service:didWriteValueForCharacteristic:)]) {
        [listener service:self didWriteValueForCharacteristic:characteristic];
    }
}

- (void)device:(BLKDevice*)device didFailToUpdateValueForCharacteristic:(CBCharacteristic *)characteristic withError:(NSError*)error
{
    id listener = self.characteristicListeners[characteristic.UUID.UUIDString][@"listener"];
    
    if ([listener respondsToSelector:@selector(service:didFailToUpdateValueForCharacteristic:withError:)]) {
        [listener service:self didFailToUpdateValueForCharacteristic:characteristic withError:error];
    }
}

- (void)device:(BLKDevice *)device didFailToWriteValueForCharacteristic:(CBCharacteristic *)characteristic withError:(NSError *)error
{
    id listener = self.characteristicListeners[characteristic.UUID.UUIDString][@"listener"];

    if ([listener respondsToSelector:@selector(service:didFailToWriteValueForCharacteristic:withError:)]) {
        [listener service:self didFailToWriteValueForCharacteristic:characteristic withError:error];
    }
}

@end
