//
//  BLKOTAUpdateService.m
//  BLEKit
//
//  Created by Igor Sales on 2014-09-24.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKOTAUpdateService.h"
#import "BLKUUIDs.h"
#import "BLKOTAUpdatePort.h"

@interface BLKOTAUpdateService()

@property (nonatomic, strong) CBUUID*           OTAControlUUID;
@property (nonatomic, strong) CBUUID*           OTADataUUID;

@property (nonatomic, strong) CBCharacteristic* OTAControlCharacteristic;
@property (nonatomic, strong) CBCharacteristic* OTADataCharacteristic;

@end

@implementation BLKOTAUpdateService

- (BOOL)shouldMakeServiceUsable
{
    return (self.OTAControlCharacteristic && self.OTADataCharacteristic);
}

#pragma mark - Overrides

- (id)portOfType:(NSString*)type atIndex:(NSInteger)index subIndex:(NSInteger)subIndex withOptions:(NSDictionary *)options
{
    if ([type isEqualToString:kBLKPortTypeOTAUpdate]) {
        if (self.OTAControlCharacteristic && self.OTADataCharacteristic) {
            BLKOTAUpdatePort* port = [[BLKOTAUpdatePort alloc] initWithPeripheral:self.service.peripheral
                                                                   andCharacteristics:@[ self.OTAControlCharacteristic,
                                                                                         self.OTADataCharacteristic]];
            [self registerListener:port forCharacteristicUUID:self.OTAControlCharacteristic.UUID];
            [self registerListener:port forCharacteristicUUID:self.OTADataCharacteristic.UUID];
            return port;
        }
    }

    return nil;
}

@end
