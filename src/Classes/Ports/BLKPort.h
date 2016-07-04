//
//  BLKPort.h
//  BLEKit
//
//  Created by Igor Sales on 2014-10-03.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <BLEKit/BLKCharacteristicListener.h>

extern NSString* const kBLKPortTypeUnknown;

extern NSString* const kBLKPortViewControllerClassName;
extern NSString* const kBLKPortWidgetName;
extern NSString* const kBLKPortType;

@interface BLKPort : NSObject <BLKCharacteristicListener>

+ (void)registerPortDescriptorAtPath:(NSString*)path;
+ (NSArray*)controlPortTypes;
+ (Class)viewControllerClassForPortType:(NSString*)type;
+ (void)enumeratePortTypesForViewControllerClass:(Class)klass
                                       withBlock:(void(^)(NSString* portType, NSString* identifier, NSInteger subindex, NSDictionary* options))block;

@property (nonatomic, readonly, weak)   BLKService*     service;
@property (nonatomic, weak, readonly)   CBPeripheral*     peripheral;
@property (nonatomic, strong, readonly) CBCharacteristic* characteristic;
@property (nonatomic, readonly)         NSArray*          characteristics;
@property (nonatomic, readonly)         BOOL              operationInProgress;

@property (nonatomic, strong)           NSError*          lastError;
@property (nonatomic, strong)           NSData*           lastReadData;

@property (nonatomic, copy)             void(^nextCompletionBlock)();
@property (nonatomic, copy)             void(^nextFailureBlock)();

- (id)initWithPeripheral:(CBPeripheral*)peripheral andCharacteristic:(CBCharacteristic*)characteristic;
- (id)initWithPeripheral:(CBPeripheral*)peripheral andCharacteristics:(NSArray*)characteristics;

// operations
- (void)invalidateWatchdogTimer;
- (void)startWatchdogTimer;

@end
