//
//  BLKPWMChannelPort.m
//  BLEKit
//
//  Created by Igor Sales on 2014-10-03.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKPWMChannelsPort.h"
#import "BLKPort.h"
#import "BLKPort+Private.h"

#define PULSE_CENTRE     (1500.0)
#define HALF_PULSE_WIDTH (500.0)

NSString* const kBLKPortTypePWMChannels = @"kBLKPortTypePWMChannels";

@interface BLKPWMChannelsPort() {
    struct {
        UInt16 value[kBLKMaxNumberOfPWMChannelsPerCharacteristic];
        UInt16 cache[kBLKMaxNumberOfPWMChannelsPerCharacteristic];
    } _channels;
}

@property (nonatomic, assign) CGFloat  lastPulseWidth;

@end

@implementation BLKPWMChannelsPort

- (id)initWithPeripheral:(CBPeripheral *)peripheral andCharacteristic:(CBCharacteristic *)characteristic
{
    if ((self = [super initWithPeripheral:peripheral andCharacteristic:characteristic])) {
        NSAssert(sizeof(_channels) == 2 * sizeof(UInt16) * kBLKMaxNumberOfPWMChannelsPerCharacteristic, @"Data structure not aligned properly");
        for (NSInteger i = 0; i < kBLKMaxNumberOfPWMChannelsPerCharacteristic; i++) {
            _channels.value[i] = PULSE_CENTRE;
            _channels.cache[i] = PULSE_CENTRE;
        }
    }

    return self;
}

- (void)setPulseWidth:(CGFloat)pulseWidth forChannel:(NSInteger)channelIndex
{
    [self setPulseWidth:pulseWidth forChannel:channelIndex commit:YES];
}

- (void)setPulseWidth:(CGFloat)pulseWidth forChannel:(NSInteger)channelIndex commit:(BOOL)commit
{
    [self setRawPulseWidth:pulseWidth * HALF_PULSE_WIDTH + PULSE_CENTRE forChannel:channelIndex commit:commit];
}

- (void)setRawPulseWidth:(CGFloat)pulseWidth forChannel:(NSInteger)channelIndex
{
    [self setRawPulseWidth:pulseWidth forChannel:channelIndex commit:YES];
}

- (void)setRawPulseWidth:(CGFloat)pulseWidth forChannel:(NSInteger)channelIndex commit:(BOOL)commit
{
    if (channelIndex < 0 || channelIndex >= self.numberOfChannels) {
        return;
    }
    
    _channels.cache[channelIndex] = pulseWidth;
    
    if (commit) {
        [self commit];
    }
}

- (void)commit
{
    if (self.operationInProgress) {
        return;
    }
    
    if (memcmp(_channels.value, _channels.cache, sizeof(UInt16)*self.numberOfChannels) == 0) {
        // Nothing new to write, so bail
        return;
    }

    // Now copy, and send it over.
    memcpy(_channels.value, _channels.cache, sizeof(UInt16)*self.numberOfChannels);
    
    [self writePulseWidths];
    [self startWatchdogTimer];
}

- (CGFloat)pulseWidthForChannel:(NSInteger)channelIndex
{
    if (channelIndex < 0 || channelIndex >= self.numberOfChannels) {
        return 0.0;
    }
    
    return ((CGFloat)_channels.cache[channelIndex] - PULSE_CENTRE) / HALF_PULSE_WIDTH;
}

#pragma mark - Private

- (void)writePulseWidths
{
    NSAssert(self.peripheral, @"nil peripheral");

    NSData* pulseData = [NSData dataWithBytes:_channels.value length:sizeof(UInt16)*self.numberOfChannels];

    [self.peripheral writeValue:pulseData
              forCharacteristic:self.characteristic
                           type:CBCharacteristicWriteWithResponse]; // TODO: Check if can be without response

    __weak typeof(self) weakSelf = self;
    void *values = _channels.value;
    void *caches = _channels.cache;

    self.nextCompletionBlock = ^{
        if (weakSelf.operationInProgress) {
            if (memcmp(values, caches, sizeof(UInt16)*weakSelf.numberOfChannels)) {

                memcpy(values, caches, sizeof(UInt16)*weakSelf.numberOfChannels);
                [weakSelf writePulseWidths];
                [weakSelf startWatchdogTimer];
            }
        }
    };
    self.nextFailureBlock = ^{
    };
}

@end
