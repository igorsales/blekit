//
//  BLKPort.m
//  BLEKit
//
//  Created by Igor Sales on 2014-10-03.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKPort.h"
#import "BLKPort+Private.h"
#import "NSArray+SelectCollect.h"

NSString* const kBLKPortTypeUnknown             = @"kBLKPortTypeUnknown";

NSString* const kBLKPortViewControllerClassName = @"kBLKPortViewControllerClassName";
NSString* const kBLKPortWidgetName              = @"kBLKPortWidgetName";
NSString* const kBLKPortType                    = @"kBLKPortType";
NSString* const kBLKPorts                       = @"kBLKPorts";
NSString* const kBLKPortIdentifier              = @"kBLKPortIdentifier";
NSString* const kBLKPortOptions                 = @"kBLKPortOptions";

NSString* const kBLKPortIdentifierDefault       = @"port";

@interface BLKPort()

@property (nonatomic, assign) BOOL     operationInProgress;
@property (nonatomic, weak)   NSTimer* watchdogTimer;

@end

static NSArray* sPortTypes = nil;
static NSMutableSet* sAdditionalPortDescriptorPaths = nil;

@implementation BLKPort

#pragma mark - Class accessors/operations

+ (void)registerPortDescriptorAtPath:(NSString *)path
{
    if (!sAdditionalPortDescriptorPaths) {
        sAdditionalPortDescriptorPaths = [NSMutableSet new];
    }
    
    [sAdditionalPortDescriptorPaths addObject:path];
    
    // reset service descriptors
    sPortTypes = nil;
}

+ (NSArray*)controlPortTypes
{
    if (!sPortTypes) {
        NSBundle* bundle = [NSBundle bundleForClass:self];
        NSString* path = [bundle pathForResource:@"BLKPortTypes.plist" ofType:nil];
        sPortTypes = [NSArray arrayWithContentsOfFile:path];
        
        for (NSString* path in sAdditionalPortDescriptorPaths) {
            @try {
                NSArray* descriptors = [NSArray arrayWithContentsOfFile:path];
                
                sPortTypes = [sPortTypes arrayByAddingObjectsFromArray:descriptors];
            }
            @catch (NSException *exception) {
                NSLog(@"Couldn't handle BLKService descriptors from file %@", path);
            }
        }
    }

    return sPortTypes;
}

+ (Class)viewControllerClassForPortType:(NSString*)type
{
    NSDictionary* dict = [self.controlPortTypes firstObjectFromPredicate:[NSPredicate predicateWithFormat:@"%K = %@",
                                                                          kBLKPortType, type]];

    return NSClassFromString([dict valueForKey:kBLKPortViewControllerClassName]);
}

+ (void)enumeratePortTypesForViewControllerClass:(Class)klass withBlock:(void(^)(NSString* portType, NSString* identifier, NSInteger subindex, NSDictionary* options))block
{
    if (!klass) {
        return;
    }

    NSDictionary* dict = [self.controlPortTypes firstObjectFromPredicate:[NSPredicate predicateWithFormat:@"%K = %@",
                                                                          kBLKPortViewControllerClassName,
                                                                          NSStringFromClass(klass)]];

    NSArray* ports = [dict valueForKey:kBLKPorts];
    if (ports.count) {
        [ports enumerateObjectsUsingBlock:^(NSDictionary* portDict, NSUInteger idx, BOOL *stop) {
            NSString*     portType   = [portDict valueForKey:kBLKPortType];
            NSString*     identifier = [portDict valueForKey:kBLKPortIdentifier];
            NSDictionary* options    = [portDict valueForKey:kBLKPortOptions];
            if (!identifier.length) {
                identifier = kBLKPortIdentifierDefault;
            }
            
            block(portType, identifier, idx, options);
        }];

        return;
    }
    
    NSString* portType = [dict valueForKey:kBLKPortType];
    
    block(portType, kBLKPortIdentifierDefault, 0, nil);
}

#pragma mark - Setup/teardown

- (id)initWithPeripheral:(CBPeripheral*)peripheral andCharacteristic:(CBCharacteristic*)characteristic
{
    if ((self = [super init])) {
        self.watchdogTimeout = 1.0;
        self.peripheral = peripheral;
        [self parseCharacteristics:@[ characteristic ]];
    }

    return self;
}

- (id)initWithPeripheral:(CBPeripheral*)peripheral andCharacteristics:(NSArray*)characteristics
{
    if ((self = [super init])) {
        self.watchdogTimeout = 1.0;
        self.peripheral = peripheral;
        [self parseCharacteristics:characteristics];
    }
    
    return self;
}

#pragma mark - Operations

- (BOOL)parseCharacteristics:(NSArray *)characteristics
{
    if (characteristics.count == 1) {
        self.characteristic    = characteristics[0];
        self.characteristicUUID = self.characteristic.UUID;

        return YES;
    }

    return NO;
}

- (BOOL)refreshCharacteristics:(NSArray*)characteristics
{
    for (CBCharacteristic* c in characteristics) {
        if ([self.characteristicUUID isEqual:c.UUID]) {
            self.characteristic = c;
            return YES;
        }
    }

    return NO;
}

#pragma mark - Actions

- (void)invalidateWatchdogTimer
{
    [self.watchdogTimer invalidate];
    self.watchdogTimer = nil;
    self.operationInProgress = NO;
}

- (void)startWatchdogTimer
{
    [self.watchdogTimer invalidate];
    
    if (self.watchdogTimeout > 0) {
        self.watchdogTimer = [NSTimer scheduledTimerWithTimeInterval:self.watchdogTimeout
                                                              target:self
                                                            selector:@selector(watchdogTimerFired:)
                                                            userInfo:nil
                                                             repeats:NO];
        self.operationInProgress = YES;
    }
}

- (void)watchdogTimerFired:(NSTimer*)timer
{
#ifdef DEBUG
    NSLog(@"BLKPort watchdog timer fired");
#endif
    if (self.operationInProgress) {
        self.operationInProgress = NO;
        if (self.nextFailureBlock) {
            self.nextFailureBlock();
        }
    }
}

#pragma mark - BLKCharacteristicListener

- (void)service:(BLKService*)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
{
    [self invalidateWatchdogTimer];
    self.lastError = nil;
    if (self.nextCompletionBlock) {
        self.nextCompletionBlock();
    }
}

- (void)service:(BLKService*)peripheral didFailToWriteValueForCharacteristic:(CBCharacteristic *)characteristic withError:(NSError *)error
{
    [self invalidateWatchdogTimer];
    self.lastError = error;
    if (self.nextFailureBlock) {
        self.nextFailureBlock();
    }
}

- (void)service:(BLKService*)service didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
{
    [self invalidateWatchdogTimer];
    self.lastError = nil;
    self.lastReadData = characteristic.value;
    if (self.nextCompletionBlock) {
        self.nextCompletionBlock();
    }
}

- (void)service:(BLKService *)service didFailToUpdateValueForCharacteristic:(CBCharacteristic *)characteristic withError:(NSError *)error
{
    [self invalidateWatchdogTimer];
    self.lastError = error;
    if (self.nextFailureBlock) {
        self.nextFailureBlock();
    }
}

@end
