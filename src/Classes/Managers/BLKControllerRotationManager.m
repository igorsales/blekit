//
//  BLKDeviceRotationManager.m
//  BLEKit
//
//  Created by Igor Sales on 2015-04-14.
//  Copyright (c) 2015 IgorSales.ca. All rights reserved.
//

#import "BLKControllerRotationManager.h"
#import <CoreMotion/CoreMotion.h>
#import <QuartzCore/QuartzCore.h>

#define kBLKNoiseLevel  (0.0125)

@interface BLKControllerRotationManager()

@property (nonatomic, strong) NSOperationQueue* queue;
@property (nonatomic, strong) CMMotionManager* mm;

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat z;

@end

@implementation BLKControllerRotationManager

- (id)init
{
    if ((self = [super init])) {
        self.orientation = UIDeviceOrientationPortrait;
        self.queue = [NSOperationQueue new];
        self.mm = [CMMotionManager new];
        self.mm.deviceMotionUpdateInterval = 5.0 / 60.0; // 5Hz
    }
    
    return self;
}

- (IBAction)start:(id)sender
{
    [self.mm startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical
                                                 toQueue:self.queue
                                             withHandler:^(CMDeviceMotion *motion, NSError *error)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            CGFloat x = motion.gravity.x;
            CGFloat y = motion.gravity.y;
            CGFloat z = motion.gravity.z;
            
            if (fabs(self.x-x) > kBLKNoiseLevel ||
                fabs(self.y-y) > kBLKNoiseLevel ||
                fabs(self.z-z) > kBLKNoiseLevel) {
                self.x = x;
                self.y = y;
                self.z = z;

                CGFloat tiltForwardBackward = acosf(self.z) * 180.0f / M_PI - 90.0f;
                
                CGFloat angle = 0;
                switch (self.orientation) {
                    case UIDeviceOrientationPortrait: angle = atan2(self.y, self.x) + M_PI_2; break;
                    case UIDeviceOrientationLandscapeLeft: angle = atan2(self.x, -self.y) + M_PI_2; break;
                    case UIDeviceOrientationLandscapeRight: angle = atan2(-self.x, self.y) + M_PI_2; break;
                    default: break;
                }
                
                CGFloat angleDegrees = angle * 180.0f / M_PI;   // in degrees
                
                if (angleDegrees >= -90 && angleDegrees <= 90) {
                    [self.delegate manager:self userDidTiltToDegrees:tiltForwardBackward angle:angleDegrees];
                }
            }
        }];
    }];
}

- (IBAction)stop:(id)sender
{
    [self.mm stopDeviceMotionUpdates];
}

@end
