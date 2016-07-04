//
//  BLKEditorUnderview.m
//  BLEKit
//
//  Created by Igor Sales on 2014-10-18.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKEditorControl.h"

@interface BLKEditorControl()

@property (nonatomic, weak) UITouch* fingerTouch;
@property (nonatomic, assign) CGSize delta;

@end

@implementation BLKEditorControl

#pragma mark - Private

- (void)drawHandleInRect:(CGRect)rect
{
    CGFloat delta_y = rect.size.height / 6;

    CGFloat x0 = rect.origin.x + delta_y;
    CGFloat x1 = rect.origin.x + rect.size.width - delta_y;
    
    for (NSInteger bar = 0; bar < 3; bar++) {
        CGFloat y0 = rect.origin.y + delta_y + 1.5 * delta_y * bar;
        
        UIBezierPath *bp = [UIBezierPath bezierPathWithRect:CGRectMake(x0, y0,
                                                                       x1 - x0, delta_y)];

        [bp stroke];
    }
}

#pragma mark - Overrides

- (void)drawRect:(CGRect)rect
{
    CGRect frameTopLeft     = CGRectMake(0,
                                         0,
                                         self.draggableBorderWidth, self.draggableBorderWidth);

    CGRect frameTopRight    = CGRectMake(self.bounds.size.width - self.draggableBorderWidth,
                                         0,
                                         self.draggableBorderWidth, self.draggableBorderWidth);

    CGRect frameBottomLeft  = CGRectMake(0,
                                         self.bounds.size.height - self.draggableBorderWidth,
                                         self.draggableBorderWidth, self.draggableBorderWidth);

    CGRect frameBottomRight = CGRectMake(self.bounds.size.width - self.draggableBorderWidth,
                                         self.bounds.size.height - self.draggableBorderWidth,
                                         self.draggableBorderWidth, self.draggableBorderWidth);

    [[UIColor darkGrayColor] set];
    [self drawHandleInRect:frameTopLeft];
    [self drawHandleInRect:frameTopRight];
    [self drawHandleInRect:frameBottomLeft];
    [self drawHandleInRect:frameBottomRight];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (self.fingerTouch) {
        return NO;
    }
    
    CGPoint xy0 = CGPointMake(self.draggableBorderWidth, self.draggableBorderWidth);
    CGPoint xy1 = CGPointMake(self.bounds.size.width - self.draggableBorderWidth, self.bounds.size.height - self.draggableBorderWidth);

    CGPoint p = [touch locationInView:self];
    if ((p.x <= xy0.x && p.y < xy0.y) ||
        (p.x >= xy1.x && p.y < xy0.y) ||
        (p.x <= xy0.x && p.y > xy1.y) ||
        (p.x >= xy1.x && p.y > xy1.y)) {
        self.fingerTouch = touch;
        return YES;
    }
    
    return NO;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint p0 = [touch previousLocationInView:self];
    CGPoint p1 = [touch locationInView:self];

    self.delta = CGSizeMake(p1.x - p0.x, p1.y - p0.y);
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];

    return YES;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    self.fingerTouch = nil;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.fingerTouch = nil;
}

@end
