//
//  BLKFirmwareUpdateOperation.h
//  BLEKit
//
//  Created by Igor Sales on 2014-09-14.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLKOperation.h"

typedef enum {
    BLKFirmwareUpdateOperationStateIdle,
    BLKFirmwareUpdateOperationStateDownloading,
    BLKFirmwareUpdateOperationStatePreparing,
    BLKFirmwareUpdateOperationStateErasing,
    BLKFirmwareUpdateOperationStateUploading,
    BLKFirmwareUpdateOperationStateRestarting,
    BLKFirmwareUpdateOperationStateDone,
    BLKFirmwareUpdateOperationStateError,
} BLKFirmwareUpdateOperationState;

@class BLKFirmwareUpdateOperation;
@class BLKOTAUpdatePort;

@protocol BLKFirmwareUpdateOperationDelegate <NSObject>

@optional
- (void)firmwareUpdateOperationWillChangeState:(BLKFirmwareUpdateOperation*)action;
- (void)firmwareUpdateOperationDidChangeState:(BLKFirmwareUpdateOperation*)action;
- (void)firmwareUpdateOperation:(BLKFirmwareUpdateOperation*)action progressedTo:(double)progress;
- (void)firmwareUpdateOperation:(BLKFirmwareUpdateOperation*)action finishedWithError:(NSError*)error;

@end

@interface BLKFirmwareUpdateOperation : BLKOperation

@property (nonatomic, readonly) BLKOTAUpdatePort* port;
@property (nonatomic, weak)     id<BLKFirmwareUpdateOperationDelegate> delegate;
@property (nonatomic, readonly) BLKFirmwareUpdateOperationState state;
@property (nonatomic, readonly) double progress;
@property (nonatomic, readonly) NSError* lastError;

- (id)initWithOTAUpdatePort:(BLKOTAUpdatePort*)port;

- (void)setFirmwareFromURL:(NSURL*)URL;
- (void)setFirmwareFromFile:(NSString*)fwPath;
- (void)setFirmwareFromData:(NSData*)firmware;

@end
