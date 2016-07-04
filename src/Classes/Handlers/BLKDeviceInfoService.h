//
//  RTRLDeviceInfoService.h
//  BLEKit
//
//  Created by Igor Sales on 2014-09-23.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKService.h"
#import "BLKDevice.h"

@class BLKDevice;

@interface BLKDeviceInfoService : BLKService

@property (nonatomic, readonly) NSString* manufacturer;
@property (nonatomic, readonly) NSString* modelNumber;
@property (nonatomic, readonly) NSString* firmwareRevision;
@property (nonatomic, readonly) NSString* hardwareRevision;
@property (nonatomic, readonly) NSString* firmwareID;
@property (nonatomic, readonly) NSString* hardwareID;

@end


@interface BLKDevice(InfoService)

@property (nonatomic, readonly) BLKDeviceInfoService* info;

@end
