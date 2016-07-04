//
//  BLKGyroscopeViewController.m
//  BLEKit
//
//  Created by Igor Sales on 2014-11-13.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKGyroscopeViewController.h"
#import "BLKI2CControlPort.h"
#import "BLKSTLSM330GyroDriver.h"
#import "BLKGyroscopeView.h"
#import "BLKControl.h"
#import <QuartzCore/QuartzCore.h>

@interface BLKGyroscopeViewController () <BLKSTLSM330GyroDriverDelegate>

@property (nonatomic, assign) CGFloat gain;
@property (nonatomic, strong) BLKSTLSM330GyroDriver* driver;

@end

@implementation BLKGyroscopeViewController

@synthesize control = _control;
@synthesize port = _port;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.layer.borderColor = [self.view.tintColor colorWithAlphaComponent:0.73].CGColor;
    self.view.layer.borderWidth = 1.0;
    self.view.layer.cornerRadius = 8.0;

    self.driver = [BLKSTLSM330GyroDriver new];
    self.driver.slaveAddress = 0xD4;
    self.driver.delegate = self;
    self.gain = 250.0;
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
    [self.driver setOperatingMode:BLKSTLSM330GyroDriverODR_190Hz_Cutoff_12_5Hz];
    [self read];
}

- (void)read
{
    [self.driver readAxisData];
}

#pragma mark - BLKSTLSM330AccelDriverDelegate

- (void)driver:(BLKSTLSM330GyroDriver*)driver axisDataX:(int16_t)x Y:(int16_t)y Z:(int16_t)z
{
    CGFloat gain = self.gain;
    CGPoint reading = CGPointMake(-gain*x/32767.0, gain*y/32767.0);
    CGFloat reading_z = gain*z/32767.0;
    
    self.gyroView.xy = reading;
    self.gyroView.z  = reading_z;
    
    [self performSelector:@selector(read) withObject:nil afterDelay:1.0/12.5];
}

- (void)driverReadFailed:(BLKSTLSM330GyroDriver *)driver
{
    
}

- (void)driverWriteFailed:(BLKSTLSM330GyroDriver *)driver
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
