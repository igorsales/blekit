//
//  BLKGPIOPort.h
//  BLEKit
//
//  Created by Igor Sales on 2015-05-15.
//  Copyright (c) 2015 IgorSales.ca. All rights reserved.
//

#import "BLKPort.h"

extern NSString* kBLKPortTypeGPIO_Inputs;
extern NSString* kBLKPortTypeGPIO_Outputs;

@interface BLKGPIOPort : BLKPort

@property (nonatomic, assign)   NSInteger numberOfPins;
@property (nonatomic, readonly) BOOL      canRead;
@property (nonatomic, readonly) BOOL      canWrite;
@property (nonatomic, readonly) BOOL      canNotify;

@property (nonatomic, readonly) NSUInteger status;

- (void)read;
- (void)write:(NSUInteger)bits mask:(NSUInteger)mask commit:(BOOL)commit;
- (void)commit;

@end
