//
//  BLKADCPort.h
//  BLEKit
//
//  Created by Igor Sales on 2015-06-10.
//  Copyright (c) 2015 IgorSales.ca. All rights reserved.
//

#import <BLEKit/BLKPort.h>

extern NSString* const kBLKPortTypeADCs;

#define kBLKMaxNumberOfADCsPerCharacteristic (10)

@interface BLKADCPort : BLKPort

@property (nonatomic, assign) NSInteger numberOfPins;
@property (nonatomic, readonly) NSInteger status;

- (void)read;
- (SInt16)readingForPin:(NSInteger)pin;

@end
