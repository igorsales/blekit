//
//  BLKPort+Private.h
//  BLEKit
//
//  Created by Igor Sales on 2014-12-04.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

@interface BLKPort() <BLKCharacteristicListener>

@property (nonatomic, weak)   CBPeripheral*     peripheral;
@property (nonatomic, strong) CBCharacteristic* characteristic;
@property (nonatomic, strong) CBUUID*           characteristicUUID;

@property (nonatomic, weak)   BLKService*     service;
@property (nonatomic, strong) NSArray*          characteristics;

@property (nonatomic, assign) NSTimeInterval    watchdogTimeout;

- (BOOL)parseCharacteristics:(NSArray*)characteristics;
- (BOOL)refreshCharacteristics:(NSArray*)characteristics;

- (void)watchdogTimerFired:(NSTimer*)timer;

@end