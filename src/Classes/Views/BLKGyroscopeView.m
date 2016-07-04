//
//  BLKGyroscopeView.m
//  BLEKit
//
//  Created by Igor Sales on 2014-11-13.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKGyroscopeView.h"

@interface BLKGyroscopeView()

@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat padding;
@property (nonatomic, assign) CGFloat arrowWidth;

@end

@implementation BLKGyroscopeView

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
    self.xy = CGPointMake(1.0, 1.0);
    self.z  = 1.0;
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
    CGFloat X = self.bounds.size.width / 2.0;
    CGFloat Y = self.bounds.size.height / 2.0;
    CGFloat Z = (X + Y) / 2.0;
    
    UIColor* posColour = self.tintColor;
    
    CGFloat r,g,b;
    [posColour getRed:&r green:&g blue:&b alpha:nil];
    UIColor* negColour = [UIColor colorWithRed:1.0 - r green:1.0 - g blue:1.0 - b alpha:1.0];

    UIBezierPath* bp = [UIBezierPath new];
    [bp setLineWidth:self.lineWidth];
    [bp moveToPoint:CGPointMake(X, Y)]; // move to centre
    
    CGFloat arrowSide = self.arrowWidth / 2.0;
    //CGFloat posArrowSide = arrowSide;
    //CGFloat negArrowSide = -arrowSide;
    
    // X-Axis
    CGFloat x = 0.75 * X;
    
    [bp addLineToPoint:CGPointMake(X + x, Y)];
    [bp addLineToPoint:CGPointMake(X + x - arrowSide, Y - arrowSide)];
    [bp moveToPoint:CGPointMake(X + x, Y)];
    [bp addLineToPoint:CGPointMake(X + x - arrowSide, Y + arrowSide)];
    
    [posColour set];
    [bp stroke];
    [bp removeAllPoints];
    
    r = 0.12 * X;
    CGFloat R = 2.0 * r;
    CGFloat angle = -self.xy.x * M_PI / 180;

    if (angle >= 0.0) {
        [posColour set];
        [bp addArcWithCenter:CGPointMake(X + x, Y) radius:R startAngle:M_PI endAngle:M_PI + angle clockwise:YES];
    } else {
        [negColour set];
        [bp addArcWithCenter:CGPointMake(X + x, Y) radius:R startAngle:M_PI endAngle:M_PI + angle clockwise:NO];
    }
    [bp stroke];
    [bp removeAllPoints];
    
    // Y-Axis
    CGFloat y = 0.75 * Y;
    
    [bp moveToPoint:CGPointMake(X, Y)];
    [bp addLineToPoint:CGPointMake(X, Y - y)];
    [bp addLineToPoint:CGPointMake(X - arrowSide, Y - y + arrowSide)];
    [bp moveToPoint:CGPointMake(X, Y - y)];
    [bp addLineToPoint:CGPointMake(X + arrowSide, Y - y + arrowSide)];
    
    [posColour set];
    [bp stroke];
    [bp removeAllPoints];
    
    CGFloat angleGap = 0.05 * 2.0 * M_PI;
    
    angle = self.xy.y * M_PI / 180;
    if (angle > 1.95 * M_PI) {
        angle = 1.95 * M_PI;
    } else if (angle < -1.95 * M_PI) {
        angle = -1.95 * M_PI;
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, X, Y - y);
    CGContextScaleCTM(ctx, 1.0, 0.5);
    
    if (angle >= 0.0) {
        [posColour set];
        [bp addArcWithCenter:CGPointMake(0, 0)
                      radius:R startAngle:3.0 * M_PI_2 - angleGap
                    endAngle:3.0 * M_PI_2 - angleGap - angle
                   clockwise:NO];
    } else {
        [negColour set];
        [bp addArcWithCenter:CGPointMake(0, 0) radius:R
                  startAngle:3.0 * M_PI_2 + angleGap
                    endAngle:3.0 * M_PI_2 + angleGap - angle
                   clockwise:YES];
    }
    [bp stroke];
    [bp removeAllPoints];

    CGContextRestoreGState(ctx);

    
    // Z-Axis
    CGFloat z = 0.75;
    
    CGFloat w = 1.0;
    CGFloat h = sqrt(X*X+Y*Y);
    if (h > 0) {
        w = Z / h;
    }
    x = z * Z * w;
    y = z * Z * w;
    
    [bp moveToPoint:CGPointMake(X, Y)];
    [bp addLineToPoint:CGPointMake(X - x, Y + y)];
    [bp addLineToPoint:CGPointMake(X - x, Y + y - arrowSide)];
    [bp moveToPoint:CGPointMake(X - x, Y + y)];
    [bp addLineToPoint:CGPointMake(X - x + arrowSide, Y + y)];
    
    [posColour set];
    [bp stroke];
    [bp removeAllPoints];

    angle = -self.z * M_PI / 180;
    
    if (angle >= 0.0) {
        [posColour set];
        [bp addArcWithCenter:CGPointMake(X - x, Y + y) radius:R startAngle:1.75*M_PI endAngle:1.75*M_PI + angle clockwise:YES];
    } else {
        [negColour set];
        [bp addArcWithCenter:CGPointMake(X - x, Y + y) radius:R startAngle:1.75*M_PI endAngle:1.75*M_PI + angle clockwise:NO];
    }
    [bp stroke];
}

@end
