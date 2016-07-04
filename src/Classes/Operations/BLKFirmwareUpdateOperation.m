//
//  BLKFirmwareUpdateOperation.m
//  BLEKit
//
//  Created by Igor Sales on 2014-09-14.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKFirmwareUpdateOperation.h"
#import "BLKDeviceInfoService.h"
#import "BLKLog.h"
#import "BLKOTAUpdatePort.h"
#import "BLKManager.h"

NSString* const kBLKErrorDomain    = @"BLKErrorDomain";

#define ERR(STR) \
    [NSError errorWithDomain:kBLKErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:(STR)}]

@interface BLKFirmwareUpdateOperation() <CBPeripheralDelegate, NSURLConnectionDataDelegate, BLKDeviceConnection>

@property (nonatomic, strong) NSData* firmware;

@property (nonatomic, strong) BLKOTAUpdatePort* port;
@property (nonatomic, assign) NSUInteger     uploadPointer;
@property (nonatomic, assign) NSUInteger     chunkSize;
@property (nonatomic, assign) NSUInteger     uploadLength;

@property (nonatomic, assign) double         downloadPercent;
@property (nonatomic, assign) double         preparationPercent;
@property (nonatomic, assign) double         eraseFlashPercent;
@property (nonatomic, assign) double         uploadFlashPercent;

@property (nonatomic, assign) double         downloaded;
@property (nonatomic, assign) double         prepared;
@property (nonatomic, assign) double         erased;
@property (nonatomic, assign) double         uploaded;

@property (nonatomic, assign) NSInteger      expectedBytes;
@property (nonatomic, strong) NSMutableData* firmwareData;
@property (nonatomic, strong) NSURL*         firmwareURL;

@property (nonatomic, assign) BLKFirmwareUpdateOperationState state;
@property (nonatomic, assign) BOOL           isStopped;
@property (nonatomic, assign) double         progress;
@property (nonatomic, assign) NSInteger      retryCount;
@property (nonatomic, strong) NSData*        uploadedPacket;

@end

@implementation BLKFirmwareUpdateOperation

#pragma mark - Setup/teardown

- (id)initWithOTAUpdatePort:(BLKOTAUpdatePort *)port
{
    if ((self = [super init])) {
        self.port = port;
        self.downloadPercent    = 0;
        self.preparationPercent = 1;
        self.eraseFlashPercent  = 9;
        self.uploadFlashPercent = 90;
    }

    return self;
}

#pragma mark - Operations

- (void)setFirmwareFromURL:(NSURL*)firmwareURL
{
    self.downloadPercent    = 5;
    self.uploadFlashPercent = 85;
    
    self.firmwareURL = firmwareURL;
}

- (void)setFirmwareFromFile:(NSString*)fwPath
{
    [self setFirmwareFromData:[NSData dataWithContentsOfFile:fwPath]];
}

- (void)setFirmwareFromData:(NSData*)firmware
{
    self.firmware = firmware;
}

- (void)start
{
    self.isStopped = NO;
    if (self.firmwareURL && self.firmware.length < 1) {
        NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:self.firmwareURL];
        [req setHTTPMethod:@"HEAD"];

        [self switchToState:BLKFirmwareUpdateOperationStateDownloading];
        [NSURLConnection sendAsynchronousRequest:req
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if (error) {
                                       [self failWithError:error];
                                       return;
                                   }
                                   if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                       NSHTTPURLResponse* httpResp = (NSHTTPURLResponse*)response;
                                       if (httpResp.statusCode == 200) {
                                           if (self.expectedBytes > 0) {
                                               self.expectedBytes = (NSInteger)httpResp.expectedContentLength;
                                           }
                                           
                                           [req setHTTPMethod:@"GET"];
                                           if (![NSURLConnection connectionWithRequest:req delegate:self]) {
                                               [self failWithError:ERR(@"Cannot download firmware")];
                                           }
                                       } else {
                                           [self failWithError:ERR(@"Cannot get firmware details")];
                                       }
                                   }
                               }];
    } else if (self.firmware.length < 1) {
        [self failWithError:ERR(@"Invalid firmware.")];
    } else if (!self.port) {
        [self failWithError:ERR(@"OTA Port unavailable")];
    } else if (!self.deviceManager) {
        [self failWithError:ERR(@"No device manager given")];
    } else {
        [self.deviceManager attach:self toDevice:self.port.service.device];
    }
}

- (void)stop
{
    self.isStopped = YES;
    [self.deviceManager detach:self fromDevice:self.port.service.device];
}

#pragma mark - Private

- (void)failWithError:(NSError*)error
{
    [self stop];
    
    if ([self.delegate respondsToSelector:@selector(firmwareUpdateOperation:finishedWithError:)]) {
        [self.delegate firmwareUpdateOperation:self
                             finishedWithError:error];
    }
    
    self.state = BLKFirmwareUpdateOperationStateError;
}

- (void)updateProgress
{
    self.progress = (self.downloaded * self.downloadPercent +
                     self.prepared * self.preparationPercent +
                     self.erased * self.eraseFlashPercent +
                     self.uploaded * self.uploadFlashPercent) * 0.01;
    
    if ([self.delegate respondsToSelector:@selector(firmwareUpdateOperation:progressedTo:)]) {
        [self.delegate firmwareUpdateOperation:self progressedTo:self.progress];
    }
}

- (void)switchToState:(BLKFirmwareUpdateOperationState)state
{
    if (self.state != state) {
        if ([self.delegate respondsToSelector:@selector(firmwareUpdateOperationWillChangeState:)]) {
            [self.delegate firmwareUpdateOperationWillChangeState:self];
        }
        
        self.state = state;
        
        if ([self.delegate respondsToSelector:@selector(firmwareUpdateOperationDidChangeState:)]) {
            [self.delegate firmwareUpdateOperationDidChangeState:self];
        }
    }
}

#pragma mark - OTA Update Process

#define GUARD do { if(self.isStopped) return; } while(0)

- (void)enablePowerToExternalFlash
{
    GUARD;

    [self switchToState:BLKFirmwareUpdateOperationStatePreparing];
    [self.port writeControlCommand:OTA_FLASH_CMD_EN_POWER_TO_EXTERNAL_FLASH
                        completion:^{
                            [self eraseFlash];
                        } failure:^{
                            [self failWithError:ERR(@"Error enabling power to flash")];
                        }];
}

- (void)eraseFlash
{
    GUARD;

    [self switchToState:BLKFirmwareUpdateOperationStateErasing];
    [self.port writeControlCommand:OTA_FLASH_CMD_ERASE_FLASH
                        completion:^{
                            self.prepared = 1.0;
                            [self updateProgress];
                            [self pollDeviceForFlashEraseFinish];
                        } failure:^{
                            [self failWithError:ERR(@"Error erasing flash")];
                        }];
}

- (void)pollDeviceForFlashEraseFinish
{
    GUARD;

    [self.port readControlStatusWithCompletion:^(NSInteger status) {
        [self polledDeviceReturnedFlashEraseValue:status];
    } failure:^{
        [self failWithError:ERR(@"Error while waiting for flash to erase")];
    }];
}

- (void)polledDeviceReturnedFlashEraseValue:(NSInteger)status
{
    if (status == 0) {
        [self startFlashUploading];
    } else {
        self.erased = (double)status / 64.0;
        [self updateProgress];
        [self eraseFlash];
    }
}

- (void)startFlashUploading
{
    GUARD;

    [self switchToState:BLKFirmwareUpdateOperationStateUploading];
    [self.port writeControlCommand:OTA_FLASH_CMD_START_FLASH_UPLOADING
                        completion:^{
                            self.retryCount = 0;
                            [self upload];
                        } failure:^{
                            [self failWithError:ERR(@"Error starting to upload to flash")];
                        }];

    self.uploadPointer = 0;
    self.chunkSize     = 0;
}

- (void)upload
{
    GUARD;

    NSUInteger len = 20;
    if (self.chunkSize >= 240) {
        len = 256 - self.chunkSize;
    }
    
    if (self.uploadPointer + len >= self.firmware.length) {
        len = self.firmware.length - self.uploadPointer;
    }
    
    self.uploadLength = len;

    self.uploadedPacket = [self.firmware subdataWithRange:NSMakeRange(self.uploadPointer, self.uploadLength)];
    [self uploadDataPacket:self.uploadedPacket];
 }

- (void)uploadDataPacket:(NSData*)data
{
    GUARD;

    [self.port writeData:data];

    // Since this is a write with no response, we just push and wait a bit
    [self performSelector:@selector(readToVerify) withObject:nil afterDelay:0.006];
}

- (void)readToVerify
{
    GUARD;

    [self.port readDataWithCompletion:^(NSData *packet) {
        if ([self.uploadedPacket isEqualToData:packet]) {
            [self uploadSuccessful];
        } else {
            self.retryCount = self.retryCount + 1;
            if (self.retryCount == 3) {
                [self failWithError:ERR(@"Upload did not verify too many times")];
            } else {
                BLK_LOG(@"Retrying upload at 0x%x after %d incorrect upload attempts", (int)self.uploadPointer, (int)self.retryCount);
                [self rewindToLastUploadPointer];
            }
        }
    } failure:^{
        self.retryCount = self.retryCount + 1;
        if (self.retryCount == 3) {
            [self failWithError:ERR(@"Upload verify failed")];
        } else {
            [self readToVerify];
        }
    }];
}

- (void)rewindToLastUploadPointer
{
    GUARD;
    
    [self.port writeControlCommand:OTA_FLASH_CMD_REWIND_TO_LAST_DFU_POINTER
                        completion:^{
                            [self upload];
                        } failure:^{
                            [self failWithError:ERR(@"Error rewinding to re-upload packet")];
                        }];
}

- (void)uploadSuccessful
{
    GUARD;

    self.uploadPointer += self.uploadLength;
    self.chunkSize     += self.uploadLength;
    
    if (self.chunkSize >= 256) {
        self.chunkSize = 0;
    }
    
    self.uploadLength = 0;
    
    self.uploaded = self.uploadPointer / (double)self.firmware.length;
    [self updateProgress];

    if (self.uploadPointer >= self.firmware.length) {
        [self performSelector:@selector(flashImageBySettingDeviceInDeviceFirmwareUpdateMode) withObject:nil afterDelay:0.05];
    } else {
        self.retryCount = 0;
        [self performSelector:@selector(upload) withObject:nil afterDelay:0];
    }
}

- (void)flashImageBySettingDeviceInDeviceFirmwareUpdateMode
{
    GUARD;

    [self switchToState:BLKFirmwareUpdateOperationStateRestarting];
    [self.port writeControlCommand:OTA_FLASH_CMD_FLASH_IMAGE_AND_REBOOT
                        completion:^{
                            [self uploadFinishedSuccesfully];
                        } failure:^{
                            [self failWithError:ERR(@"Error setting device into DFU mode")];
                        }];
}

- (void)uploadFinishedSuccesfully
{
    GUARD;

    [self switchToState:BLKFirmwareUpdateOperationStateDone];
    self.isStopped = YES;
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    GUARD;

    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;

        if (httpResponse.statusCode == 200) {
            if (httpResponse.expectedContentLength > 0) {
                self.expectedBytes = (NSInteger)response.expectedContentLength;
                self.firmwareData  = [NSMutableData dataWithCapacity:self.expectedBytes];
            } else {
                self.firmwareData = [NSMutableData data];
            }
        } else {
            [self failWithError:ERR(@"Invalid response from firmware server")];
            return;
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.firmwareData appendData:data];
    
    if (self.expectedBytes > 0) {
        self.downloaded = (double)self.firmwareData.length / (double)self.expectedBytes;
        [self updateProgress];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.downloaded = 1.0;
    [self updateProgress];
    
    [self setFirmwareFromData:self.firmwareData];
    self.firmwareData = nil;
 
    GUARD;

    [self start];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManager:(CBCentralManager*)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (!self.isStopped) { // i.e. is running
        [self failWithError:error];
    }
}

#pragma mark - BLKDeviceConnection

- (void)device:(BLKDevice *)device connectionFailedWithError:(NSError *)error
{
    [self failWithError:ERR(@"Failed to connect to device")];
}

- (void)deviceAlreadyConnected:(BLKDevice *)device
{
    [self enablePowerToExternalFlash];
}

- (void)deviceDidConnect:(BLKDevice *)device
{
    // Give it a couple seconds to refresh the characteristics
    // TODO: Ideally this would not happen, so the manager should handle only giving us a connection notice
    // when ports are fully operational
    [self performSelector:@selector(enablePowerToExternalFlash) withObject:nil afterDelay:2.0];
}

- (void)deviceDidDisconnect:(BLKDevice *)device
{
    if (!self.isStopped) {
        // Timeout will catch this one, hopefully
        [self failWithError:ERR(@"Device disconnected")];
    }
}

@end
