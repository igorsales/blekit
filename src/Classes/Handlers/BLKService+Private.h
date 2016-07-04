//
//  BLKService+Private.h
//  BLEKit
//
//  Created by Igor Sales on 2014-10-10.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKService.h"

@class BLKDevice;

@interface BLKService()

@property (nonatomic, weak)   BLKDevice* device;
@property (nonatomic, assign) BOOL isServiceUsable;

- (NSString*)serviceKeyForDevice:(BLKDevice*)device;

- (void)device:(BLKDevice*)device didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic;

- (void)device:(BLKDevice*)device didUpdateValueForCharacteristic:(CBCharacteristic*)characteristic;
- (void)device:(BLKDevice*)device didFailToUpdateValueForCharacteristic:(CBCharacteristic*)characteristic withError:(NSError*)error;

- (void)device:(BLKDevice*)device didWriteValueForCharacteristic:(CBCharacteristic*)characteristic;
- (void)device:(BLKDevice*)device didFailToWriteValueForCharacteristic:(CBCharacteristic*)characteristic withError:(NSError*)error;

@end