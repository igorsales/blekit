//
//  BLKSTLIS3MDLDriver.h
//  BLEKit
//
//  Created by Igor Sales on 2014-11-01.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKI2CDriver.h"

typedef enum {
    BLKSTLIS3MDLDriverOutputDataRate0_625Hz,
    BLKSTLIS3MDLDriverOutputDataRate1_25Hz,
    BLKSTLIS3MDLDriverOutputDataRate2_5Hz,
    BLKSTLIS3MDLDriverOutputDataRate5Hz,
    BLKSTLIS3MDLDriverOutputDataRate10Hz,
    BLKSTLIS3MDLDriverOutputDataRate20Hz,
    BLKSTLIS3MDLDriverOutputDataRate40Hz,
    BLKSTLIS3MDLDriverOutputDataRate80Hz,
    
    BLKSTLIS3MDLDriverOutputDataRateMask = BLKSTLIS3MDLDriverOutputDataRate80Hz
} BLKSTLIS3MDLDriverOutputDataRate;

typedef enum {
    BLKSTLIS3MDLDriverOperatingModeContinuous,
    BLKSTLIS3MDLDriverOperatingModeSingleShot,
    BLKSTLIS3MDLDriverOperatingModePowerDown1,
    BLKSTLIS3MDLDriverOperatingModePowerDown2,

    BLKSTLIS3MDLDriverOperatingModeMask = 0x03
} BLKSTLIS3MDLDriverOperatingMode;

typedef enum {
    BLKSTLIS3MDLDriverLowPowerOperatingMode,
    BLKSTLIS3MDLDriverMediumPerformanceMode,
    BLKSTLIS3MDLDriverHighPerformanceMode,
    BLKSTLIS3MDLDriverUltraHighPerformanceMode,
    
    BLKSTLIS3MDLDriverPowerOperatingModeMask = 0x03
} BLKSTLIS3MDLDriverPowerOperatingMode;

@class BLKSTLIS3MDLDriver;

@protocol BLKSTLIS3MDLDriverDelegate <NSObject>

- (void)driver:(BLKSTLIS3MDLDriver*)driver axisDataX:(int16_t)x Y:(int16_t)y Z:(int16_t)Z;
- (void)driverReadFailed:(BLKSTLIS3MDLDriver *)driver;
- (void)driverWriteFailed:(BLKSTLIS3MDLDriver *)driver;
- (void)driverFinishedSelectorSuccessfully:(SEL)sel;

@end

@interface BLKSTLIS3MDLDriver : BLKI2CDriver

@property (nonatomic, weak) id<BLKSTLIS3MDLDriverDelegate> delegate;

// operations
- (void)setOperatingMode:(BLKSTLIS3MDLDriverOperatingMode)mode;
- (void)setDataRate:(BLKSTLIS3MDLDriverOutputDataRate)rate;
- (void)setBlockDataUpdate:(BOOL)on;
- (void)readAxisData;
- (void)setXAndYAxisPowerOperatingMode:(BLKSTLIS3MDLDriverPowerOperatingMode)mode;
- (void)setZAxisPowerOperatingMode:(BLKSTLIS3MDLDriverPowerOperatingMode)mode;

@end
