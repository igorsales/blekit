//
//  NSIndexPath+Tag.m
//  BLEKit
//
//  Created by Igor Sales on 2014-10-22.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "NSIndexPath+Tag.h"

#define DIVIDER (100000)

@implementation NSIndexPath (Tag)

+ (NSIndexPath*)indexPathFromTag:(NSInteger)tag
{
    return [NSIndexPath indexPathForRow:tag % DIVIDER inSection:tag / DIVIDER];
}

- (NSInteger)tag
{
    return self.section * DIVIDER + self.row;
}

@end
