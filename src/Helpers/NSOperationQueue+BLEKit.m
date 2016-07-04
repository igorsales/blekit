//
//  NSOperationQueue+BLEKit.m
//  BLEKit
//
//  Created by Igor Sales on 2014-10-26.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "NSOperationQueue+BLEKit.h"

@implementation NSOperationQueue (BLEKit)

+ (dispatch_queue_t)BLEKitQueue
{
    static dispatch_queue_t queue = nil;

    if (!queue) {
        queue = dispatch_queue_create("org.ble-kit.operations_queue", nil);
    }
    
    return nil;//queue;
}

@end
