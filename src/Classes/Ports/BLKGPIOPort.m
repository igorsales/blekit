//
//  BLKGPIOPort.m
//  BLEKit
//
//  Created by Igor Sales on 2015-05-15.
//  Copyright (c) 2015 IgorSales.ca. All rights reserved.
//

#import "BLKGPIOPort.h"
#import "BLKPort+Private.h"

NSString* kBLKPortTypeGPIO_Inputs  = @"kBLKPortTypeGPIO_Inputs";
NSString* kBLKPortTypeGPIO_Outputs = @"kBLKPortTypeGPIO_Outputs";

@interface BLKGPIOPort()

@property (nonatomic, assign) NSUInteger status;
@property (nonatomic, assign) NSUInteger statusCache;

@end

@implementation BLKGPIOPort

@synthesize numberOfPins = _numberOfPins;
@synthesize canRead      = _canRead;
@synthesize canWrite     = _canWrite;
@synthesize canNotify    = _canNotify;

- (void)setCharacteristic:(CBCharacteristic *)characteristic
{
    [super setCharacteristic:characteristic];
    
    _canRead   = characteristic.properties & CBCharacteristicPropertyRead;
    _canWrite  = characteristic.properties & (CBCharacteristicPropertyWrite | CBCharacteristicPropertyWriteWithoutResponse);
    _canNotify = characteristic.properties & CBCharacteristicPropertyNotify;
    
    if (_canNotify) {
        [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
    }
}

#pragma mark - Operations

- (void)read
{
    if (self.operationInProgress) {
        return;
    }
    
    [self.peripheral readValueForCharacteristic:self.characteristic];
    [self startWatchdogTimer];
    
    NSUInteger* statusPtr = &_status;
    NSUInteger* statusCachePtr = &_statusCache;
    
    __weak typeof(self) weakSelf = self;
    self.nextCompletionBlock = ^{
        
        NSUInteger bits = 0;
        [weakSelf.characteristic.value getBytes:&bits length:1];
        
        [weakSelf willChangeValueForKey:@"status"];
        *statusPtr = *statusCachePtr = bits;
        [weakSelf didChangeValueForKey:@"status"];
    };
    
    self.nextFailureBlock = ^{
    };
}

- (void)write:(NSUInteger)bits mask:(NSUInteger)mask commit:(BOOL)commit
{
    _statusCache = (_statusCache & ~mask) | (bits & mask);

    if (commit) {
        [self commit];
    }
}

- (void)commit
{
    if (self.operationInProgress) {
        return;
    }
    
    if (_status == _statusCache) {
        // Nothing new to write, so bail
        return;
    }
    
    // Now copy, and send it over.
    _status = _statusCache;
    
    [self writeBits];
    [self startWatchdogTimer];
}

- (void)writeBits
{
    NSAssert(self.peripheral, @"nil peripheral");
    
    NSInteger length = 1; // TODO: For now, assume only 8 bits at most
    
    NSData* bitsData = [NSData dataWithBytes:&_status length:length];
    
    [self.peripheral writeValue:bitsData
              forCharacteristic:self.characteristic
                           type:CBCharacteristicWriteWithResponse]; // TODO: Check if can be without response
    
    __weak typeof(self) weakSelf = self;
    NSUInteger *status = &_status;
    NSUInteger *cache  = &_statusCache;
    
    self.nextCompletionBlock = ^{
        if (weakSelf.operationInProgress) {
            if (*status != *cache) {
                
                *status = *cache;
                [weakSelf writeBits];
                [weakSelf startWatchdogTimer];
            }
        }
    };

    self.nextFailureBlock = ^{
        // Do nothing
    };
}

#pragma mark - Overrides

- (void)service:(BLKService *)service didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
{
    NSUInteger bits = 0;
    [characteristic.value getBytes:&bits length:1];

    [self willChangeValueForKey:@"status"];
    _status = _statusCache = bits;
    [self didChangeValueForKey:@"status"];
}

@end
