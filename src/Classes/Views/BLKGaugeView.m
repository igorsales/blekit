//
//  BLKGaugeView.m
//  BLEKit
//
//  Created by Igor Sales on 2015-06-10.
//  Copyright (c) 2015 IgorSales.ca. All rights reserved.
//

#import "BLKGaugeView.h"
#import <QuartzCore/QuartzCore.h>

@implementation BLKGaugeView

- (void)awakeFromNib
{
    self.minimumValue = 0.0;
    self.maximumValue = 1.0;
    self.fillColor = self.tintColor;
    
    self.layer.masksToBounds = YES;
}

- (void)setValue:(CGFloat)value
{
    if (value < self.minimumValue) {
        value = self.minimumValue;
    } else if (value > self.maximumValue) {
        value = self.maximumValue;
    }

    if (_value != value) {
        _value = value;
        self.readingLabel.text = [NSString stringWithFormat:@"%.2f", value];
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    if (self.maximumValue <= self.minimumValue) {
        return;
    }

    CGFloat bottom = self.bounds.size.height;
    CGFloat y = bottom - self.value / (self.maximumValue - self.minimumValue) * self.bounds.size.height;
    
    CGRect fillRect = CGRectMake(0, y, self.bounds.size.width, bottom - y);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [self.backgroundColor setFill];
    CGContextFillRect(ctx, self.bounds);
    
    [self.fillColor setFill];
    CGContextFillRect(ctx, fillRect);
}

@end
