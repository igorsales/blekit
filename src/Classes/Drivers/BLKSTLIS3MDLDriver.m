//
//  BLKSTLIS3MDLDriver.m
//  BLEKit
//
//  Created by Igor Sales on 2014-11-01.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKSTLIS3MDLDriver.h"

typedef enum {
    BLKSTLIS3MDL_CTRL_REG_1 = 0x20,
    BLKSTLIS3MDL_CTRL_REG_2 = 0x21,
    BLKSTLIS3MDL_CTRL_REG_3 = 0x22,
    BLKSTLIS3MDL_CTRL_REG_4 = 0x23,
    BLKSTLIS3MDL_CTRL_REG_5 = 0x24,
    
    BLKSTLIS3MDL_OUT_X_L    = 0x28,
    BLKSTLIS3MDL_OUT_X_H    = 0x29,
    BLKSTLIS3MDL_OUT_Y_L    = 0x2A,
    BLKSTLIS3MDL_OUT_Y_H    = 0x2B,
    BLKSTLIS3MDL_OUT_Z_L    = 0x2C,
    BLKSTLIS3MDL_OUT_Z_H    = 0x2D,
} BLKSTLIS3MDLRegisters;

@implementation BLKSTLIS3MDLDriver

#pragma mark - Operations

- (void)setOperatingMode:(BLKSTLIS3MDLDriverOperatingMode)mode
{
    [self readModifyWriteValue:mode
                      register:BLKSTLIS3MDL_CTRL_REG_3
                          mask:BLKSTLIS3MDLDriverOperatingModeMask];
}

- (void)setDataRate:(BLKSTLIS3MDLDriverOutputDataRate)rate
{
    [self readModifyWriteValue:rate << 2
                      register:BLKSTLIS3MDL_CTRL_REG_1
                          mask:BLKSTLIS3MDLDriverOutputDataRateMask << 2];
}

- (void)setBlockDataUpdate:(BOOL)on
{
    [self writeValue:on ? 0x40 : 0x00 register:BLKSTLIS3MDL_CTRL_REG_5];
}

- (void)readAxisData
{
    [self readBytes:6 startingAtRegister:BLKSTLIS3MDL_OUT_X_L];
}

- (void)setXAndYAxisPowerOperatingMode:(BLKSTLIS3MDLDriverPowerOperatingMode)mode
{
    [self readModifyWriteValue:mode << 5 register:BLKSTLIS3MDL_CTRL_REG_1 mask:BLKSTLIS3MDLDriverPowerOperatingModeMask << 5];
}

- (void)setZAxisPowerOperatingMode:(BLKSTLIS3MDLDriverPowerOperatingMode)mode
{
    [self readModifyWriteValue:mode << 2 register:BLKSTLIS3MDL_CTRL_REG_4 mask:BLKSTLIS3MDLDriverPowerOperatingModeMask << 2];
}

#pragma mark - Overrides

- (void)data:(NSData *)data wasReadFromRegister:(NSInteger)regAddr
{
    if (self.delegate && data.length == 6 && regAddr == BLKSTLIS3MDL_OUT_X_L) {
        int16_t* channels = (int16_t*)[data bytes];
        [self.delegate driver:self axisDataX:channels[0] Y:channels[1] Z:channels[2]];
    }
}

- (void)failedReadingFromRegister:(NSInteger)regAddr
{
    [self.delegate driverReadFailed:self];
}

- (void)failedWritingValue:(NSInteger)value toRegister:(NSInteger)regAddr
{
    [self.delegate driverWriteFailed:self];
}

- (void)value:(NSInteger)value wasWrittenToRegister:(NSInteger)regAddr
{
    if (regAddr == BLKSTLIS3MDL_CTRL_REG_5) {
        [self.delegate driverFinishedSelectorSuccessfully:@selector(setBlockDataUpdate:)];
    }
}

@end
