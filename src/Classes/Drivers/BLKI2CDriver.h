//
//  BLKI2CDriver.h
//  BLEKit
//
//  Created by Igor Sales on 2014-11-01.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKDriver.h"

@class BLKI2CControlPort;

@interface BLKI2CDriver : BLKDriver

@property (nonatomic, readonly) BLKI2CControlPort* I2CPort;
@property (nonatomic, assign)   NSInteger            slaveAddress;

// operations
- (void)readModifyWriteValue:(NSInteger)value register:(NSInteger)regAddr mask:(NSInteger)mask;
- (void)writeValue:(NSInteger)value register:(NSInteger)regAddr;
- (void)readValueFromRegister:(NSInteger)regAddr;
- (void)readBytes:(NSInteger)length startingAtRegister:(NSInteger)regAddr;

// overrides
- (void)value:(NSInteger)value wasReadFromRegister:(NSInteger)regAddr;
- (void)data:(NSData*)data wasReadFromRegister:(NSInteger)regAddr;
- (void)value:(NSInteger)value wasWrittenToRegister:(NSInteger)regAddr;
- (void)failedReadingFromRegister:(NSInteger)regAddr;
- (void)failedWritingValue:(NSInteger)value toRegister:(NSInteger)regAddr;

@end
