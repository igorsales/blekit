//
//  BLKCharacteristicListener.h
//  BLEKit
//
//  Created by Igor Sales on 2014-11-30.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//


@class BLKService;

@protocol BLKCharacteristicListener <NSObject>

@optional
- (void)service:(BLKService*)service didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic;

- (void)service:(BLKService*)service didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic;
- (void)service:(BLKService*)service didFailToUpdateValueForCharacteristic:(CBCharacteristic *)characteristic withError:(NSError*)error;

- (void)service:(BLKService*)service didWriteValueForCharacteristic:(CBCharacteristic *)characteristic;
- (void)service:(BLKService*)service didFailToWriteValueForCharacteristic:(CBCharacteristic *)characteristic withError:(NSError*)error;

@end
