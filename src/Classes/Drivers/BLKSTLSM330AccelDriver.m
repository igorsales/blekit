//
//  BLKSTLSM330AccelDriver.m
//  BLEKit
//
//  Created by Igor Sales on 2014-11-13.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKSTLSM330AccelDriver.h"

typedef enum {
    BLKSTLSM330_CTRL_REG_5_A = 0x20,
    
    BLKSTLSM330_OUT_X_L_A    = 0x28,
    BLKSTLSM330_OUT_X_H_A    = 0x29,
    BLKSTLSM330_OUT_Y_L_A    = 0x2A,
    BLKSTLSM330_OUT_Y_H_A    = 0x2B,
    BLKSTLSM330_OUT_Z_L_A    = 0x2C,
    BLKSTLSM330_OUT_Z_H_A    = 0x2D,
} BLKSTLSM330Registers;


@implementation BLKSTLSM330AccelDriver

#pragma mark - Operations

- (void)setOperatingMode:(BLKSTLSM330AccelDriverOperatingMode)mode
{
    [self readModifyWriteValue:mode << 4
                      register:BLKSTLSM330_CTRL_REG_5_A
                          mask:BLKSTLSM330AccelDriverOperatingModeMask << 4];
}

- (void)readAxisData
{
    [self readBytes:6 startingAtRegister:BLKSTLSM330_OUT_X_L_A];
}

#pragma mark - Overrides

- (void)data:(NSData *)data wasReadFromRegister:(NSInteger)regAddr
{
    if (self.delegate && data.length == 6 && regAddr == BLKSTLSM330_OUT_X_L_A) {
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

@end
