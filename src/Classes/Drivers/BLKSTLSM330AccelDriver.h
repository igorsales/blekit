//
//  BLKSTLSM330AccelDriver.h
//  BLEKit
//
//  Created by Igor Sales on 2014-11-13.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <BLEKit/BLKI2CDriver.h>

typedef enum {
    BLKSTLSM330AccelDriverPowerDown,
    BLKSTLSM330AccelDriverOutputDataRate3_125Hz,
    BLKSTLSM330AccelDriverOutputDataRate6_25Hz,
    BLKSTLSM330AccelDriverOutputDataRate12_5Hz,
    BLKSTLSM330AccelDriverOutputDataRate25Hz,
    BLKSTLSM330AccelDriverOutputDataRate50Hz,
    BLKSTLSM330AccelDriverOutputDataRate100Hz,
    BLKSTLSM330AccelDriverOutputDataRate400Hz,
    BLKSTLSM330AccelDriverOutputDataRate800Hz,
    BLKSTLSM330AccelDriverOutputDataRate1600Hz,
    
    BLKSTLSM330AccelDriverOperatingModeMask = 0x0F
} BLKSTLSM330AccelDriverOperatingMode;

@class BLKSTLSM330AccelDriver;

@protocol BLKSTLSM330AccelDriverDelegate <NSObject>

- (void)driver:(BLKSTLSM330AccelDriver*)driver axisDataX:(int16_t)x Y:(int16_t)y Z:(int16_t)Z;
- (void)driverReadFailed:(BLKSTLSM330AccelDriver *)driver;
- (void)driverWriteFailed:(BLKSTLSM330AccelDriver *)driver;

@end

@interface BLKSTLSM330AccelDriver : BLKI2CDriver

@property (nonatomic, weak) id<BLKSTLSM330AccelDriverDelegate> delegate;

- (void)setOperatingMode:(BLKSTLSM330AccelDriverOperatingMode)mode;
- (void)readAxisData;

@end
