//
//  BLKPWMSliderViewController.m
//  BLEKit
//
//  Created by Igor Sales on 2015-05-15.
//  Copyright (c) 2015 IgorSales.ca. All rights reserved.
//

#import "BLKPWMSliderViewController.h"
#import "BLKPWMSliderSettingsViewController.h"
#import "BLKPWMChannelsPort.h"
#import "BLKEditorViewController.h"
#import "BLKControl.h"
#import "CALayer+Borders.h"

#import <QuartzCore/QuartzCore.h>

@interface BLKPWMSliderViewController () <BLKEditorDelegate>

@end

@implementation BLKPWMSliderViewController

#pragma mark - Setup/teardown

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        self.channel = NSNotFound;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.channel = NSNotFound;
    }
    
    return self;
}

- (void)dealloc
{
    [self unbindProperties];
}


#pragma mark - Accessors

@synthesize control = _control;
@synthesize port = _port;
@synthesize defaultsPWMPort = _defaultsPWMPort;

- (BLKPWMChannelsPort*)PWMPort
{
    return (BLKPWMChannelsPort*)self.port;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view.layer setBorderWithTintColour:self.view.tintColor];

    self.slider.minimumValue = 0;
    self.slider.maximumValue = 1000000 * 1.0/60.0;
    self.slider.value        = (self.slider.minimumValue + self.slider.maximumValue) / 2;

    [self bindProperties];
}

- (void)bindProperties
{
    [self.control applyProperties:@[@"frame"]
                               to:self.view];
    [self.control applyProperties:@[@"channel"]
                               to:self];

    [self.control bindTo:self properties:@[@"channel"]];
    [self.control bindTo:self.view properties:@[@"frame"]];
}

- (void)unbindProperties
{
    [self.control unbindProperties:@[@"channel"] from:self];
    [self.control unbindProperties:@[@"frame"] from:self.view];
}

#pragma mark - Actions

- (IBAction)sliderValueChanged:(id)sender
{
    CGFloat portValue;
    BOOL commit = NO;
    
    if (self.channel != NSNotFound) {
        portValue = self.slider.value;
        
        [self.PWMPort setRawPulseWidth:portValue forChannel:self.channel];
        commit = YES;
    }

    if (commit) {
        [self.PWMPort commit];
    }
}

#pragma mark - BLKEditorViewControllerDelegate

- (UIViewController*)editor:(BLKEditorViewController*)editor settingsViewControllerForButtonPosition:(BLKEditorPosition)position
{
    BLKPWMSliderSettingsViewController* contentVC = nil;
    switch (position) {
        case BLKEditorPositionTopCentre:
            contentVC = [[BLKPWMSliderSettingsViewController alloc] initWithNibName:nil bundle:nil];
            contentVC.PWMSliderViewController = self;
            break;

        default:
            break;
    }

    return contentVC;
}

@end
