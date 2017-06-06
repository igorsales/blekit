//
//  BLKGPOutputsViewController.m
//  BLEKit
//
//  Created by Igor Sales on 2015-05-15.
//  Copyright (c) 2015 IgorSales.ca. All rights reserved.
//

#import "BLKGPIOsViewController.h"
#import "BLKControl.h"
#import "BLKGPIOPort.h"
#import "BLKLEDView.h"

#import "CALayer+Borders.h"
#import "UINib+NibView.h"

#define kBLKBorderWidth (8.0)

@interface BLKGPIOsViewController ()

@end

@implementation BLKGPIOsViewController

#pragma mark - Setup/teardown

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    // Overwrite the nibName to always catch the same XIB file
    if ((self = [super initWithNibName:@"BLKGPIOsViewController" bundle:nibBundleOrNil])) {
        
    }

    return self;
}

- (void)dealloc
{
    _port = nil;
    [self unbindProperties];
}

#pragma mark - Accessors

@synthesize control = _control;
@synthesize port = _port;

- (void)setPort:(BLKPort*)port
{
    if (_port != port) {
        if (self.GPIOPort.canNotify) {
            [self.GPIOPort removeObserver:self
                               forKeyPath:@"status"];
        }
        
        _port = port;
        [self adjustLayout];
        
        if (self.GPIOPort.canNotify) {
            [self.GPIOPort addObserver:self
                            forKeyPath:@"status"
                               options:0
                               context:nil];
        }
    }
}

- (BLKGPIOPort*)GPIOPort
{
    return (BLKGPIOPort*)self.port;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self adjustLayout];

    [self.view.layer setBorderWithTintColour:self.view.tintColor];
    
    [self bindProperties];
}

- (void)bindProperties
{
    [self.control bindTo:self.view properties:@[@"frame"]];
}

- (void)unbindProperties
{
    [self.control unbindProperties:@[@"frame"] from:self.view];
}

#pragma mark - Actions

- (IBAction)LEDViewTapped:(BLKLEDView*)sender
{
    [self.view.subviews[sender.tag] toggle];
    
    NSInteger mask = 1 << sender.tag;
    NSInteger bits = sender.on ? mask : 0;
    [self.GPIOPort write:bits mask:mask commit:YES];
}

#pragma mark - Private

- (void)adjustLayout
{
    CGRect bounds = self.view.bounds;

    bounds.size.width = 2 * kBLKBorderWidth + self.GPIOPort.numberOfPins * 32.0;
    
    self.view.bounds = bounds;
    
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger nbrOfPins = self.GPIOPort.numberOfPins;
    if (nbrOfPins <= 0) {
        nbrOfPins = 2;
    }
    
    CGFloat x = kBLKBorderWidth;
    for (NSInteger idx = 0; idx < nbrOfPins; idx++) {
        BLKLEDView* LEDView = (BLKLEDView*)[UINib viewFromNibNamed:@"BLKLEDView" bundle:[NSBundle bundleForClass:[self class]]];
        
        CGRect frame = LEDView.frame;
        frame.origin.x = x;
        frame.origin.y = kBLKBorderWidth;
        LEDView.frame = frame;
        
        LEDView.number = idx + 1;
        LEDView.tag    = idx;
        
        if (self.GPIOPort.canWrite || [self isKindOfClass:[BLKGPOutputsViewController class]]) {
            [LEDView addTarget:self action:@selector(LEDViewTapped:) forControlEvents:UIControlEventTouchUpInside];
        } else if (self.GPIOPort.canRead || self.GPIOPort.canNotify || [self isKindOfClass:[BLKGPInputsViewController class]]) {
            LEDView.LEDColour = [UIColor redColor];
        } else {
            LEDView.LEDColour = [UIColor whiteColor];
        }
        
        [self.view addSubview:LEDView];
        
        x = x + frame.size.width;
    }
}

- (void)updateLEDs
{
    [self.view.subviews enumerateObjectsUsingBlock:^(BLKLEDView* LEDView, NSUInteger idx, BOOL *stop) {
        LEDView.on = (self.GPIOPort.status & (1 << idx));
    }];
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.GPIOPort && [keyPath isEqualToString:@"status"]) {
        [self updateLEDs];
    }
}

@end


@implementation BLKGPInputsViewController

@end


@implementation BLKGPOutputsViewController

@end
