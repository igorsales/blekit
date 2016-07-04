//
//  BLKOTAUpdateService.h
//  BLEKit
//
//  Created by Igor Sales on 2014-09-24.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKService.h"

@interface BLKOTAUpdateService : BLKService

@property (nonatomic, readonly) CBCharacteristic* OTAControlCharacteristic;
@property (nonatomic, readonly) CBCharacteristic* OTADataCharacteristic;

@end
