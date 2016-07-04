//
//  BLKPortsService.h
//  BLEKit
//
//  Created by Igor Sales on 2014-10-03.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <BLEKit/BLKService.h>

typedef struct {
    unsigned numberOfPWMChannels: 5;
    unsigned I2CPortAvailable: 1;
    unsigned numberOfGPInputs: 6;
    unsigned numberOfGPOutputs: 6;
    unsigned numberOfADCs: 6;
    unsigned reserved:8;
} BLKPortsAndCapabilities;


@interface BLKPortsService : BLKService

@property (nonatomic, readonly) CBCharacteristic* portsAndCapabilitiesCharacteristic;
@property (nonatomic, readonly) CBCharacteristic* PWMChannelsWidth1Thru10Characteristic;
@property (nonatomic, readonly) CBCharacteristic* PWMDefaultChannelsWidth1Thru10Characteristic;
@property (nonatomic, readonly) CBCharacteristic* I2CControlCharacteristic;
@property (nonatomic, readonly) CBCharacteristic* GeneralPurposeInputsCharacteristic;
@property (nonatomic, readonly) CBCharacteristic* GeneralPurposeOutputsCharacteristic;
@property (nonatomic, readonly) CBCharacteristic* AnalogToDigitalConvertersCharacteristic;

@property (nonatomic, readonly) BLKPortsAndCapabilities portsAndCapabilities;

- (CBCharacteristic*)characteristicForPWMChannelsAtIndex:(NSInteger)index defaultWidths:(BOOL)isDefaultWidths;

@end
