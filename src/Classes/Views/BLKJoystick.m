//
//  BLKJoystick.m
//  BLEKit
//
//  Created by Igor Sales on 2014-10-04.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKJoystick.h"
#import <QuartzCore/QuartzCore.h>

@interface BLKJoystick()

@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat padding;
@property (nonatomic, assign) CGFloat stickRadius;

@property (nonatomic, assign) CGRect  stickBounds;
@property (nonatomic, assign) CGPoint stickPosition;
@property (nonatomic, assign) CGRect  stickRect;

@property (nonatomic, weak) UITouch* fingerTouch;

@end

@implementation BLKJoystick

#pragma mark - Setup/teardown

- (id)initWithType:(BLKJoystickType)type
{
    if ((self = [super init])) {
        self.type = type;
        [self setup];
    }

    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.type = BLKJoystickTypeHorizontalAndVertical;
        [self setup];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        self.type = BLKJoystickTypeHorizontalAndVertical;
        [self setup];
    }

    return self;
}

- (void)setup
{
    self.lineWidth = 1.0;
    self.padding = self.lineWidth / 2.0 + 8.0;
    self.stickRadius = self.bounds.size.width / 12.3809524; //=21.0;
}

#pragma mark - Accessors

- (void)setInvertHorizontal:(BOOL)invertHorizontal
{
    if (_invertHorizontal != invertHorizontal) {
        _invertHorizontal = invertHorizontal;
        
        [self updateJoystickCentre];
    }
}

- (void)setInvertVertical:(BOOL)invertVertical
{
    if (_invertVertical != invertVertical) {
        _invertVertical = invertVertical;

        [self updateJoystickCentre];
    }
}

- (void)setStickyHorizontal:(BOOL)stickyHorizontal
{
    if (_stickyHorizontal != stickyHorizontal) {
        _stickyHorizontal = stickyHorizontal;
        
        if (!_stickyHorizontal) {
            [self centreStick];
        }
    }
}

- (void)setStickyVertical:(BOOL)stickyVertical
{
    if (_stickyVertical != stickyVertical) {
        _stickyVertical = stickyVertical;

        if (!_stickyVertical) {
            [self centreStick];
        }
    }
}

#pragma mark - Private

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self centreStick];
}

- (void)centreStick
{
    CGFloat x = self.stickyHorizontal ? self.stickPosition.x : self.bounds.size.width / 2;
    CGFloat y = self.stickyVertical   ? self.stickPosition.y : self.bounds.size.height / 2;

    self.stickPosition = CGPointMake(x, y);
}

- (void)updateJoystickCentre
{
    if (self.stickBounds.size.width > 0 && self.stickBounds.size.height > 0) {
        CGRect stickWindow = CGRectMake(self.stickBounds.origin.x + self.stickRadius,
                                        self.stickBounds.origin.y + self.stickRadius,
                                        self.stickBounds.size.width - 2*self.stickRadius,
                                        self.stickBounds.size.height - 2*self.stickRadius);
        CGFloat normalX = -1.0 + 2.0 * (_stickPosition.x - stickWindow.origin.x) / stickWindow.size.width;
        CGFloat normalY = -1.0 + 2.0 * (_stickPosition.y - stickWindow.origin.y) / stickWindow.size.height;
        
        if (normalX < -1.0) { normalX = -1.0; } else if (normalX > 1.0) { normalX = 1.0; }
        if (normalY < -1.0) { normalY = -1.0; } else if (normalY > 1.0) { normalY = 1.0; }
        
        if (self.invertHorizontal) {
            normalX = -normalX;
        }
        
        if (self.invertVertical) {
            normalY = -normalY;
        }
        
        if (fabs(self.joystickCentre.x-normalX) > 0.05 || fabs(self.joystickCentre.y-normalY) > 0.05) {
            self.joystickCentre = CGPointMake(normalX, normalY);
            
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }

}

- (void)setStickPosition:(CGPoint)newPosition
{
    if (_stickPosition.x != newPosition.x || _stickPosition.y != newPosition.y) {
        _stickPosition = newPosition;
        
        [self updateJoystickCentre];
    }
}

#pragma mark - Overrides

- (void)drawRect:(CGRect)rect
{
    [self.tintColor set];
    self.stickBounds = CGRectInset(self.bounds, self.padding, self.padding);
    UIBezierPath* circlePath = [UIBezierPath bezierPathWithOvalInRect:self.stickBounds];
    [circlePath setLineWidth:self.lineWidth];
    [circlePath stroke];
    
    CGFloat arrowSide = self.stickRadius * 2;
    CGFloat oneFifth  = arrowSide / 5;
    
    CGFloat x0 = self.stickBounds.origin.x + oneFifth;
    CGFloat x1 = self.stickBounds.origin.x + arrowSide - oneFifth - oneFifth;
    CGFloat x2 = self.stickBounds.origin.x + arrowSide - oneFifth;
    CGFloat y0 = self.stickBounds.origin.y + self.stickBounds.size.height / 2 - arrowSide / 2 + oneFifth;
    CGFloat y1 = self.stickBounds.origin.y + self.stickBounds.size.height / 2;
    CGFloat y2 = self.stickBounds.origin.y + self.stickBounds.size.height / 2 + arrowSide / 2 - oneFifth;

    UIBezierPath* bp = [UIBezierPath new];
    if (self.type == BLKJoystickTypeHorizontal || self.type == BLKJoystickTypeHorizontalAndVertical) {
        [bp moveToPoint:CGPointMake(x0, y1)];
        [bp addLineToPoint:CGPointMake(x2, y0)];
        [bp addLineToPoint:CGPointMake(x1, y1)];
        [bp addLineToPoint:CGPointMake(x2, y2)];
        [bp addLineToPoint:CGPointMake(x0, y1)];
    }

    if (self.type == BLKJoystickTypeVertical || self.type == BLKJoystickTypeHorizontalAndVertical) {
        [bp moveToPoint:CGPointMake(y1, x0)];
        [bp addLineToPoint:CGPointMake(y0, x2)];
        [bp addLineToPoint:CGPointMake(y1, x1)];
        [bp addLineToPoint:CGPointMake(y2, x2)];
        [bp addLineToPoint:CGPointMake(y1, x0)];
    }

    x0 = self.stickBounds.origin.x + self.stickBounds.size.width - oneFifth;
    x1 = self.stickBounds.origin.x + self.stickBounds.size.width - arrowSide + oneFifth + oneFifth;
    x2 = self.stickBounds.origin.x + self.stickBounds.size.width - arrowSide + oneFifth;
    
    if (self.type == BLKJoystickTypeHorizontal || self.type == BLKJoystickTypeHorizontalAndVertical) {
        [bp moveToPoint:CGPointMake(x0, y1)];
        [bp addLineToPoint:CGPointMake(x2, y0)];
        [bp addLineToPoint:CGPointMake(x1, y1)];
        [bp addLineToPoint:CGPointMake(x2, y2)];
        [bp addLineToPoint:CGPointMake(x0, y1)];
    }

    if (self.type == BLKJoystickTypeVertical || self.type == BLKJoystickTypeHorizontalAndVertical) {
        [bp moveToPoint:CGPointMake(y1, x0)];
        [bp addLineToPoint:CGPointMake(y0, x2)];
        [bp addLineToPoint:CGPointMake(y1, x1)];
        [bp addLineToPoint:CGPointMake(y2, x2)];
        [bp addLineToPoint:CGPointMake(y1, x0)];
    }
    [bp stroke];
    
    self.stickRect = CGRectMake(self.stickPosition.x - self.stickRadius,
                                self.stickPosition.y - self.stickRadius,
                                self.stickRadius * 2,
                                self.stickRadius * 2);
    UIBezierPath* stick = [UIBezierPath bezierPathWithRoundedRect:self.stickRect cornerRadius:self.stickRadius / 2];
    [stick setLineWidth:self.lineWidth];
    [[UIColor colorWithRed:1 green:1 blue:1 alpha:0.6] set];
    [stick fill];
    [[UIColor colorWithRed:0 green:0 blue:0 alpha:.73] set];
    [stick stroke];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (self.fingerTouch) {
        return NO;
    }

    self.fingerTouch = touch;
    
    CGPoint location = [touch locationInView:self];
    if (!CGRectContainsPoint(self.stickRect, location)) {
        self.stickPosition = [touch locationInView:self];
        [self setNeedsDisplay];
    }

    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (touch != self.fingerTouch) {
        return NO;
    }

    CGPoint t1 = [self.fingerTouch locationInView:self];
    CGPoint t0 = [self.fingerTouch previousLocationInView:self];
    CGPoint delta = CGPointMake(t1.x - t0.x, t1.y - t0.y);
    
    self.stickPosition = CGPointMake(self.stickPosition.x + delta.x,
                                     self.stickPosition.y + delta.y);
    
    [self setNeedsDisplay];
    
    return YES;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    if ([event.allTouches containsObject:self.fingerTouch]) {
        self.fingerTouch = nil;
        
        [self centreStick];
        [self setNeedsDisplay];
    }
}


- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (touch == self.fingerTouch) {
        self.fingerTouch = nil;

        [self centreStick];
        [self setNeedsDisplay];
    }
}

#pragma mark - Operations

- (void)moveStickToPosition:(CGPoint)position
{
    if (isnan(position.x)) {
        position.x = self.stickPosition.x;
    } else {
        position.x = (int)((self.bounds.size.width / 2) * (1 + position.x));
    }
    
    if (isnan(position.y)) {
        position.y = self.stickPosition.y;
    } else {
        position.y = (int)((self.bounds.size.height / 2) * (1 + position.y));
    }
    
    self.stickPosition = position;
    [self setNeedsDisplay];
}

- (void)turnWheelToAngle:(CGFloat)angle
{
    // TODO
}

@end
