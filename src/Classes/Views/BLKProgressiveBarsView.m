//
//  BLKProgressiveBarsView.m
//  BLEKit
//
//  Created by Igor Sales on 2014-12-01.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKProgressiveBarsView.h"

@interface BLKProgressiveBarsView()

@property (nonatomic, assign) CGFloat padding;
@property (nonatomic, assign) NSInteger numberOfBars;
@property (nonatomic, assign) CGFloat minY;
@property (nonatomic, assign) CGFloat maxY;

@end


@implementation BLKProgressiveBarsView

#pragma mark - Setup/teardown

- (void)setup
{
    self.signal = 0.5;
    self.minY = 0.3;

    self.padding = 1.0;
    self.numberOfBars = 5;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self setup];
    }

    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self setup];
    }

    return self;
}

#pragma mark - Accessors

- (void)setSignal:(CGFloat)signal
{
    if (_signal != signal) {
        _signal = signal;
        [self setNeedsDisplay];
    }
}

#pragma mark - Overrides

- (void)drawRect:(CGRect)rect
{
    CGFloat outerBarwidth = (self.bounds.size.width) / self.numberOfBars;
    CGFloat barWidth      = outerBarwidth - 2.0 * self.padding;
    CGFloat barHeight     = self.bounds.size.height - 2.0 * self.padding;
    CGFloat y0 = 0; //self.padding;
    CGFloat y1 = y0 + (1.0 - self.minY) * barHeight;
    CGFloat y2 = self.bounds.size.height; // - self.padding;
    CGFloat stepY = (y1 - y0) / self.numberOfBars;
    CGFloat signalBand = 1.0 / self.numberOfBars;

    for (NSInteger bar = 0; bar < self.numberOfBars; bar++) {
        CGFloat x0 = outerBarwidth * bar + self.padding;
        CGFloat x1 = x0 + barWidth;
        CGFloat y  = y1 - bar * stepY;
        CGFloat lowerBound = signalBand * bar;
        CGFloat upperBound = signalBand * (bar + 1);

        CGRect rect = CGRectMake(x0, y - self.padding, x1 - x0, y2 - y);
        UIBezierPath* bp = [UIBezierPath bezierPathWithRoundedRect:rect
                                                      cornerRadius:1.5];
        [bp setLineWidth:1.0];
        if (self.signal >= upperBound) {
            [self.tintColor set];
            [bp fill];
        } else if (self.signal >= lowerBound) {
            [[self.tintColor colorWithAlphaComponent:(self.signal - lowerBound)/signalBand] set];
            [bp fill];
        }
        
        [self.tintColor set];
        [bp stroke];
    }
    
    //[[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:0] stroke];
}

@end
