//
//  NSString+CapitalizedSelector.m
//  BLEKit
//
//  Created by Igor Sales on 2014-09-24.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "NSString+CapitalizedSelector.h"

@implementation NSString (CapitalizedSelector)

- (NSString*)capitalizedSelectorString
{
    return [NSString stringWithFormat:@"%@%@", [self substringToIndex:1].uppercaseString, [self substringFromIndex:1]];
}

@end
