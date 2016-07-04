//
//  BLKI2CViewController.m
//  BLEKit
//
//  Created by Igor Sales on 2014-10-07.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKI2CViewController.h"
#import "BLKI2CControlPort.h"
#import "BLKControl.h"

@interface BLKI2CViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@end

@implementation BLKI2CViewController

@synthesize control = _control;
@synthesize port = _port;

- (BLKI2CControlPort*)I2CPort
{
    return (BLKI2CControlPort*)self.port;
}

- (NSInteger)length
{
    return [self.lengthPicker selectedRowInComponent:0] + 1;
}

- (NSInteger)slaveAddress
{
    return ([self.slaveAddressPicker selectedRowInComponent:0] << 4) + [self.slaveAddressPicker selectedRowInComponent:1];
}

- (NSInteger)registerAddress
{
    return ([self.regAddressPicker selectedRowInComponent:0] << 4) + [self.regAddressPicker selectedRowInComponent:1];
}

- (void)setHex:(NSData*)data
{
    NSMutableString* hex = [NSMutableString new];
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        const unsigned char* ptr = bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            [hex appendFormat:@"%02X ", ptr[i]];
        }
    }];
    
    self.hexTextField.text = hex;
}

- (NSData*)hexData
{
    NSMutableData* data = [NSMutableData data];

    NSScanner* scanner = [NSScanner scannerWithString:self.hexTextField.text];
    unsigned int hexValue = 0;
    while ([scanner scanHexInt:&hexValue]) {
        [data appendBytes:&hexValue length:1];
    }
    
    return data;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    for (UIButton* button in self.digitButtons) {
        button.layer.cornerRadius = 4.0;
        button.layer.borderWidth  = 1.0;
        button.layer.borderColor  = [button titleColorForState:UIControlStateNormal].CGColor;
    }
    
    self.view.layer.borderColor  = [self.view.tintColor colorWithAlphaComponent:0.73].CGColor;
    self.view.layer.borderWidth  = 1.0;
    self.view.layer.cornerRadius = 8.0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.control bindTo:self.view properties:@[@"frame"]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.control unbindProperties:@[@"frame"] from:self.view];

    [super viewWillDisappear:animated];
}

- (IBAction)readTapped:(id)sender
{
    self.I2CPort.useStopCondition = self.stopSwitch.on;
    [self.I2CPort readBytes:self.length
           fromSlaveAddress:self.slaveAddress
         andRegisterAddress:self.registerAddress
                 completion:^(NSData *data) {
                     [self setHex:data];
                 }
                    failure:^{
                        self.hexTextField.text = @"READ FAILED!";
                    }];
}

- (IBAction)writeTapped:(id)sender
{
    self.I2CPort.useStopCondition = self.stopSwitch.on;
    [self.I2CPort writeBytes:self.hexData
              toSlaveAddress:self.slaveAddress
          andRegisterAddress:self.registerAddress
                  completion:^(NSInteger written) {
                      NSLog(@"WRITE worked %d", (int)written);
                  }
                     failure:^{
                         self.hexTextField.text = @"WRITE FAILED!";
                     }];
}

- (IBAction)hexDigitTapped:(id)sender
{
    NSInteger digit = [sender tag];
    
    NSString* hex = self.hexTextField.text;
    if (hex.length % 3 == 1) {
        hex = [hex stringByAppendingFormat:@"%X ", (int)digit];
    } else {
        hex = [hex stringByAppendingFormat:@"%X", (int)digit];
    }

    self.hexTextField.text = hex;
}

- (IBAction)delTapped:(id)sender
{
    NSString* hex = self.hexTextField.text;
    
    if (hex.length == 0) {
        return;
    }
    
    if (hex.length % 3 == 1) {
        hex = [hex substringToIndex:hex.length - 1];
    } else if (hex.length > 2) {
        hex = [hex substringToIndex:hex.length - 2];
    }
    
    self.hexTextField.text = hex;
}

- (IBAction)clearTapped:(id)sender
{
    self.hexTextField.text = @"";
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView == self.lengthPicker) {
        return 1;
    }

    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == self.lengthPicker) {
        return 16;
    }
    
    return 16;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (self.lengthPicker == pickerView) {
        return [NSString stringWithFormat:@"%d", (int)row+1];
    }

    return [NSString stringWithFormat:@"%x", (int)row];
}

@end
