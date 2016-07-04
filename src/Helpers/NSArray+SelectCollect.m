//
//  NSArray+SelectCollect.m
//  BLEKit
//
//  Created by Igor Sales on 2014-10-30.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "NSArray+SelectCollect.h"

@implementation NSArray (SelectCollect)

- (id)firstObjectFromPredicate:(NSPredicate*)predicate
{
    __block id retObj = nil;
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([predicate evaluateWithObject:obj]) {
            retObj = obj;
            *stop = YES;
        }
    }];

    return retObj;
}

@end
