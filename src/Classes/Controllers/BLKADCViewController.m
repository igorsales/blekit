//
//  BLKADCViewController.m
//  BLEKit
//
//  Created by Igor Sales on 2015-06-10.
//  Copyright (c) 2015 IgorSales.ca. All rights reserved.
//

#import "BLKADCViewController.h"
#import "BLKADCPort.h"
#import "BLKGaugeView.h"
#import "BLKADCSettingsViewController.h"
#import "BLKEditorViewController.h"
#import "BLKControl.h"

#import "CALayer+Borders.h"
#import "UINib+NibView.h"

@interface BLKADCViewController () <BLKEditorDelegate> {
}

@property (nonatomic, assign) NSTimeInterval timerPeriod;
@property (nonatomic, weak)   NSTimer* updateTimer;

@property (nonatomic, assign) CGFloat multiplier1;
@property (nonatomic, assign) CGFloat multiplier2;
@property (nonatomic, assign) CGFloat multiplier3;
@property (nonatomic, assign) CGFloat multiplier4;
@property (nonatomic, assign) CGFloat multiplier5;
@property (nonatomic, assign) CGFloat multiplier6;
@property (nonatomic, assign) CGFloat multiplier7;
@property (nonatomic, assign) CGFloat multiplier8;
@property (nonatomic, assign) CGFloat multiplier9;
@property (nonatomic, assign) CGFloat multiplier10;

@property (nonatomic, assign) CGFloat minimum1;
@property (nonatomic, assign) CGFloat minimum2;
@property (nonatomic, assign) CGFloat minimum3;
@property (nonatomic, assign) CGFloat minimum4;
@property (nonatomic, assign) CGFloat minimum5;
@property (nonatomic, assign) CGFloat minimum6;
@property (nonatomic, assign) CGFloat minimum7;
@property (nonatomic, assign) CGFloat minimum8;
@property (nonatomic, assign) CGFloat minimum9;
@property (nonatomic, assign) CGFloat minimum10;

@property (nonatomic, assign) CGFloat maximum1;
@property (nonatomic, assign) CGFloat maximum2;
@property (nonatomic, assign) CGFloat maximum3;
@property (nonatomic, assign) CGFloat maximum4;
@property (nonatomic, assign) CGFloat maximum5;
@property (nonatomic, assign) CGFloat maximum6;
@property (nonatomic, assign) CGFloat maximum7;
@property (nonatomic, assign) CGFloat maximum8;
@property (nonatomic, assign) CGFloat maximum9;
@property (nonatomic, assign) CGFloat maximum10;

@end

@implementation BLKADCViewController

#pragma mark - Setup/teardown

- (void)dealloc
{
    self.port = nil;
    [self unbindProperties];
}

#pragma mark - Accessors

@synthesize control = _control;
@synthesize port = _port;

- (void)setPort:(BLKPort*)port
{
    if (_port != port) {
        if (self.ADCPort) {
            [self.ADCPort removeObserver:self
                              forKeyPath:@"status"];
        }
        
        _port = port;
        [self adjustLayout];
        
        if (self.ADCPort) {
            [self.ADCPort addObserver:self
                           forKeyPath:@"status"
                              options:0
                              context:nil];
        }
    }
}

- (BLKADCPort*)ADCPort
{
    return (BLKADCPort*)self.port;
}

- (void)setTimerPeriod:(NSTimeInterval)timerPeriod
{
    if (_timerPeriod != timerPeriod) {
        _timerPeriod = timerPeriod;
        [self setupTimer];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareLabels];
    
    [self.view.layer setBorderWithTintColour:self.view.tintColor];
    
    [self bindProperties];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self updateGauges];
    [self setupTimer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self adjustLayout];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.updateTimer invalidate];
    self.updateTimer = nil;

    [super viewWillDisappear:animated];
}

- (void)bindProperties
{
    [self.control bindTo:self.view properties:@[@"frame"]];
    
    [self.control applyProperties:@[@"timerPeriod"] to:self];
    if (self.timerPeriod <= 0) {
        self.timerPeriod = 1.0;
    }
    
    [self.control bindTo:self properties:@[@"timerPeriod"]];

    for (NSInteger index = 1; index <= 10; index++) {
        NSString* minimumKey    = [NSString stringWithFormat:@"minimum%ld", (long)index];
        NSString* maximumKey    = [NSString stringWithFormat:@"maximum%ld", (long)index];
        NSString* multiplierKey = [NSString stringWithFormat:@"multiplier%ld", (long)index];

        NSArray* properties = @[minimumKey, maximumKey, multiplierKey];
        [self.control applyProperties:properties to:self];
        [self.control bindTo:self properties:properties];

        // Set defaults, if not yet set
        CGFloat min = [[self valueForKey:minimumKey] doubleValue];
        CGFloat max = [[self valueForKey:maximumKey] doubleValue];
        CGFloat mul = [[self valueForKey:multiplierKey] doubleValue];
        
        if (max <= min) {
            [self setValue:@(0) forKey:minimumKey];
            [self setValue:@(3.3) forKey:maximumKey];
        }
        
        if (mul <= 0.0) {
            [self setValue:@(1.0) forKey:multiplierKey];
        }
    }
}

- (void)unbindProperties
{
    [self.control unbindProperties:@[@"frame"] from:self.view];
    
    [self.control unbindProperties:@[@"timerPeriod"] from:self];

    for (NSInteger index = 1; index <= 10; index++) {
        NSString* minimumKey    = [NSString stringWithFormat:@"minimum%ld", (long)index];
        NSString* maximumKey    = [NSString stringWithFormat:@"maximum%ld", (long)index];
        NSString* multiplierKey = [NSString stringWithFormat:@"multiplier%ld", (long)index];
        [self.control unbindProperties:@[minimumKey, maximumKey, multiplierKey] from:self];
    }
}

#pragma mark - Private

- (void)setupTimer
{
    [self.updateTimer invalidate];

    if (self.isViewLoaded && self.view.window) {
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:self.timerPeriod
                                                            target:self
                                                          selector:@selector(updateTimerFired:)
                                                          userInfo:nil
                                                           repeats:YES];
    }
}

- (void)prepareLabels
{
    self.minLabel.text = @"  0";
    self.maxLabel.text = @"100";
}

- (void)getMinimum:(CGFloat*)min maximum:(CGFloat*)max multiplier:(CGFloat*)multiplier atIndex:(NSInteger)index
{
    if (index < 1 || index > 10) {
        return;
    }

    if (min) {
        NSString* minimumKey    = [NSString stringWithFormat:@"minimum%ld", (long)index];
        *min = [[self valueForKey:minimumKey] doubleValue];
    }
    
    if (max) {
        NSString* maximumKey    = [NSString stringWithFormat:@"maximum%ld", (long)index];
        *max = [[self valueForKey:maximumKey] doubleValue];
    }

    if (multiplier) {
        NSString* multiplierKey = [NSString stringWithFormat:@"multiplier%ld", (long)index];
        *multiplier = [[self valueForKey:multiplierKey] doubleValue];
    }
}

- (void)adjustLayout
{
    [[self.gaugesView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

    CGRect frame = self.gaugesView.frame;
    if (self.ADCPort.numberOfPins > 0) {
        frame.size.width = 39.0 * self.ADCPort.numberOfPins + (self.ADCPort.numberOfPins - 1) * 3.0; // 3 == padding
    } else {
        frame.size.width = 39.0;
    }
    self.gaugesView.frame = frame;
    
    CGFloat x = 0;
    for (NSInteger idx = 0; idx < self.ADCPort.numberOfPins; idx++) {
        BLKGaugeView* gaugeView = (BLKGaugeView*)[UINib viewFromNibNamed:@"BLKGaugeView" bundle:[NSBundle bundleForClass:self.class]];
        [gaugeView.layer setBorderWithTintColour:[gaugeView.fillColor colorWithAlphaComponent:0.83]];
        
        CGFloat min, max, mult;
        [self getMinimum:&min maximum:&max multiplier:&mult atIndex:idx + 1];
        
        gaugeView.minimumValue = min;
        gaugeView.maximumValue = max;

        frame = gaugeView.frame;
        frame.origin.x = x;
        gaugeView.frame = frame;
        
        [self.gaugesView addSubview:gaugeView];
        
        x = gaugeView.frame.size.width + 3.0;
    }
    
    frame = self.view.frame;
    frame.size.width = self.gaugesView.frame.origin.x + self.gaugesView.frame.size.width + 8.0; // margin
    self.view.frame = frame;
}

- (void)updateGauges
{
    for (NSInteger idx = 0; idx < self.ADCPort.numberOfPins; idx++) {
        SInt16 reading = [self.ADCPort readingForPin:idx];
        
        BLKGaugeView* gaugeView = self.gaugesView.subviews[idx];
        
        CGFloat mult = 1.0;
        [self getMinimum:nil maximum:nil multiplier:&mult atIndex:idx+1];
        
        gaugeView.value = (3.3/(1 << 15)) * reading * mult;
    }
}

- (void)updateTimerFired:(NSTimer*)timer
{
    [self.ADCPort read];
}

#pragma mark - BLKEditorDelegate

- (UIViewController*)editor:(BLKEditorViewController*)editor settingsViewControllerForButtonPosition:(BLKEditorPosition)position
{
    if (position != BLKEditorPositionBottomCentre) {
        return nil;
    }
    
    BLKADCSettingsViewController* contentVC = [[BLKADCSettingsViewController alloc] initWithNibName:nil bundle:nil];
    contentVC.ADCViewController = self;
    
    return contentVC;
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.ADCPort && [keyPath isEqualToString:@"status"]) {
        [self updateGauges];
    }
}

@end
