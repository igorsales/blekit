//
//  BLKAccelerometerView.m
//  BLEKit
//
//  Created by Igor Sales on 2014-11-13.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKAccelerometerView.h"

@interface BLKAccelerometerView()

@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat padding;
@property (nonatomic, assign) CGFloat arrowWidth;

@end

@implementation BLKAccelerometerView

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

- (void)setup
{
    self.xy = CGPointMake(.2, .5);
    self.z  = -.75;
    self.lineWidth = 1.0;
    self.padding = self.lineWidth / 2.0 + 8.0;
    self.arrowWidth = 10.0;
}

- (void)setXY:(CGPoint)xy
{
    if (!CGPointEqualToPoint(_xy, xy)) {
        _xy = xy;
        [self setNeedsDisplay];
    }
}

- (void)setZ:(CGFloat)z
{
    if (_z != z) {
        _z = z;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGFloat X = self.bounds.size.width / 2;
    CGFloat Y = self.bounds.size.height / 2;
    CGFloat Z = (X + Y) / 2.0;
    
    UIColor* posColour = self.tintColor;
    
    CGFloat r,g,b;
    [posColour getRed:&r green:&g blue:&b alpha:nil];
    UIColor* negColour = [UIColor colorWithRed:1.0 - r green:1.0 - g blue:1.0 - b alpha:1.0];

    UIBezierPath* bp = [UIBezierPath new];
    [bp setLineWidth:self.lineWidth];
    [bp moveToPoint:CGPointMake(X, Y)]; // move to centre
    
    CGFloat arrowSide = self.arrowWidth / 2.0;
    CGFloat posArrowSide = arrowSide;
    CGFloat negArrowSide = -arrowSide;
    
    // X-Axis
    CGFloat x = self.xy.x;
    if (x > 1.0) x = 1.0;
    if (x < -1.0) x = -1.0;
    
    x = x * X;
    arrowSide = x >= 0.0 ? posArrowSide : negArrowSide;

    [bp addLineToPoint:CGPointMake(X + x, Y)];
    [bp addLineToPoint:CGPointMake(X + x - arrowSide, Y - arrowSide)];
    [bp moveToPoint:CGPointMake(X + x, Y)];
    [bp addLineToPoint:CGPointMake(X + x - arrowSide, Y + arrowSide)];
    
    [x >= 0.0 ? posColour : negColour set];
    [bp stroke];
    [bp removeAllPoints];
    
    // Y-Axis
    CGFloat y = self.xy.y;
    if (y > 1.0)  y = 1.0;
    if (y < -1.0) y = -1.0;
    
    y = y * Y;
    arrowSide = y >= 0.0 ? posArrowSide : negArrowSide;
    
    [bp moveToPoint:CGPointMake(X, Y)];
    [bp addLineToPoint:CGPointMake(X, Y - y)];
    [bp addLineToPoint:CGPointMake(X - arrowSide, Y - y + arrowSide)];
    [bp moveToPoint:CGPointMake(X, Y - y)];
    [bp addLineToPoint:CGPointMake(X + arrowSide, Y - y + arrowSide)];

    [y >= 0.0 ? posColour : negColour set];
    [bp stroke];
    [bp removeAllPoints];

    // Z-Axis
    CGFloat z = self.z;
    if (z > 1.0)  z = 1.0;
    if (z < -1.0) z = -1.0;
    
    CGFloat w = 1.0;
    CGFloat h = sqrt(X*X+Y*Y);
    if (h > 0) {
        w = Z / h;
    }
    x = z * Z * w;
    y = z * Z * w;
    arrowSide = z >= 0.0 ? posArrowSide : negArrowSide;

    [bp moveToPoint:CGPointMake(X, Y)];
    [bp addLineToPoint:CGPointMake(X - x, Y + y)];
    [bp addLineToPoint:CGPointMake(X - x, Y + y - arrowSide)];
    [bp moveToPoint:CGPointMake(X - x, Y + y)];
    [bp addLineToPoint:CGPointMake(X - x + arrowSide, Y + y)];
    
    [z >= 0.0 ? posColour : negColour set];
    [bp stroke];
}

@end