//
//  BLKDevice.h
//  BLEKit
//
//  Created by Igor Sales on 2014-09-26.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


typedef enum {
    BLKDeviceStateDisconnected,
    BLKDeviceStateUnavailable,
    BLKDeviceStateConnecting,
    BLKDeviceStateConnected,
    BLKDeviceStateUpdatingFirmware,
} BLKDeviceState;

#define BLKSignalStrengthUnknown (NSIntegerMax)

@class BLKConfiguration;

@interface BLKDevice : NSObject

@property (nonatomic, readonly) NSString*        peripheralId;
@property (nonatomic, readonly) NSUUID*          peripheralIdentifier;
@property (nonatomic, readonly) CBPeripheral*    peripheral;

@property (nonatomic, readonly) NSInteger        signalStrength;
@property (nonatomic, readonly) BLKDeviceState state;

@property (nonatomic, strong)   BLKConfiguration* configuration;

- (id)portOfType:(NSString*)type atIndex:(NSInteger)index subIndex:(NSInteger)subIndex withOptions:(NSDictionary*)options;

@end
