//
//  BLKLoadManager.h
//  BLEKit
//
//  Created by Igor Sales on 2014-09-19.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLKLoadManager;
@class BLKLoad;
@class BLKDevice;

@protocol BLKLoadManagerDelegate <NSObject>

- (void)loadManagerDidStartRefresh:(BLKLoadManager*)manager;
- (void)loadManagerDidEndRefresh:(BLKLoadManager*)manager;
- (void)loadManagerDidUpdateLoads:(BLKLoadManager*)manager;

@end

@interface BLKLoadManager : NSObject

@property (nonatomic, readonly) NSArray* loads;

@property (nonatomic, weak) IBOutlet id<BLKLoadManagerDelegate> delegate;

// operations
- (void)refresh;
- (void)enumerateLoadsForHardwareID:(NSString*)hardwareID andHardwareVersion:(NSString*)hardwareVersion usingBlock:(void(^)(BLKLoad* load, NSUInteger index, BOOL *stop))block;
- (BOOL)hasNewerFirmwareRevisionForDevice:(BLKDevice*)device;
- (BOOL)hasStarterFirmwareRevisionForDevice:(BLKDevice*)device;

- (BLKLoad*)starterLoadForDevice:(BLKDevice*)device;
- (NSArray*)newerFirmwareLoadsForDevice:(BLKDevice*)device;
- (NSArray*)compatibleFirmwareLoadsForDevice:(BLKDevice*)device;
- (NSArray*)olderFirmwareLoadsForDevice:(BLKDevice*)device;

@end
