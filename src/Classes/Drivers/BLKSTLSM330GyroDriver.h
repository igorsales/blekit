//
//  BLKSTLSM330GyroDriver.h
//  BLEKit
//
//  Created by Igor Sales on 2014-11-13.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <BLEKit/BLKI2CDriver.h>

typedef enum {
    BLKSTLSM330GyroDriverPowerDown               = 0x00,
    BLKSTLSM330GyroDriverODR_95Hz_Cutoff_12_5Hz  = 0x01,
    BLKSTLSM330GyroDriverODR_95Hz_Cutoff_25Hz    = 0x03,
    BLKSTLSM330GyroDriverODR_95Hz_Cutoff_25Hz_2  = 0x05,
    BLKSTLSM330GyroDriverODR_95Hz_Cutoff_25Hz_3  = 0x07,

    BLKSTLSM330GyroDriverODR_190Hz_Cutoff_12_5Hz = 0x09,
    BLKSTLSM330GyroDriverODR_190Hz_Cutoff_25Hz   = 0x0b,
    BLKSTLSM330GyroDriverODR_190Hz_Cutoff_50Hz   = 0x0d,
    BLKSTLSM330GyroDriverODR_190Hz_Cutoff_70Hz   = 0x0f,

    BLKSTLSM330GyroDriverODR_380Hz_Cutoff_20Hz   = 0x11,
    BLKSTLSM330GyroDriverODR_380Hz_Cutoff_25Hz   = 0x13,
    BLKSTLSM330GyroDriverODR_380Hz_Cutoff_50Hz   = 0x15,
    BLKSTLSM330GyroDriverODR_380Hz_Cutoff_100Hz  = 0x17,

    BLKSTLSM330GyroDriverODR_760Hz_Cutoff_30Hz   = 0x19,
    BLKSTLSM330GyroDriverODR_760Hz_Cutoff_35Hz   = 0x1b,
    BLKSTLSM330GyroDriverODR_760Hz_Cutoff_50Hz   = 0x1d,
    BLKSTLSM330GyroDriverODR_760Hz_Cutoff_100Hz  = 0x1f,

    BLKSTLSM330GyroDriverOperatingModeMask  = 0x1F
} BLKSTLSM330GyroDriverOperatingMode;

@class BLKSTLSM330GyroDriver;

@protocol BLKSTLSM330GyroDriverDelegate <NSObject>

- (void)driver:(BLKSTLSM330GyroDriver*)driver axisDataX:(int16_t)x Y:(int16_t)y Z:(int16_t)Z;
- (void)driverReadFailed:(BLKSTLSM330GyroDriver *)driver;
- (void)driverWriteFailed:(BLKSTLSM330GyroDriver *)driver;

@end


@interface BLKSTLSM330GyroDriver : BLKI2CDriver

@property (nonatomic, weak) id<BLKSTLSM330GyroDriverDelegate> delegate;

- (void)setOperatingMode:(BLKSTLSM330GyroDriverOperatingMode)mode;
- (void)readAxisData;

@end
