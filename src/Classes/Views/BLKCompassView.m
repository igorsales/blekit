//
//  BLKCompassView.m
//  BLEKit
//
//  Created by Igor Sales on 2014-10-30.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKCompassView.h"

@interface BLKCompassView()

@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat padding;
@property (nonatomic, assign) CGFloat arrowWidth;

@property (nonatomic, strong) UIBezierPath* circlePath;
@property (nonatomic, strong) UIBezierPath* arrowOutline;
@property (nonatomic, strong) UIBezierPath* leftHalf;
@property (nonatomic, strong) UIBezierPath* rightHalf;
@property (nonatomic, assign) CGPoint centre;

@end

@implementation BLKCompassView

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
    self.bearings = CGPointMake(8.0, -12.0);
    self.lineWidth = 1.0;
    self.padding = self.lineWidth / 2.0 + 8.0;
    self.arrowWidth = 10.0;
}

- (void)setupBezierPaths
{
    CGRect bounds = CGRectInset(self.bounds, self.padding, self.padding);
    self.circlePath = [UIBezierPath bezierPathWithOvalInRect:bounds];
    [self.circlePath setLineWidth:self.lineWidth];
    
    CGFloat radius = bounds.size.width / 2 - 2.0;

    UIBezierPath* bp = [UIBezierPath new];
    [bp setLineWidth:self.lineWidth];
    
    [bp moveToPoint:CGPointMake(0, 0)];
    [bp addLineToPoint:CGPointMake(-self.arrowWidth, -self.arrowWidth)];
    [bp addLineToPoint:CGPointMake(0, -radius)];
    [bp addLineToPoint:CGPointMake(self.arrowWidth, - self.arrowWidth)];
    [bp addLineToPoint:CGPointMake(0, 0)];
    [bp addLineToPoint:CGPointMake(0, -radius)];
    self.arrowOutline = bp;
    
    bp = [UIBezierPath new];
    [bp moveToPoint:CGPointMake(0, 0)];
    [bp addLineToPoint:CGPointMake(-self.arrowWidth, -self.arrowWidth)];
    [bp addLineToPoint:CGPointMake(0, -radius)];
    [bp addLineToPoint:CGPointMake(0, 0)];
    self.leftHalf = bp;

    bp = [UIBezierPath new];
    [bp moveToPoint:CGPointMake(0, 0)];
    [bp addLineToPoint:CGPointMake(self.arrowWidth, -self.arrowWidth)];
    [bp addLineToPoint:CGPointMake(0, -radius)];
    [bp addLineToPoint:CGPointMake(0, 0)];
    self.rightHalf = bp;

    self.centre = CGPointMake(bounds.origin.x + bounds.size.width / 2,
                              bounds.origin.y + bounds.size.height / 2);

}

- (void)setBearings:(CGPoint)bearings
{
    if (!CGPointEqualToPoint(_bearings, bearings)) {
        _bearings = bearings;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    if (!self.circlePath) {
        [self setupBezierPaths];
    }

    [self.backgroundColor set];
    [self.circlePath fill];
    [self.tintColor set];
    [self.circlePath stroke];
    
    CGPoint north = self.bearings;
    CGFloat len   = sqrt(north.x * north.x + north.y * north.y);
    if (len > 1.0) {
        north.x = north.x / len;
        north.y = north.y / len;
    }

    CGFloat angle = atan2(-self.bearings.y, self.bearings.x);
    if (angle < 0) {
        angle = angle + 2.0 * M_PI;
    }
    angle = angle + M_PI_2; // compass 0 degrees is north
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    
    CGContextTranslateCTM(ctx, self.centre.x, self.centre.y);
    CGContextRotateCTM(ctx, angle);
    CGContextSetFillColorWithColor(ctx, [self.tintColor colorWithAlphaComponent:0.3].CGColor);
    [self.leftHalf fill];
    CGContextSetFillColorWithColor(ctx, [self.tintColor colorWithAlphaComponent:0.6].CGColor);
    [self.rightHalf fill];
    [self.arrowOutline stroke];
    
    CGContextRotateCTM(ctx, M_PI_2);
    [self.arrowOutline stroke];

    CGContextRotateCTM(ctx, M_PI_2);
    [self.arrowOutline stroke];

    CGContextRotateCTM(ctx, M_PI_2);
    [self.arrowOutline stroke];

    CGContextRestoreGState(ctx);
}

@end
