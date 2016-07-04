//
//  BLKI2CControlPort.h
//  BLEKit
//
//  Created by Igor Sales on 2014-10-03.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <BLEKit/BLKPort.h>

extern NSString* const kBLKPortTypeI2CControl;

@interface BLKI2CControlPort : BLKPort

@property (nonatomic, assign) BOOL useStopCondition;

- (void)readBytes:(NSInteger)length
 fromSlaveAddress:(NSInteger)slaveAddress
andRegisterAddress:(NSInteger)regAddress
       completion:(void(^)(NSData* data))completionBlock
          failure:(void(^)(void))failureBlock;

- (void)writeBytes:(NSData*)data
    toSlaveAddress:(NSInteger)slaveAddress
andRegisterAddress:(NSInteger)regAddress
        completion:(void(^)(NSInteger written))completionBlock
           failure:(void(^)(void))failureBlock;

@end
