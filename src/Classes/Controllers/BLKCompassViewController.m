//
//  BLKCompassViewController.m
//  BLEKit
//
//  Created by Igor Sales on 2014-10-30.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKCompassViewController.h"
#import "BLKI2CControlPort.h"
#import "BLKSTLIS3MDLDriver.h"
#import "BLKCompassView.h"
#import "BLKControl.h"


typedef enum {
    BLKCompassStateIdle,
    BLKCompassStateConfiguring,
    BLKCompassStateReading
} BLKCompassState;

@interface BLKCompassViewController () <BLKSTLIS3MDLDriverDelegate> {
    CGFloat _min_x, _min_y, _min_z;
    CGFloat _max_x, _max_y, _max_z;
    BOOL _justStarted;
    BOOL    _angles[359];
    NSInteger _angleCount;
    NSInteger _sampleCount;
    
    CGFloat _offset_x, _offset_y, _offset_z;
    CGFloat _scale_x,  _scale_y,  _scale_z;
}

@property (nonatomic, assign) CGFloat offsetX;
@property (nonatomic, assign) CGFloat offsetY;
@property (nonatomic, assign) CGFloat offsetZ;

@property (nonatomic, assign) CGFloat scaleX;
@property (nonatomic, assign) CGFloat scaleY;
@property (nonatomic, assign) CGFloat scaleZ;

@property (nonatomic, strong) BLKSTLIS3MDLDriver* driver;
@property (nonatomic, assign) BLKCompassState state;

@property (nonatomic, assign) CGFloat gain;

@property (nonatomic, assign) BOOL isCalibrating;
@property (nonatomic, assign) BOOL calibrated;

- (void)start;
- (void)stop;

@end

@implementation BLKCompassViewController

@synthesize control = _control;
@synthesize port = _port;
@synthesize isCalibrating = _calibrating;

@synthesize offsetX = _offset_x;
@synthesize offsetY = _offset_y;
@synthesize offsetZ = _offset_z;
@synthesize scaleX  = _scale_x;
@synthesize scaleY  = _scale_y;
@synthesize scaleZ  = _scale_z;

- (void)setIsCalibrating:(BOOL)calibrating
{
    if (_calibrating != calibrating) {
        _calibrating = calibrating;
        
        if (_calibrating) {
            _justStarted = YES;
            memset(_angles, 0, sizeof(_angles));
            _angleCount = 0;
            _sampleCount = 0;
            _min_x = _min_y = _min_z = _max_x = _max_y = _max_z;
            _offset_x = _offset_y = _offset_z = 0;
            _scale_x = _scale_y = _scale_z = 1.0;
        }
    }
}

- (BLKI2CControlPort*)I2CPort
{
    return (BLKI2CControlPort*)self.port;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.driver = [BLKSTLIS3MDLDriver new];
    self.driver.slaveAddress = 0x38;
    self.driver.delegate = self;
    self.gain = 4.0;
    
    /*self.view.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.view.layer.shadowRadius = 3.0;
    self.view.layer.shadowOpacity = 0.6;
    self.view.layer.masksToBounds = NO;
    self.view.layer.shadowOffset = CGSizeZero;*/
    
    self.compassView.backgroundColor = [UIColor lightTextColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.control applyProperties:@[ @"calibrated", @"offsetX", @"offsetY", @"offsetZ", @"scaleX", @"scaleY", @"scaleZ" ] to:self];
    [self.control bindTo:self.view properties:@[@"frame"]];
    [self.control bindTo:self properties:@[ @"calibrated", @"offsetX", @"offsetY", @"offsetZ", @"scaleX", @"scaleY", @"scaleZ" ]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.control unbindProperties:@[@"frame"] from:self.view];
    [self.control unbindProperties:@[ @"calibrated", @"offsetX", @"offsetY", @"offsetZ", @"scaleX", @"scaleY", @"scaleZ" ] from:self];
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

- (void)addX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z toCalibrationWithAngle:(CGFloat)angle;
{
    if (_justStarted) {
        _justStarted = NO;
        _min_x = _max_x = x;
        _min_y = _max_y = y;
        _min_z = _max_z = z;
        _sampleCount++;
        return;
    }

    if (x < _min_x) _min_x = x;
    if (y < _min_y) _min_y = y;
    if (z < _min_z) _min_z = z;
    
    if (x > _max_x) _max_x = x;
    if (y > _max_y) _max_y = y;
    if (z > _max_z) _max_z = z;
    
    if (!_angles[(int)angle % 360]) {
        _angles[(int)angle % 360] = YES;
        _angleCount++;
    }
    
    _sampleCount++;
    
    if (_angleCount >= 360 || _sampleCount > 750) {
        [self calibrate];
    }
}

- (void)calibrate
{
    [self willChangeValueForKey:@"offsetX"];
    [self willChangeValueForKey:@"offsetY"];
    [self willChangeValueForKey:@"offsetZ"];
    [self willChangeValueForKey:@"scaleX"];
    [self willChangeValueForKey:@"scaleY"];
    [self willChangeValueForKey:@"scaleZ"];

    _offset_x = (_min_x + _max_x) / 2.0;
    _offset_y = (_min_y + _max_y) / 2.0;
    _offset_z = (_min_z + _max_z) / 2.0;
    
    CGFloat min_x = _min_x - _offset_x;
    CGFloat min_y = _min_y - _offset_y;
    CGFloat min_z = _min_z - _offset_z;
    
    CGFloat max_x = _max_x - _offset_x;
    CGFloat max_y = _max_y - _offset_y;
    CGFloat max_z = _max_z - _offset_z;
    
    CGFloat avg_x = (max_x - min_x) / 2.0;
    CGFloat avg_y = (max_y - min_y) / 2.0;
    CGFloat avg_z = (max_z - min_z) / 2.0;
    
    CGFloat avg_rad = (avg_x + avg_y + avg_z)/3.0;
    
    _scale_x = avg_rad / avg_x;
    _scale_y = avg_rad / avg_y;
    _scale_z = avg_rad / avg_z;

    [self didChangeValueForKey:@"offsetX"];
    [self didChangeValueForKey:@"offsetY"];
    [self didChangeValueForKey:@"offsetZ"];
    [self didChangeValueForKey:@"scaleX"];
    [self didChangeValueForKey:@"scaleY"];
    [self didChangeValueForKey:@"scaleZ"];

    self.isCalibrating = NO;
    self.calibrated = YES;
    
    if ([self.parentViewController respondsToSelector:@selector(saveConfiguration:)]) {
        [(id<BLKConfigurationDelegate>)self.parentViewController saveConfiguration:self];
    }
}

- (void)configure
{
    self.state = BLKCompassStateConfiguring;
    [self.driver setXAndYAxisPowerOperatingMode:BLKSTLIS3MDLDriverUltraHighPerformanceMode];
    [self.driver setZAxisPowerOperatingMode:BLKSTLIS3MDLDriverUltraHighPerformanceMode];
    [self.driver setDataRate:BLKSTLIS3MDLDriverOutputDataRate80Hz];
    [self.driver setOperatingMode:BLKSTLIS3MDLDriverOperatingModeContinuous];
    [self.driver setBlockDataUpdate:YES];
}

- (void)read
{
    self.state = BLKCompassStateReading;
    [self.driver readAxisData];
}

#pragma mark - BLKSTLIS3MDLDriverDelegate

- (void)driver:(BLKSTLIS3MDLDriver *)driver axisDataX:(int16_t)x Y:(int16_t)y Z:(int16_t)z
{
    CGFloat gain = self.gain;
    CGPoint reading = CGPointMake(-gain*x/32767.0, gain*y/32767.0);
    CGFloat reading_z = gain*z/32767.0;
    CGFloat l = 0;
    
    if (!self.isCalibrating) {
        reading.x = (reading.x - _offset_x) * _scale_x;
        reading.y = (reading.y - _offset_y) * _scale_y;
        reading_z = (reading_z - _offset_z) * _scale_z;
        
        l = sqrt(reading.x * reading.x + reading.y * reading.y + reading_z * reading_z);
    }
    
    CGFloat angle;
    if (reading.y > 0) {
        angle = 90 - atan(reading.x/reading.y)*180/M_PI;
    } else if (reading.y < 0) {
        angle = 270 - atan(reading.x/reading.y)*180/M_PI;
    } else {
        if (reading.x < 0) {
            angle = 180;
        } else {
            angle = 0;
        }
    }
    
    if (self.isCalibrating) {
        [self addX:reading.x Y:reading.y Z:reading_z toCalibrationWithAngle:angle];
    }
    
    if (l >= 0.25 || l <= 0.65) {
        self.compassView.bearings = reading;
    }
    
    // call read with a delay to avoid a block cycle
    [self performSelector:@selector(read) withObject:nil afterDelay:0];
}

- (void)driverReadFailed:(BLKSTLIS3MDLDriver *)driver
{
}

- (void)driverWriteFailed:(BLKSTLIS3MDLDriver *)driver
{
}

- (void)driverFinishedSelectorSuccessfully:(SEL)sel
{
    if (sel == @selector(setBlockDataUpdate:)) {
        self.isCalibrating = !self.calibrated;
        [self read];
    }
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
