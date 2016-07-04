//
//  BLKADCPort.m
//  BLEKit
//
//  Created by Igor Sales on 2015-06-10.
//  Copyright (c) 2015 IgorSales.ca. All rights reserved.
//

#import "BLKADCPort.h"
#import "BLKPort+Private.h"

NSString* const kBLKPortTypeADCs = @"kBLKPortTypeADCs";

@interface BLKADCPort() {
    struct {
        SInt16 value[kBLKMaxNumberOfADCsPerCharacteristic];
    } _channels;
}

@end

@implementation BLKADCPort

- (id)initWithPeripheral:(CBPeripheral *)peripheral andCharacteristic:(CBCharacteristic *)characteristic
{
    if ((self = [super initWithPeripheral:peripheral andCharacteristic:characteristic])) {
        NSAssert(sizeof(_channels) == sizeof(UInt16) * kBLKMaxNumberOfADCsPerCharacteristic, @"Data structure not aligned properly");
        for (NSInteger i = 0; i < kBLKMaxNumberOfADCsPerCharacteristic; i++) {
            _channels.value[i] = 0x0000;
        }
    }
    
    return self;
}

- (void)read
{
    if (self.operationInProgress) {
        return;
    }
    
    [self.peripheral readValueForCharacteristic:self.characteristic];
    [self startWatchdogTimer];

    void* channelsPtr = _channels.value;
    
    __weak typeof(self) weakSelf = self;
    self.nextCompletionBlock = ^{
        [weakSelf willChangeValueForKey:@"status"];
        
        if (weakSelf.characteristic.value.length >= weakSelf.numberOfPins * sizeof(UInt16)) {
            [weakSelf.characteristic.value getBytes:channelsPtr length:sizeof(UInt16) * weakSelf.numberOfPins];
        }
        
        [weakSelf didChangeValueForKey:@"status"];
    };

    self.nextFailureBlock = ^{
    };
}

- (SInt16)readingForPin:(NSInteger)pin
{
    if (pin < 0 || pin > self.numberOfPins) {
        return NAN;
    }

    // 2's complement 12-bit resolution left-aligned in 16 bits
    return _channels.value[pin];
}

@end
