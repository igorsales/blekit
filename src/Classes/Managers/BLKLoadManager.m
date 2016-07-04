//
//  BLKLoadManager.m
//  BLEKit
//
//  Created by Igor Sales on 2014-09-19.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKLoadManager.h"
#import "BLKLoad.h"
#import "BLKLog.h"
#import "BLKDevice.h"
#import "BLKDeviceInfoService.h"

static NSString* const kBLKLoadManagerStarterLoadName = @"BLEKit-starter";

@interface BLKLoadManager()

@property (nonatomic, strong) NSArray* loads;
@property (nonatomic, strong) NSURLRequest* refreshRequest;

@property (nonatomic, readonly) NSURL* loadsCacheURL;

@end

static BLKLoadManager* sLoadsManager = nil;

@implementation BLKLoadManager

@synthesize loadsCacheURL = _loadsCacheURL;

#pragma mark - Setup/teardown

+ (id)alloc
{
    if (sLoadsManager) {
        return sLoadsManager;
    }
    
    return [super alloc];
}

- (id)init
{
    if (self == sLoadsManager) {
        return sLoadsManager;
    }

    if ((self = [super init])) {
        sLoadsManager = self;
        [self deserialize];
        [self refresh];
    }

    return self;
}

#pragma mark - Private

- (NSURL*)loadsCacheURL
{
    if (!_loadsCacheURL) {
        NSError* error = nil;
        NSURL* URL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory
                                                            inDomain:NSUserDomainMask
                                                   appropriateForURL:nil
                                                              create:YES
                                                               error:&error];
        if (error) {
            BLK_LOG(@"Error creating cached loads file: %@", error);
        } else {
            URL = [URL URLByAppendingPathComponent:@"firmwareLoads.json"];
        }
        
        _loadsCacheURL = URL;
    }

    return _loadsCacheURL;
}

- (void)deserialize
{
    id data = [NSKeyedUnarchiver unarchiveObjectWithFile:self.loadsCacheURL.path];
    
    if (!data || ![data isKindOfClass:[NSArray class]]) {
        BLK_LOG(@"Invalid data read from cache. Flushing");
    } else {
        self.loads = data;
    }
}

- (void)serialize
{
    if (![NSKeyedArchiver archiveRootObject:self.loads toFile:self.loadsCacheURL.path]) {
        BLK_LOG(@"Error serializing firmware loads");
    }
}

- (void)parseLoads:(NSArray*)loads
{
    NSMutableArray* parsedLoads = [NSMutableArray new];

    for (NSDictionary* d in loads) {
        if (![d isKindOfClass:[NSDictionary class]]) {
            BLK_LOG(@"Invalid load type: %@", d);
        }
        
        BLKLoad* load = [[BLKLoad alloc] initWithDictionary:d];
        [parsedLoads addObject:load];
    }

    self.loads = parsedLoads;
    [self.delegate loadManagerDidUpdateLoads:self];
    [self serialize];
}

#pragma mark - Operations

- (void)refresh
{
    if (self.refreshRequest) {
        BLK_LOG(@"Already refreshing");
        return;
    }

    self.refreshRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://api.ble-kit.org/loads"]];

    [self.delegate loadManagerDidStartRefresh:self];
    [NSURLConnection sendAsynchronousRequest:self.refreshRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse* response, NSData* data, NSError* error) {
                               if (error) {
                                   BLK_LOG(@"Refresh failed");
                               } else if (data.length == 0) {
                                   BLK_LOG(@"Empty response returned");
                               } else {
                                   NSArray* loads = [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:0
                                                                                      error:&error];
                                   if (loads == nil || error) {
                                       BLK_LOG(@"Invalid response from server");
                                   } else {
                                       [self parseLoads:loads];
                                   }
                               }
                               self.refreshRequest = nil;
                               [self.delegate loadManagerDidEndRefresh:self];
                           }];
}

- (void)enumerateLoadsForHardwareID:(NSString *)hardwareID andHardwareVersion:(NSString *)hardwareVersion usingBlock:(void (^)(BLKLoad *load, NSUInteger index, BOOL *stop))block
{
    [self.loads enumerateObjectsUsingBlock:^(BLKLoad* load, NSUInteger idx, BOOL *stop) {
        if ([load.hardwareID isEqualToString:hardwareID] &&
            [load.hardwareVersion isEqualToString:hardwareVersion]) {
            block(load, idx, stop);
        }
    }];
}

- (BOOL)hasNewerFirmwareRevisionForDevice:(BLKDevice*)device
{
    __block BOOL found = NO;
    [self enumerateLoadsForHardwareID:device.info.hardwareID
                   andHardwareVersion:device.info.hardwareRevision
                           usingBlock:^(BLKLoad *load, NSUInteger index, BOOL *stop) {
        if ([load.firmwareID isEqualToString:device.info.firmwareID] &&
            [load.firmwareVersion compare:device.info.firmwareRevision options:NSCaseInsensitiveSearch] == NSOrderedDescending) {
            *stop = YES;
            found = YES;
        }
    }];
    
    return found;
}

- (BOOL)hasStarterFirmwareRevisionForDevice:(BLKDevice*)device
{
    __block BOOL found = NO;
    [self enumerateLoadsForHardwareID:device.info.hardwareID
                   andHardwareVersion:device.info.hardwareRevision
                           usingBlock:^(BLKLoad *load, NSUInteger index, BOOL *stop) {
        if ([load.firmwareID isEqualToString:kBLKLoadManagerStarterLoadName]) {
            *stop = YES;
            found = YES;
        }
    }];
    
    return found;
}

- (BLKLoad*)starterLoadForDevice:(BLKDevice*)device
{
    NSArray* loads = [self.loads filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(BLKLoad* load, NSDictionary *bindings) {
        return ([load.hardwareID isEqualToString:device.info.hardwareID] &&
                [load.hardwareVersion isEqualToString:device.info.hardwareRevision] &&
                [load.firmwareID isEqualToString:kBLKLoadManagerStarterLoadName]);
    }]];

    loads = [loads sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"firmwareVersion" ascending:NO] ]]; // Descending to get newest first
    
    if (loads.count) {
        return loads[0];
    } else {
        return nil;
    }
}

- (NSArray*)newerFirmwareLoadsForDevice:(BLKDevice*)device
{
    NSArray* loads = [self.loads filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(BLKLoad* load, NSDictionary *bindings) {
        return ([load.hardwareID isEqualToString:device.info.hardwareID] &&
                [load.hardwareVersion isEqualToString:device.info.hardwareRevision] &&
                [load.firmwareID isEqualToString:device.info.firmwareID] &&
                [load.firmwareVersion compare:device.info.firmwareRevision options:NSCaseInsensitiveSearch] == NSOrderedDescending);
    }]];
    
    return [loads sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"firmwareVersion" ascending:NO] ]]; // Descending to get newest first
}

- (NSArray*)compatibleFirmwareLoadsForDevice:(BLKDevice*)device
{
    NSArray* loads = [self.loads filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(BLKLoad* load, NSDictionary *bindings) {
        return ([load.hardwareID isEqualToString:device.info.hardwareID] &&
                [load.hardwareVersion isEqualToString:device.info.hardwareRevision] &&
                ![load.firmwareID isEqualToString:device.info.firmwareID] &&
                ![load.firmwareID isEqualToString:kBLKLoadManagerStarterLoadName]);
    }]];

    return [loads sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"firmwareID" ascending:YES],
                                                 [NSSortDescriptor sortDescriptorWithKey:@"firmwareVersion" ascending:NO] ]]; // Descending to get newest first
}

- (NSArray*)olderFirmwareLoadsForDevice:(BLKDevice*)device
{
    NSArray* loads = [self.loads filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(BLKLoad* load, NSDictionary *bindings) {
        return ([load.hardwareID isEqualToString:device.info.hardwareID] &&
                [load.hardwareVersion isEqualToString:device.info.hardwareRevision] &&
                [load.firmwareID isEqualToString:device.info.firmwareID] &&
                [load.firmwareVersion compare:device.info.firmwareRevision options:NSCaseInsensitiveSearch] == NSOrderedAscending);
    }]];
    
    return [loads sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"firmwareVersion" ascending:NO] ]]; // Descending to get newest first
}


@end
