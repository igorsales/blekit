//
//  BLKPortsService.m
//  BLEKit
//
//  Created by Igor Sales on 2014-10-03.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKPortsService.h"
#import "BLKService+Private.h"
#import "BLKPWMChannelsPort.h"
#import "BLKGPIOPort.h"
#import "BLKADCPort.h"
#import "BLKLog.h"
#import "BLKI2CControlPort.h"

@interface BLKPortsService()

@property (nonatomic, strong) CBUUID* portsAndCapabilitiesUUID;
@property (nonatomic, strong) CBUUID* PWMChannelsWidth1Thru10UUID;
@property (nonatomic, strong) CBUUID* PWMDefaultChannelsWidth1Thru10UUID;
@property (nonatomic, strong) CBUUID* I2CControlUUID;
@property (nonatomic, strong) CBUUID* GeneralPurposeInputsUUID;
@property (nonatomic, strong) CBUUID* GeneralPurposeOutputsUUID;
@property (nonatomic, strong) CBUUID* AnalogToDigitalConvertersUUID;

@property (nonatomic, strong) CBCharacteristic* portsAndCapabilitiesCharacteristic;
@property (nonatomic, strong) CBCharacteristic* PWMChannelsWidth1Thru10Characteristic;
@property (nonatomic, strong) CBCharacteristic* PWMDefaultChannelsWidth1Thru10Characteristic;
@property (nonatomic, strong) CBCharacteristic* I2CControlCharacteristic;
@property (nonatomic, strong) CBCharacteristic* GeneralPurposeInputsCharacteristic;
@property (nonatomic, strong) CBCharacteristic* GeneralPurposeOutputsCharacteristic;
@property (nonatomic, strong) CBCharacteristic* AnalogToDigitalConvertersCharacteristic;

@property (nonatomic, assign) BLKPortsAndCapabilities portsAndCapabilities;

@end

@implementation BLKPortsService

#pragma mark - Class operations

+ (BOOL)processPortsAndCapabilitiesData:(NSData*)data
          intoPortAndCapabilitiesStruct:(BLKPortsAndCapabilities*)portsAndCapabilities
{
    if (data.length != sizeof(BLKPortsAndCapabilities) || portsAndCapabilities == nil) {
        BLK_LOG(@"Invalid Ports and Capabilities value or agument: %@ %p", data, portsAndCapabilities);
        return NO;
    }
    
    [data getBytes:portsAndCapabilities length:sizeof(BLKPortsAndCapabilities)];
    
    return YES;
}

#pragma mark - Overrides

- (id)portOfType:(NSString*)type atIndex:(NSInteger)index subIndex:(NSInteger)subIndex withOptions:(NSDictionary*)options
{
    if ([type isEqualToString:kBLKPortTypePWMChannels]) {
        if (index < (self.portsAndCapabilities.numberOfPWMChannels + kBLKMaxNumberOfPWMChannelsPerCharacteristic - 1) / kBLKMaxNumberOfPWMChannelsPerCharacteristic) {
            
            BOOL defaults = [[options valueForKey:@"isDefaults"] boolValue];
            CBCharacteristic* characteristic = [self characteristicForPWMChannelsAtIndex:index defaultWidths:defaults];
            if (characteristic) {
                NSInteger numberOfChannels = (self.portsAndCapabilities.numberOfPWMChannels - index * kBLKMaxNumberOfPWMChannelsPerCharacteristic) % kBLKMaxNumberOfPWMChannelsPerCharacteristic;
                if (numberOfChannels > 0) {
                    BLKPWMChannelsPort* PWMChannel = [[BLKPWMChannelsPort alloc] initWithPeripheral:self.service.peripheral andCharacteristic:characteristic];
                    PWMChannel.numberOfChannels = numberOfChannels;
                    [self registerListener:PWMChannel forCharacteristicUUID:characteristic.UUID];
                    
                    return PWMChannel;
                }
            }
        }
    } else if ([type isEqualToString:kBLKPortTypeI2CControl]) {
        if (self.portsAndCapabilities.I2CPortAvailable) {
            if (self.I2CControlCharacteristic) {
                BLKI2CControlPort* I2CPort = [[BLKI2CControlPort alloc] initWithPeripheral:self.service.peripheral
                                                                             andCharacteristic:self.I2CControlCharacteristic];
                [self registerListener:I2CPort forCharacteristicUUID:self.I2CControlCharacteristic.UUID];
                return I2CPort;
            }
        }
    } else if ([type isEqualToString:kBLKPortTypeGPIO_Inputs]) {
        if (self.portsAndCapabilities.numberOfGPInputs) {
            if (self.GeneralPurposeInputsCharacteristic) {
                BLKGPIOPort* GPIOPort = [[BLKGPIOPort alloc] initWithPeripheral:self.service.peripheral
                                                                  andCharacteristic:self.GeneralPurposeInputsCharacteristic];
                GPIOPort.numberOfPins = self.portsAndCapabilities.numberOfGPInputs;

                [self registerListener:GPIOPort forCharacteristicUUID:self.GeneralPurposeInputsCharacteristic.UUID];
                return GPIOPort;
            }
        }
    } else if ([type isEqualToString:kBLKPortTypeGPIO_Outputs]) {
        if (self.portsAndCapabilities.numberOfGPOutputs) {
            if (self.GeneralPurposeOutputsCharacteristic) {
                BLKGPIOPort* GPIOPort = [[BLKGPIOPort alloc] initWithPeripheral:self.service.peripheral
                                                                  andCharacteristic:self.GeneralPurposeOutputsCharacteristic];
                GPIOPort.numberOfPins = self.portsAndCapabilities.numberOfGPOutputs;
                
                [self registerListener:GPIOPort forCharacteristicUUID:self.GeneralPurposeOutputsCharacteristic.UUID];
                return GPIOPort;
            }
        }
    } else if ([type isEqualToString:kBLKPortTypeADCs]) {
        if (self.portsAndCapabilities.numberOfADCs) {
            if (self.AnalogToDigitalConvertersCharacteristic) {
                BLKADCPort* ADCPort = [[BLKADCPort alloc] initWithPeripheral:self.service.peripheral
                                                               andCharacteristic:self.AnalogToDigitalConvertersCharacteristic];
                ADCPort.numberOfPins = self.portsAndCapabilities.numberOfADCs;
                
                [self registerListener:ADCPort forCharacteristicUUID:self.AnalogToDigitalConvertersCharacteristic.UUID];
                return ADCPort;
            }
        }
    }

    return nil;
}

#pragma mark - Operations

- (CBCharacteristic*)characteristicForPWMChannelsAtIndex:(NSInteger)index defaultWidths:(BOOL)isDefaultWidths
{
    NSString* attrName = [NSString stringWithFormat:@"PWM%@ChannelsWidth%dThru%dCharacteristic",
                          isDefaultWidths ? @"Default" : @"",
                          (int)index+1, (int)index+10];
    SEL selector = NSSelectorFromString(attrName);
    if ([self respondsToSelector:selector]) {
        //return [self performSelector:selector withObject:nil];
        IMP imp = [self methodForSelector:selector];
        id (*func)(id, SEL) = (void *)imp;
        return func(self, selector);
    } else {
        BLK_LOG(@"Invalid characteristic specified: %@", attrName);
    }
    
    return nil;
}

#pragma mark - CBPeripheralDelegate

- (BOOL)parseServiceCharacteristics:(CBService *)service
{
    BOOL r = [super parseServiceCharacteristics:service];

    if (r) {
        if (self.portsAndCapabilitiesCharacteristic) {
            // Read constants
            [service.peripheral readValueForCharacteristic:self.portsAndCapabilitiesCharacteristic];
        }
    }

    return r;
}

- (BOOL)shouldMakeServiceUsable
{
    return self.portsAndCapabilitiesCharacteristic != nil;
}

- (void)device:(BLKDevice *)device didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
{
    if (characteristic == self.portsAndCapabilitiesCharacteristic) {
        BLKPortsAndCapabilities portsAndCapabilities;
        if ([BLKPortsService processPortsAndCapabilitiesData:characteristic.value
                                 intoPortAndCapabilitiesStruct:&portsAndCapabilities]) {
            self.portsAndCapabilities = portsAndCapabilities;
        }
    }

    [super device:device didUpdateValueForCharacteristic:characteristic];
}

@end
