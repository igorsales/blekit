//
//  BLKJoystickViewController.m
//  BLEKit
//
//  Created by Igor Sales on 2014-10-06.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKJoystickViewController.h"
#import "BLKJoystick.h"
#import "BLKPWMChannelsPort.h"
#import "BLKEditorViewController.h"
#import "BLKJoystickSettingsViewController.h"
#import "BLKControllerRotationManager.h"
#import "BLKControl.h"
#import "CALayer+Borders.h"

#import <QuartzCore/QuartzCore.h>

@interface BLKJoystickViewController () <BLKEditorDelegate, BLKControllerRotationObserver>

@end

@implementation BLKJoystickViewController

#pragma mark - Accessors

@synthesize control = _control;
@synthesize port = _port;
@synthesize defaultsPWMPort = _defaultsPWMPort;

- (BLKPWMChannelsPort*)PWMPort
{
    return (BLKPWMChannelsPort*)self.port;
}

- (void)setHorizontalChannel:(NSInteger)horizontalChannel
{
    if (_horizontalChannel != horizontalChannel) {
        _horizontalChannel = horizontalChannel;
        [self disconnectOtherJoystickViewControllersFromChannel:_horizontalChannel];
        [self disconnectChannel:_horizontalChannel notInAxis:BLKAxisX];
    }
}

- (void)setVerticalChannel:(NSInteger)verticalChannel
{
    if (_verticalChannel != verticalChannel) {
        _verticalChannel = verticalChannel;
        [self disconnectOtherJoystickViewControllersFromChannel:_verticalChannel];
        [self disconnectChannel:_verticalChannel notInAxis:BLKAxisY];
    }
}

- (void)setZChannel:(NSInteger)zChannel
{
    if (_zChannel != zChannel) {
        _zChannel = zChannel;
        [self disconnectOtherJoystickViewControllersFromChannel:_zChannel];
        [self disconnectChannel:_zChannel notInAxis:BLKAxisZ];
    }
}

- (void)setHorizontalValueOnDisconnect:(CGFloat)horizontalValueOnDisconnect
{
    if (_horizontalValueOnDisconnect != horizontalValueOnDisconnect) {
        _horizontalValueOnDisconnect = horizontalValueOnDisconnect;
        [self joystickDefaultValueChanged:self.joystick];
    }
}

- (void)setVerticalValueOnDisconnect:(CGFloat)verticalValueOnDisconnect
{
    if (_verticalValueOnDisconnect != verticalValueOnDisconnect) {
        _verticalValueOnDisconnect = verticalValueOnDisconnect;
        [self joystickDefaultValueChanged:self.joystick];
    }
}

- (void)setZValueOnDisconnect:(CGFloat)zValueOnDisconnect
{
    if (_zValueOnDisconnect != zValueOnDisconnect) {
        _zValueOnDisconnect = zValueOnDisconnect;
        [self joystickDefaultValueChanged:self.joystick];
    }
}

- (void)setHorizontalTrim:(CGFloat)horizontalTrim
{
    if (_horizontalTrim != horizontalTrim) {
        _horizontalTrim = horizontalTrim;
        [self joystickValueChanged:self.joystick];
    }
}

- (void)setVerticalTrim:(CGFloat)verticalTrim
{
    if (_verticalTrim != verticalTrim) {
        _verticalTrim = verticalTrim;
        [self joystickValueChanged:self.joystick];
    }
}

- (void)setZTrim:(CGFloat)zTrim
{
    if (_zTrim != zTrim) {
        _zTrim = zTrim;
        [self joystickValueChanged:self.joystick];
    }
}

- (void)setHorizontalScale:(BLKChannelScale)horizontalScale
{
    if (_horizontalScale != horizontalScale) {
        _horizontalScale = horizontalScale;
        [self joystickValueChanged:self.joystick];
    }
}

- (void)setVerticalScale:(BLKChannelScale)verticalScale
{
    if (_verticalScale != verticalScale) {
        _verticalScale = verticalScale;
        [self joystickValueChanged:self.joystick];
    }
}

- (void)setZScale:(BLKChannelScale)zScale
{
    if (_zScale != zScale) {
        _zScale = zScale;
        [self joystickValueChanged:self.joystick];
    }
}

#pragma mark Setup/teardown

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        self.horizontalChannel            = NSNotFound;
        self.verticalChannel              = NSNotFound;
        self.zChannel                     = NSNotFound;
        self.horizontalDamperChannelIndex = NSNotFound;
        self.verticalDamperChannelIndex   = NSNotFound;
    }

    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.horizontalChannel            = NSNotFound;
        self.verticalChannel              = NSNotFound;
        self.zChannel                     = NSNotFound;
        self.horizontalDamperChannelIndex = NSNotFound;
        self.verticalDamperChannelIndex   = NSNotFound;
    }

    return self;
}

- (void)dealloc
{
    [self unbindProperties];
}

#pragma mark - Private

- (void)disconnectOtherJoystickViewControllersFromChannel:(NSInteger)channel
{
    [self.parentViewController.childViewControllers
     enumerateObjectsUsingBlock:^(UIViewController* vc, NSUInteger idx, BOOL *stop) {
         if (![vc isKindOfClass:[BLKJoystickViewController class]] ||
             vc == self) {
             return;
         }
         
         BLKJoystickViewController* jvc = (BLKJoystickViewController*)vc;
         if (jvc.horizontalChannel == channel) {
             jvc.horizontalChannel = NSNotFound;
         }
         if (jvc.verticalChannel == channel) {
             jvc.verticalChannel = NSNotFound;
         }
         if (jvc.zChannel == channel) {
             jvc.zChannel = NSNotFound;
         }
     }];
}

- (void)disconnectChannel:(NSInteger)channel notInAxis:(BLKAxis)axis
{
    if (channel == NSNotFound) {
        return;
    }
    
    switch (axis) {
        case BLKAxisX:
            if (self.verticalChannel == channel)
                self.verticalChannel = NSNotFound;
            if (self.zChannel == channel)
                self.zChannel = NSNotFound;
            break;
        case BLKAxisY:
            if (self.horizontalChannel == channel)
                self.horizontalChannel = NSNotFound;
            if (self.zChannel == channel)
                self.zChannel = NSNotFound;
            break;
        case BLKAxisZ:
            if (self.horizontalChannel == channel)
                self.horizontalChannel = NSNotFound;
            if (self.verticalChannel == channel)
                self.verticalChannel = NSNotFound;
            break;
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view.layer setBorderWithTintColour:self.view.tintColor];

    [self.joystick addTarget:self
                      action:@selector(joystickValueChanged:)
            forControlEvents:UIControlEventValueChanged];

    [self bindProperties];
}

- (void)bindProperties
{
    [self.control applyProperties:@[@"type",
                                    @"invertHorizontal", @"invertVertical",
                                    @"stickyHorizontal", @"stickyVertical"]
                               to:self.joystick];
    [self.control applyProperties:@[@"horizontalChannel", @"verticalChannel", @"zChannel",
                                    @"horizontalTrim", @"verticalTrim", @"zTrim",
                                    @"horizontalValueOnDisconnect", @"verticalValueOnDisconnect", @"zValueOnDisconnect",
                                    @"horizontalScale", @"verticalScale", @"zScale",
                                    @"horizontalTieToControllerAngle", @"verticalTieToControllerAngle", @"zTieToControllerAngle",
                                    @"horizontalTieToControllerTilt", @"verticalTieToControllerTilt", @"zTieToControllerTilt",
                                    @"horizontalDamperChannelIndex", @"verticalDamperChannelIndex"]
                               to:self];
    [self.control applyProperties:@[@"frame"] to:self.view];
    
    [self.control bindTo:self.joystick properties:@[@"type",
                                                    @"invertHorizontal", @"invertVertical",
                                                    @"stickyHorizontal", @"stickyVertical"]];
    [self.control bindTo:self properties:@[@"horizontalChannel", @"verticalChannel", @"zChannel",
                                           @"horizontalTrim", @"verticalTrim", @"zTrim",
                                           @"horizontalValueOnDisconnect", @"verticalValueOnDisconnect", @"zValueOnDisconnect",
                                           @"horizontalScale", @"verticalScale", @"zScale",
                                           @"horizontalTieToControllerAngle", @"verticalTieToControllerAngle", @"zTieToControllerAngle",
                                           @"horizontalTieToControllerTilt", @"verticalTieToControllerTilt", @"zTieToControllerTilt",
                                           @"horizontalDamperChannelIndex", @"verticalDamperChannelIndex"]];
    [self.control bindTo:self.view properties:@[@"frame"]];
}

- (void)unbindProperties
{
    [self.control unbindProperties:@[@"horizontalChannel", @"verticalChannel", @"zChannel",
                                     @"horizontalTrim", @"verticalTrim", @"zTrim",
                                     @"horizontalValueOnDisconnect", @"verticalValueOnDisconnect", @"zValueOnDisconnect",
                                     @"horizontalScale", @"verticalScale", @"zScale",
                                     @"horizontalTieToControllerAngle", @"verticalTieToControllerAngle", @"zTieToControllerAngle",
                                     @"horizontalTieToControllerTilt", @"verticalTieToControllerTilt", @"zTieToControllerTilt",
                                     @"horizontalDamperChannelIndex", @"verticalDamperChannelIndex"]
                              from:self];
    [self.control unbindProperties:@[@"frame"] from:self.view];
    [self.control unbindProperties:@[@"type",
                                     @"invertHorizontal", @"invertVertical",
                                     @"stickyHorizontal", @"stickyVertical"]
                          from:self.joystick];
}

- (CGFloat)scaledValue:(CGFloat)value fromChannelScale:(BLKChannelScale)scale dampeningChannel:(NSInteger)damperChannelIndex
{
    // compute the dampened effect if any
    CGFloat max = 1.0;
    if (damperChannelIndex != NSNotFound) {
        max = 1.0 - fabs([self.PWMPort pulseWidthForChannel:damperChannelIndex]);
        
        if (max < 0.0) {
            max = 0.0;
        }
    }
    
    switch (scale) {
        default:
        case BLKChannelScaleLinear:
            return value;

        case BLKChannelScaleDivideBy2:
            return value * max * 0.5;

        case BLKChannelScaleDivideBy3:
            return value * max / 3.0;

        case BLKChannelScaleDivideBy4:
            return value * max * 0.25;

        case BLKChannelScaleLogarithmic:
            if (value > 0) {
                if (value < 1.0) {
                    return -log(-value * max + 1.0)/6.0;
                } else {
                    return max * 1.0;
                }
            } else if (value < 0) {
                if (value > -1.0) {
                    return log(value * max + 1.0)/6.0;
                } else {
                    return - max * 1.0;
                }
            }
            return 0.0;
    }
}

- (void)applyJoystickPosition:(CGPoint)joystickCentre z:(CGFloat)zPosition toPort:(BLKPWMChannelsPort*)port
{
    CGFloat portValue;
    BOOL commit = NO;
    
    if (self.verticalChannel != NSNotFound) {
        if (isnan(joystickCentre.y)) {
            portValue = 0;
        } else {
            portValue = joystickCentre.y + self.verticalTrim;
            portValue = [self scaledValue:portValue
                         fromChannelScale:self.verticalScale
                         dampeningChannel:self.verticalDamperChannelIndex];
        }
        
        [port setPulseWidth:portValue forChannel:self.verticalChannel commit:NO];
        commit = YES;
    }
    
    if (self.horizontalChannel != NSNotFound) {
        if (isnan(joystickCentre.x)) {
            portValue = 0;
        } else {
            portValue = joystickCentre.x + self.horizontalTrim;
            portValue = [self scaledValue:portValue
                         fromChannelScale:self.horizontalScale
                         dampeningChannel:self.horizontalDamperChannelIndex];
        }
        
        [port setPulseWidth:portValue forChannel:self.horizontalChannel commit:NO];
        commit = YES;
    }
    
    if (self.zChannel != NSNotFound) {
        if (isnan(zPosition)) {
            portValue = 0;
        } else {
            portValue = 0; // TODO: joystick.wheelAngle + self.zTrim;
            portValue = [self scaledValue:portValue fromChannelScale:self.zScale dampeningChannel:NSNotFound];
        }
        
        [port setPulseWidth:portValue forChannel:self.zChannel commit:NO];
        commit = YES;
    }
    
    if (commit) {
        [port commit];
    }
}

#pragma mark - Actions

- (IBAction)joystickValueChanged:(BLKJoystick*)joystick
{
    [self applyJoystickPosition:joystick.joystickCentre
                              z:joystick.joystickWheelPosition
                         toPort:self.PWMPort];
}

- (IBAction)joystickDefaultValueChanged:(BLKJoystick*)joystick
{
    if (self.defaultsPWMPort) {
        [self applyJoystickPosition:CGPointMake(self.horizontalValueOnDisconnect, self.verticalValueOnDisconnect)
                                  z:self.zValueOnDisconnect
                             toPort:self.defaultsPWMPort];
    }
}

- (IBAction)apply:(id)sender
{
    [self joystickValueChanged:self.joystick];
    [self joystickDefaultValueChanged:self.joystick];
}

#pragma mark - Operations

- (void)observeAngle:(CGFloat)angle tilt:(CGFloat)tilt
{
    CGPoint position = CGPointMake(NAN, NAN);
    CGFloat roll     = NAN;

    if (self.horizontalTieToControllerAngle && !self.horizontalTieToControllerTilt) {
        position.x = angle/90;
    } else if (self.verticalTieToControllerAngle && !self.verticalTieToControllerTilt) {
        position.y = angle/90;
    } else if (self.zTieToControllerAngle && !self.zTieToControllerTilt) {
        roll = angle/90;
    }
    
    //TODO: Improve tilt to ensure screen is always visible
    tilt -= 45;
    if (self.horizontalTieToControllerTilt && !self.horizontalTieToControllerAngle) {
        position.x = tilt/45;
    } else if (self.verticalTieToControllerTilt && !self.verticalTieToControllerAngle) {
        position.y = -tilt/45;
    } else if (self.zTieToControllerTilt && !self.zTieToControllerAngle) {
        roll = tilt/45;
    }
    
    if (!isnan(position.x) || !isnan(position.y)) {
        [self.joystick moveStickToPosition:position];
    }
    
    if (!isnan(roll)) {
        [self.joystick turnWheelToAngle:roll];
    }
}

#pragma mark - BLKEditorViewControllerDelegate

- (UIViewController*)editor:(BLKEditorViewController *)editor settingsViewControllerForButtonPosition:(BLKEditorPosition)position
{
    BLKAxis axis;
    
    switch (position) {
        case BLKEditorPositionTopCentre:
            axis = BLKAxisY;
            break;
            
        case BLKEditorPositionRightCentre:
            axis = BLKAxisX;
            break;
            
        default:
            return nil;
    }

    BLKJoystickSettingsViewController* contentVC = [[BLKJoystickSettingsViewController alloc] initWithNibName:nil bundle:nil];
    contentVC.axis                   = axis;
    contentVC.joystickViewController = self;
    
    return contentVC;
}

@end
