//
//  CALayer+Borders.m
//  BLEKit
//
//  Created by Igor Sales on 2015-05-15.
//  Copyright (c) 2015 IgorSales.ca. All rights reserved.
//

#import "CALayer+Borders.h"

@implementation CALayer (CALayer_Borders)

- (void)setBorderWithTintColour:(UIColor*)tintColour
{
    self.borderColor = [tintColour colorWithAlphaComponent:0.73].CGColor;
    self.borderWidth = 1.0;
    self.cornerRadius = 8.0;
}

@end
