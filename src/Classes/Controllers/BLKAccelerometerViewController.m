//
//  BLKAccelerometerViewController.m
//  BLEKit
//
//  Created by Igor Sales on 2014-11-13.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKAccelerometerViewController.h"
#import "BLKI2CControlPort.h"
#import "BLKSTLSM330AccelDriver.h"
#import "BLKAccelerometerView.h"
#import "BLKControl.h"
#import <QuartzCore/QuartzCore.h>

@interface BLKAccelerometerViewController () <BLKSTLSM330AccelDriverDelegate>

@property (nonatomic, assign) CGFloat gain;
@property (nonatomic, strong) BLKSTLSM330AccelDriver* driver;

@end

@implementation BLKAccelerometerViewController

@synthesize control = _control;
@synthesize port = _port;

- (BLKI2CControlPort*)I2CPort
{
    return (BLKI2CControlPort*)self.port;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.layer.borderColor = [self.view.tintColor colorWithAlphaComponent:0.73].CGColor;
    self.view.layer.borderWidth = 1.0;
    self.view.layer.cornerRadius = 8.0;

    self.driver = [BLKSTLSM330AccelDriver new];
    self.driver.slaveAddress = 0x3C;
    self.driver.delegate = self;
    self.gain = 2.0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.control bindTo:self.view properties:@[@"frame"]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.control unbindProperties:@[@"frame"] from:self.view];
    [self stop];

    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.driver.port = self.port;
    [self start];
}

#pragma mark - Private

- (void)configure
{
    [self.driver setOperatingMode:BLKSTLSM330AccelDriverOutputDataRate12_5Hz];
    [self read];
}

- (void)read
{
    [self.driver readAxisData];
}

#pragma mark - BLKSTLSM330AccelDriverDelegate

- (void)driver:(BLKSTLSM330AccelDriver*)driver axisDataX:(int16_t)x Y:(int16_t)y Z:(int16_t)z
{
    CGFloat gain = self.gain;
    CGPoint reading = CGPointMake(-gain*x/32767.0, gain*y/32767.0);
    CGFloat reading_z = gain*z/32767.0;
    
    self.accelView.xy = reading;
    self.accelView.z  = reading_z;

    [self performSelector:@selector(read) withObject:nil afterDelay:1.0/12.5];
}

- (void)driverReadFailed:(BLKSTLSM330AccelDriver *)driver
{
    
}

- (void)driverWriteFailed:(BLKSTLSM330AccelDriver *)driver
{
    
}

#pragma mark - Operations

- (void)start
{
    // Set compass into Continuous conversion mode
    [self configure];
}

- (void)stop
{
}


@end
