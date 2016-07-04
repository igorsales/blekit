//
//  BLKOTAUpdatePort.m
//  BLEKit
//
//  Created by Igor Sales on 2014-10-15.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKOTAUpdatePort.h"
#import "BLKPort+Private.h"
#import "BLKUUIDs.h"

NSString* const kBLKPortTypeOTAUpdate = @"kBLKPortTypeOTAUpdate";

@interface BLKOTAUpdatePort()

@property (nonatomic, weak) CBCharacteristic* OTADataCharacteristic;
@property (nonatomic, weak) CBCharacteristic* OTAControlCharacteristic;

@end

@implementation BLKOTAUpdatePort

#pragma mark - Setup/teardown

- (id)initWithPeripheral:(CBPeripheral *)peripheral andCharacteristic:(CBCharacteristic *)characteristic
{
    NSAssert(false, @"This port needs two characteristics");
    self = nil;
    return nil;
}

- (id)initWithPeripheral:(CBPeripheral *)peripheral andCharacteristics:(NSArray *)characteristics
{
    if ((self = [super initWithPeripheral:peripheral andCharacteristics:characteristics])) {
        self.watchdogTimeout = 20.0;
    }

    return self;
}

#pragma mark - Private

- (BOOL)parseCharacteristics:(NSArray*)characteristics
{
    for (CBCharacteristic* c in characteristics) {
        if ([c.UUID isEqual:[CBUUID UUIDWithString:kBLKOTAControlUUID]]) {
            self.OTAControlCharacteristic = c;
        } else if ([c.UUID isEqual:[CBUUID UUIDWithString:kBLKOTADataUUID]]) {
            self.OTADataCharacteristic = c;
        }
    }
    
    return self.OTAControlCharacteristic && self.OTADataCharacteristic;
}

- (BOOL)refreshCharacteristics:(NSArray*)characteristics
{
    return [self parseCharacteristics:characteristics];
}

#pragma mark - Operations

- (void)writeData:(NSData*)data
{
    [self.peripheral writeValue:data
              forCharacteristic:self.OTADataCharacteristic
                           type:CBCharacteristicWriteWithoutResponse];
    [self invalidateWatchdogTimer];
    self.nextCompletionBlock = nil;
    self.nextFailureBlock = nil;
}

- (void)readDataWithCompletion:(void (^)(NSData *))completionBlock
                       failure:(void (^)(void))failureBlock
{
    [self.peripheral readValueForCharacteristic:self.OTADataCharacteristic];

    CBCharacteristic* characteristic = self.OTADataCharacteristic;
    self.nextCompletionBlock = ^{
        if (characteristic.value.length) {
            if (completionBlock) {
                completionBlock(characteristic.value);
            }
        } else {
            if (failureBlock) {
                failureBlock();
            }
        }
    };
    self.nextFailureBlock = failureBlock;
    [self startWatchdogTimer];
}

- (void)writeControlCommand:(OTA_FLASH_CMD)command
                 completion:(void(^)(void))completionBlock
                    failure:(void(^)(void))failureBlock
{
    unsigned char value[1] = { command };

    [self.peripheral writeValue:[NSData dataWithBytes:&value length:1]
              forCharacteristic:self.OTAControlCharacteristic
                           type:CBCharacteristicWriteWithResponse];

    self.nextCompletionBlock = completionBlock;
    self.nextFailureBlock = failureBlock;
    [self startWatchdogTimer];
}

- (void)readControlStatusWithCompletion:(void(^)(NSInteger status))completionBlock
                                failure:(void(^)(void))failureBlock
{
    [self.peripheral readValueForCharacteristic:self.OTAControlCharacteristic];
    
    CBCharacteristic* characteristic = self.OTAControlCharacteristic;
    self.nextCompletionBlock = ^{
        NSData* value = characteristic.value;
        
        if (value.length) {
            const unsigned char *v = (const unsigned char *)[value bytes];
            
            if (completionBlock) {
                completionBlock(*v);
            }
        } else {
            if (failureBlock) {
                failureBlock();
            }
        }
    };
    self.nextFailureBlock = failureBlock;
    [self startWatchdogTimer];
}


@end
