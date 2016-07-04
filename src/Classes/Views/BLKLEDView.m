//
//  BLKLEDView.m
//  BLEKit
//
//  Created by Igor Sales on 2015-05-15.
//  Copyright (c) 2015 IgorSales.ca. All rights reserved.
//

#import "BLKLEDView.h"
#import <QuartzCore/QuartzCore.h>

@interface BLKLEDView()

@property (nonatomic, weak) IBOutlet UIButton* LEDButton;
@property (nonatomic, weak) IBOutlet UILabel*  numberLabel;

@end

@implementation BLKLEDView

#pragma mark - Setup/teardown

- (void)awakeFromNib
{
    [self setup];
}

#pragma mark - Accessors

@synthesize on = _on;

- (NSInteger)number
{
    return [self.numberLabel.text integerValue];
}

- (void)setNumber:(NSInteger)number
{
    self.numberLabel.text = @(number).description;
}

- (BOOL)on
{
    return _on;
}

- (void)setOn:(BOOL)on
{
    if (_on != on) {
        _on = on;
        
        if (_on) {
            self.LEDButton.layer.backgroundColor = [self.LEDColour colorWithAlphaComponent:0.9].CGColor;
        } else {
            self.LEDButton.layer.backgroundColor = [self.LEDColour colorWithAlphaComponent:0.1].CGColor;
        }
    }
}

- (void)setLEDColour:(UIColor *)LEDColour
{
    if (_LEDColour != LEDColour) {
        _LEDColour = LEDColour;
        
        _on = !self.on; // toggle to force colour change
        self.on = !self.on;
    }
}

#pragma mark - Actions

- (IBAction)LEDButtonTapped:(id)sender
{
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Operations

- (void)toggle
{
    self.on = !self.on;
}

#pragma mark - Private

- (void)setup
{
    self.LEDColour = [UIColor greenColor];
    self.LEDButton.layer.cornerRadius    = self.bounds.size.width * 0.5;
    self.LEDButton.layer.borderWidth     = 1.0;
    self.LEDButton.layer.borderColor     = self.LEDColour.CGColor;
    self.LEDButton.layer.masksToBounds   = YES;
    self.LEDButton.layer.backgroundColor = [self.LEDColour colorWithAlphaComponent:0.1].CGColor;
}

@end
