//
//  BLKOTAUpdatePort.h
//  BLEKit
//
//  Created by Igor Sales on 2014-10-15.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <BLEKit/BLKPort.h>

extern NSString* const kBLKPortTypeOTAUpdate;

typedef enum
{
    OTA_FLASH_CMD_EN_POWER_TO_EXTERNAL_FLASH = 0x04,
    OTA_FLASH_CMD_ERASE_FLASH                = 0x00,
    OTA_FLASH_CMD_START_FLASH_UPLOADING      = 0x02,
    OTA_FLASH_CMD_FLASH_IMAGE_AND_REBOOT     = 0x03,
    OTA_FLASH_CMD_REWIND_TO_LAST_DFU_POINTER = 0x05,
} OTA_FLASH_CMD;


@interface BLKOTAUpdatePort : BLKPort

- (void)writeData:(NSData*)data;
- (void)readDataWithCompletion:(void(^)(NSData* data))completionBlock
                       failure:(void(^)(void))failureBlock;

- (void)writeControlCommand:(OTA_FLASH_CMD)command
                 completion:(void(^)(void))completionBlock
                    failure:(void(^)(void))failureBlock;

- (void)readControlStatusWithCompletion:(void(^)(NSInteger status))completionBlock
                                failure:(void(^)(void))failureBlock;

@end
