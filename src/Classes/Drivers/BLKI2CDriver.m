//
//  BLKI2CDriver.m
//  BLEKit
//
//  Created by Igor Sales on 2014-11-01.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKI2CDriver.h"
#import "BLKI2CControlPort.h"
#import "BLKLog.h"

@implementation BLKI2CDriver

#pragma mark - Accessor

- (BLKI2CControlPort*)I2CPort
{
    return (BLKI2CControlPort*)self.port;
}

#pragma mark - Operations

- (void)readModifyWriteValue:(NSInteger)value register:(NSInteger)regAddr mask:(NSInteger)mask
{
    [self.I2CPort readBytes:1
           fromSlaveAddress:self.slaveAddress
         andRegisterAddress:regAddr
                 completion:^(NSData *data) {
                     NSMutableData* buffer = [data mutableCopy];
                     unsigned char *ptr = [buffer mutableBytes];
                     ptr[0] = (ptr[0] & ~mask);
                     ptr[0] = (ptr[0] | (value & mask));
                     
                     [self.I2CPort writeBytes:buffer
                               toSlaveAddress:self.slaveAddress
                           andRegisterAddress:regAddr
                                   completion:^(NSInteger written) {
                                       // Do nothing, success
                                       [self value:value wasWrittenToRegister:regAddr];
                                   } failure:^{
                                       BLK_LOG(@"failed to read/modify/write regAddr %02x on slave addr %02x", (int)regAddr, (int)self.slaveAddress);
                                       [self failedWritingValue:value toRegister:regAddr];
                                   }];
                     
                 } failure:^{
                     BLK_LOG(@"failed to read value from regAddr %02x on slave addr %02x", (int)regAddr, (int)self.slaveAddress);
                     [self failedReadingFromRegister:regAddr];
                 }];
}

- (void)writeValue:(NSInteger)value register:(NSInteger)regAddr
{
    unsigned char buffer[1] = { value };

    [self.I2CPort writeBytes:[NSData dataWithBytes:buffer length:1]
              toSlaveAddress:self.slaveAddress
          andRegisterAddress:regAddr
                  completion:^(NSInteger written) {
                      // Do nothing, success
                      [self value:value wasWrittenToRegister:regAddr];
                  }
                     failure:^{
                         BLK_LOG(@"failed to write value to reg addr %02x on slave addr %02x", (int)regAddr, (int)self.slaveAddress);
                         [self failedWritingValue:value toRegister:regAddr];
                     }];
}

- (void)readValueFromRegister:(NSInteger)regAddr
{
    [self.I2CPort readBytes:1
           fromSlaveAddress:self.slaveAddress
         andRegisterAddress:regAddr
                 completion:^(NSData *data) {
                     unsigned char* ptr = (unsigned char *)[data bytes];
                     [self value:ptr[0] wasReadFromRegister:regAddr];
                 } failure:^{
                     BLK_LOG(@"failed to read from reg addr %02x on slave addr %02x", (int)regAddr, (int)self.slaveAddress);
                     [self failedReadingFromRegister:regAddr];
                 }];
}

- (void)readBytes:(NSInteger)length startingAtRegister:(NSInteger)regAddr
{
    [self.I2CPort readBytes:length
           fromSlaveAddress:self.slaveAddress
         andRegisterAddress:regAddr
                 completion:^(NSData *data) {
                     [self data:data wasReadFromRegister:regAddr];
                 } failure:^{
                     BLK_LOG(@"failed to read %d bytes from reg addr %02x on slave addr %02x", (int)length, (int)regAddr, (int)self.slaveAddress);
                 }];
}

#pragma mark - Overrides

- (void)value:(NSInteger)value wasReadFromRegister:(NSInteger)regAddr
{
    // do nothing, meant to be overwritten
}

- (void)value:(NSInteger)value wasWrittenToRegister:(NSInteger)regAddr
{
    // do nothing, meant to be overwritten
}

- (void)data:(NSData *)data wasReadFromRegister:(NSInteger)regAddr
{
    // do nothing, meant to be overwritten
}

- (void)failedReadingFromRegister:(NSInteger)regAddr
{
    // do nothing, meant to be overwritten
}

- (void)failedWritingValue:(NSInteger)value toRegister:(NSInteger)regAddr
{
    // do nothing, meant to be overwritten
}

@end
