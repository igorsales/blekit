//
//  BLKPWMChannelPort.h
//  BLEKit
//
//  Created by Igor Sales on 2014-10-03.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BLEKit/BLKPort.h>

extern NSString* const kBLKPortTypePWMChannels;

#define kBLKMaxNumberOfPWMChannelsPerCharacteristic (10)

@interface BLKPWMChannelsPort : BLKPort

@property (nonatomic, assign) NSInteger numberOfChannels;

- (void)setPulseWidth:(CGFloat)pulseWidth forChannel:(NSInteger)channelIndex;
- (void)setPulseWidth:(CGFloat)pulseWidth forChannel:(NSInteger)channelIndex commit:(BOOL)commit;
- (void)setRawPulseWidth:(CGFloat)pulseWidth forChannel:(NSInteger)channelIndex;
- (void)setRawPulseWidth:(CGFloat)pulseWidth forChannel:(NSInteger)channelIndex commit:(BOOL)commit;
- (void)commit;

@end
