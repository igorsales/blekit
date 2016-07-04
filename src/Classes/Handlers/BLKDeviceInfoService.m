//
//  BLKDeviceInfoService.m
//  BLEKit
//
//  Created by Igor Sales on 2014-09-23.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKDeviceInfoService.h"
#import "BLKUUIDs.h"
#import "BLKDevice.h"
#import "BLKService+Private.h"
#import "BLKDevice+Private.h"

@interface BLKDeviceInfoService()

@property (nonatomic, strong) CBUUID* manufacturerStringUUID;
@property (nonatomic, strong) CBUUID* modelNumberStringUUID;
@property (nonatomic, strong) CBUUID* firmwareRevisionStringUUID;
@property (nonatomic, strong) CBUUID* hardwareRevisionStringUUID;
@property (nonatomic, strong) CBUUID* firmwareIDStringUUID;

@property (nonatomic, strong) CBCharacteristic* manufacturerStringCharacteristic;
@property (nonatomic, strong) CBCharacteristic* modelNumberStringCharacteristic;
@property (nonatomic, strong) CBCharacteristic* firmwareRevisionStringCharacteristic;
@property (nonatomic, strong) CBCharacteristic* hardwareRevisionStringCharacteristic;
@property (nonatomic, strong) CBCharacteristic* firmwareIDStringCharacteristic;

@end

@implementation BLKDeviceInfoService

#pragma mark - Class KVO

+ (NSSet*)keyPathsForValuesAffectingHardwareID
{
    return [NSSet setWithObjects:@"modelNumber", nil];
}

#pragma mark - Accessors

- (NSString*)manufacturer
{
    return [[NSString alloc] initWithData:self.manufacturerStringCharacteristic.value encoding:NSUTF8StringEncoding];
}

- (NSString*)modelNumber
{
    return [[NSString alloc] initWithData:self.modelNumberStringCharacteristic.value encoding:NSUTF8StringEncoding];
}

- (NSString*)firmwareRevision
{
    return [[NSString alloc] initWithData:self.firmwareRevisionStringCharacteristic.value encoding:NSUTF8StringEncoding];
}

- (NSString*)hardwareRevision
{
    return [[NSString alloc] initWithData:self.hardwareRevisionStringCharacteristic.value encoding:NSUTF8StringEncoding];
}

- (NSString*)firmwareID
{
    return [[NSString alloc] initWithData:self.firmwareIDStringCharacteristic.value encoding:NSUTF8StringEncoding];
}

- (NSString*)hardwareID
{
    return self.modelNumber;
}

#pragma mark - Accessor overrides

- (void)setDevice:(BLKDevice *)device
{
    [super setDevice:device];
}

#pragma mark - Private

- (NSString*)serviceKeyForDevice:(BLKDevice*)device
{
    return @"info";
}

#pragma mark - Overrides

- (BOOL)parseServiceCharacteristics:(CBService *)service
{
    BOOL r = [super parseServiceCharacteristics:service];

    if (r) {
        // Always update the characteristics
        if (self.manufacturerStringCharacteristic) {
            [service.peripheral readValueForCharacteristic:self.manufacturerStringCharacteristic];
        }
        
        if (self.modelNumberStringCharacteristic) {
            [service.peripheral readValueForCharacteristic:self.modelNumberStringCharacteristic];
        }
        
        if (self.firmwareRevisionStringCharacteristic) {
            [service.peripheral readValueForCharacteristic:self.firmwareRevisionStringCharacteristic];
        }
        
        if (self.hardwareRevisionStringCharacteristic) {
            [service.peripheral readValueForCharacteristic:self.hardwareRevisionStringCharacteristic];
        }
        
        if (self.firmwareIDStringCharacteristic) {
            [service.peripheral readValueForCharacteristic:self.firmwareIDStringCharacteristic];
        }
    }
    
    return r;
}

- (BOOL)shouldMakeServiceUsable
{
    return (self.manufacturerStringCharacteristic &&
            self.modelNumberStringCharacteristic &&
            self.firmwareRevisionStringCharacteristic &&
            self.hardwareRevisionStringCharacteristic &&
            self.firmwareIDStringCharacteristic);
}

- (void)device:(BLKDevice*)device didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic;
{
    NSString* key = nil;

    if (characteristic == self.manufacturerStringCharacteristic) {
        key = @"manufacturer";
    } else if (characteristic == self.modelNumberStringCharacteristic) {
        key = @"modelNumber";
    } else if (characteristic == self.firmwareIDStringCharacteristic) {
        key = @"firmwareID";
    } else if (characteristic == self.hardwareRevisionStringCharacteristic) {
        key = @"hardwareRevision";
    } else if (characteristic == self.firmwareRevisionStringCharacteristic) {
        key = @"firmwareRevision";
    }
    
    if (key) {
        [self willChangeValueForKey:key];
        [self didChangeValueForKey:key];
    }
    
    [super device:device didUpdateValueForCharacteristic:characteristic];
}

@end

@implementation BLKDevice(InfoService)

- (BLKDeviceInfoService*)info
{
    return [self serviceWithClassName:NSStringFromClass([BLKDeviceInfoService class])];
}

@end
