//
//  BLKConfiguration.m
//  BLEKit
//
//  Created by Igor Sales on 2014-10-21.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKConfiguration.h"
#import "BLKControl.h"

@interface BLKConfiguration() <NSCoding>

@property (nonatomic, strong) NSMutableArray* mutableControls;

@end

@implementation BLKConfiguration

@synthesize mutableControls = _controls;

- (id)init
{
    if ((self = [super init])) {
        self.mutableControls = [NSMutableArray new];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init])) {
        self.mutableControls = [[aDecoder decodeObjectForKey:@"mutableControls"] mutableCopy];
        if (!self.mutableControls) {
            self.mutableControls = [NSMutableArray new];
        }
        [self.mutableControls enumerateObjectsUsingBlock:^(BLKControl* control, NSUInteger idx, BOOL *stop) {
            control.configuration = self;
        }];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.mutableControls forKey:@"mutableControls"];
}

- (NSArray*)controls
{
    return _controls;
}

- (void)addControl:(BLKControl*)control
{
    [self.mutableControls addObject:control];
    control.configuration = self;
}

- (void)removeControl:(BLKControl*)control
{
    [self.mutableControls removeObject:control];
}

@end
