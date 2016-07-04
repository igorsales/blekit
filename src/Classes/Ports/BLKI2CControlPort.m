//
//  BLKI2CControlPort.m
//  BLEKit
//
//  Created by Igor Sales on 2014-10-03.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKI2CControlPort.h"
#import "BLKLog.h"

NSString* const kBLKPortTypeI2CControl = @"kBLKPortTypeI2CControl";

@interface _BLKI2CControlPortQueueEntry : NSObject

@property (nonatomic, assign) BOOL isWrite;
@property (nonatomic, assign) NSInteger slaveAddr;
@property (nonatomic, assign) NSInteger regAddr;
@property (nonatomic, assign) BOOL useStopCondition;
@property (nonatomic, strong) NSData* data;
@property (nonatomic, assign) NSInteger length;
@property (nonatomic, assign) BOOL requestToReadSent;
@property (nonatomic, strong) void(^writeCompletionBlock)();
@property (nonatomic, strong) void(^readCompletionBlock)(NSData* data);
@property (nonatomic, strong) void(^failureBlock)();

- (id)initWithWriteBlock:(void(^)())writeBlock readBlock:(void(^)(NSData* data))readBlock failBlock:(void(^)())failBlock;

@end

@implementation _BLKI2CControlPortQueueEntry

- (id)initWithWriteBlock:(void (^)())writeBlock readBlock:(void (^)(NSData *))readBlock failBlock:(void (^)())failBlock
{
    if ((self = [super init])) {
        _writeCompletionBlock = writeBlock;
        _readCompletionBlock  = readBlock;
        _failureBlock         = failBlock;
    }

    return self;
}

@end

@interface BLKI2CControlPort()

@property (nonatomic, strong) NSMutableArray* queue;

@end


@implementation BLKI2CControlPort

- (id)initWithPeripheral:(CBPeripheral *)peripheral andCharacteristic:(CBCharacteristic *)characteristic
{
    if ((self = [super initWithPeripheral:peripheral andCharacteristic:characteristic])) {
        self.queue = [NSMutableArray new];
        [self _prepareBlocks];
    }

    return self;
}

- (void)_prepareBlocks
{
    __weak typeof (self) weakSelf = self;
    self.nextFailureBlock = ^{
        [weakSelf _fail];
    };
    
    self.nextCompletionBlock = ^{
        [weakSelf _handleResponse];
    };
}

- (void)_handleResponse
{
    _BLKI2CControlPortQueueEntry* entry = [self _head];
    if (!entry) {
        BLK_LOG(@"Strange! entry is nil. How come?");
        return;
    }
    
    if (entry.isWrite) {
        [self _writeComplete];
    } else {
        if (!entry.requestToReadSent) {
            entry.requestToReadSent = YES;
            [self _writeAddressComplete];
        } else {
            [self _handleReadResponseForEntry:entry];
        }
    }
}

- (void)_enqueue:(_BLKI2CControlPortQueueEntry*)entry
{
    [self.queue addObject:entry];
}

- (_BLKI2CControlPortQueueEntry*)_head
{
    return [self.queue firstObject];
}

- (_BLKI2CControlPortQueueEntry*)_dequeue
{
    _BLKI2CControlPortQueueEntry* entry = [self _head];
    
    if (entry) {
        [self.queue removeObjectAtIndex:0];
    }

    return entry;
}

- (void)_executeNext
{
    _BLKI2CControlPortQueueEntry* entry = [self.queue firstObject];
    if (!entry) {
        return;
    }

    if (entry.isWrite) {
        [self _writeBytes:entry.data
           toSlaveAddress:entry.slaveAddr
       andRegisterAddress:entry.regAddr
         useStopCondition:entry.useStopCondition];
    } else { // read
        [self _readBytes:entry.length
        fromSlaveAddress:entry.slaveAddr
      andRegisterAddress:entry.regAddr
        useStopCondition:entry.useStopCondition];
    }
}
         
- (void)_writeAddressComplete
{
    // Address was written, now read the response
    [self.peripheral readValueForCharacteristic:self.characteristic];
}

- (void)_handleReadResponseForEntry:(_BLKI2CControlPortQueueEntry*)entry
{
    struct {
        unsigned char operation;
        unsigned char reg_addr;
        unsigned char length;
    } I2CHeader;
    
    if (self.lastReadData.length < sizeof(I2CHeader)) {
        [self _fail];
        return;
    }
    
    [self.lastReadData getBytes:&I2CHeader length:sizeof(I2CHeader)];
    
    if (I2CHeader.operation != 0x01 ||
        (I2CHeader.reg_addr & 0x7f) != ((unsigned char)entry.regAddr & 0x7f) ||
        I2CHeader.length != entry.length ||
        self.lastReadData.length < 3 + entry.length) {
        [self _fail];
        return;
    }
    
    [self _readComplete:[self.lastReadData subdataWithRange:NSMakeRange(3, entry.length)]];
}

- (void)_writeComplete
{
    _BLKI2CControlPortQueueEntry* entry = [self _dequeue];

    if (entry.writeCompletionBlock) {
        entry.writeCompletionBlock();
    }

    [self _executeNext];
}

- (void)_readComplete:(NSData*)data
{
    _BLKI2CControlPortQueueEntry* entry = [self _dequeue];
    
    if (entry.readCompletionBlock) {
        entry.readCompletionBlock(data);
    }

    [self _executeNext];
}

- (void)_fail
{
    _BLKI2CControlPortQueueEntry* entry = [self _dequeue];
    
    if (entry.failureBlock) {
        entry.failureBlock();
    }

    [self _executeNext];
}

- (void)readBytes:(NSInteger)length
 fromSlaveAddress:(NSInteger)slaveAddress
andRegisterAddress:(NSInteger)regAddress
       completion:(void (^)(NSData *))completionBlock
          failure:(void (^)(void))failureBlock
{
    if (length > 16) {
        if (failureBlock) {
            failureBlock();
        }
        return;
    }

    _BLKI2CControlPortQueueEntry* entry = [_BLKI2CControlPortQueueEntry new];
    entry.isWrite = NO;
    entry.slaveAddr = slaveAddress;
    entry.regAddr = regAddress;
    entry.length = length;
    entry.useStopCondition = self.useStopCondition;
    entry.requestToReadSent = NO;
    entry.readCompletionBlock = completionBlock;
    entry.failureBlock = failureBlock;
    
    BOOL immediate = self.queue.count == 0;
    
    [self.queue addObject:entry];
    
    if (immediate) {
        [self _executeNext];
    }
}

- (void)_readBytes:(NSInteger)length
  fromSlaveAddress:(NSInteger)slaveAddress
andRegisterAddress:(NSInteger)regAddress
  useStopCondition:(BOOL)useStopCondition
{
    unsigned char command[5];

    command[0] = 0x01; // READ Operation
    command[1] = (unsigned char)slaveAddress;
    command[2] = useStopCondition ? 0x01 : 0x00;
    command[3] = length;
    command[4] = (unsigned char)regAddress | 0x80;

    NSData* cmdBytes = [NSData dataWithBytes:command length:5];
    [self.peripheral writeValue:cmdBytes
              forCharacteristic:self.characteristic
                           type:CBCharacteristicWriteWithResponse];
}

- (void)_writeBytes:(NSData *)data
    toSlaveAddress:(NSInteger)slaveAddress
andRegisterAddress:(NSInteger)regAddress
  useStopCondition:(BOOL)useStopCondition
{
    unsigned char command[5 + 16];
    NSInteger length = data.length;

    command[0] = 0x00; // WRITE Operation
    command[1] = (unsigned char)slaveAddress;
    command[2] = useStopCondition ? 0x01 : 0x00;
    command[3] = length;
    command[4] = (unsigned char)regAddress | 0x80;
    memcpy(command + 5, data.bytes, length);

    NSData* cmdBytes = [NSData dataWithBytes:command length:5 + length];
    [self.peripheral writeValue:cmdBytes
              forCharacteristic:self.characteristic
                           type:CBCharacteristicWriteWithResponse];

}

- (void)writeBytes:(NSData *)data
    toSlaveAddress:(NSInteger)slaveAddress
andRegisterAddress:(NSInteger)regAddress
        completion:(void (^)(NSInteger))completionBlock
           failure:(void (^)(void))failureBlock
{
    NSInteger length = data.length;
    if (length == 0 || length > 16) {
        if (failureBlock) {
            failureBlock();
        }
        return;
    }
    
    _BLKI2CControlPortQueueEntry* entry = [_BLKI2CControlPortQueueEntry new];
    entry.isWrite = YES;
    entry.slaveAddr = slaveAddress;
    entry.regAddr = regAddress;
    entry.data = data;
    entry.useStopCondition = self.useStopCondition;
    entry.writeCompletionBlock = completionBlock;
    entry.failureBlock = failureBlock;
    
    BOOL immediate = self.queue.count == 0;
    
    [self.queue addObject:entry];
    
    if (immediate) {
        [self _executeNext];
    }
}

@end
