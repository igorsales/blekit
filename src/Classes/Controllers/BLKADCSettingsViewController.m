//
//  BLKADCSettingsViewController.m
//  BLEKit
//
//  Created by Igor Sales on 2015-06-21.
//  Copyright (c) 2015 IgorSales.ca. All rights reserved.
//

#import "BLKEditorViewController.h"
#import "BLKADCSettingsViewController.h"
#import "BLKADCViewController.h"
#import "BLKSliderCell.h"
#import "BLKADCPort.h"

#import "UINib+NibView.h"
#import "NSIndexPath+Tag.h"

@interface BLKADCSettingsViewController () <BLKEditorDataSource>

@property (nonatomic, strong) NSArray* specs;
@property (nonatomic, assign) NSInteger currentADC;

@end

@implementation BLKADCSettingsViewController

@synthesize specs = _specs;

- (NSArray*)specs
{
    if (!_specs) {
        _specs = @[
                   // Section 1
                   @[
                       @{ @"label": @"Update period",
                          @"reuseId": @"BLKSliderCell",
                          @"key": @"timerPeriod",
                          @"min": @(0.1),
                          @"max": @(5.0),
                        }
                    ],

                   // Section 2
                   @[
                       @{ @"label": @"Choose ADC",
                          @"labelFormat": @"ADC %d",
                          @"reuseId": @"BLKADCCell"
                        }
                    ],
                   
                   // Section 3: Multiplier
                   @[
                       @{
                           @"label":     @"Multiplier",
                           @"reuseId":   @"BLKSliderCell",
                           @"keyPrefix": @"multiplier",
                           @"min":       @(0.01),
                           @"max":       @(16.0)
                        }
                    ],
                   
                    // Section 4: Minimum
                    @[
                       @{
                           @"label":     @"Minimum",
                           @"reuseId":   @"BLKSliderCell",
                           @"keyPrefix": @"minimum",
                           @"min":       @(0.0),
                           @"max":       @(25.0)
                        }
                     ],
                   
                    // Section 5: Maximum
                    @[
                       @{
                           @"label":     @"Maximum",
                           @"reuseId":   @"BLKSliderCell",
                           @"keyPrefix": @"maximum",
                           @"min":       @(0.0),
                           @"max":       @(25.0)
                        }
                    ]
                   ];
    }

    return _specs;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.specs.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 1: return self.ADCViewController.ADCPort.numberOfPins;
            
        default: return [self.specs[section] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    BLKSliderCell* sliderCell = nil;
    NSDictionary* spec = nil;
    NSString* reuseId = nil;
    NSString* key = nil;

    switch (indexPath.section) {
        case 1:
            spec = self.specs[indexPath.section][0];
            cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
            }
            
            cell.textLabel.text = [NSString stringWithFormat:spec[@"labelFormat"], indexPath.row + 1];
            cell.accessoryType = self.currentADC == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
            
        default:
            spec = self.specs[indexPath.section][indexPath.row];
            reuseId = spec[@"reuseId"];
            cell = sliderCell = [tableView dequeueReusableCellWithIdentifier:reuseId];
            if (!cell) {
                cell = sliderCell = (BLKSliderCell*)[UINib viewFromNibNamed:reuseId bundle:[NSBundle bundleForClass:[self class]]];
                [sliderCell.resetButton removeFromSuperview];
                sliderCell.readingLabel.hidden = NO;
                [sliderCell.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
                [sliderCell.minusButton addTarget:self action:@selector(minusButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                [sliderCell.plusButton addTarget:self action:@selector(plusButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                sliderCell.slider.tag = sliderCell.minusButton.tag = sliderCell.plusButton.tag = indexPath.tag;
            }
            
            sliderCell.slider.minimumValue = [spec[@"min"] doubleValue];
            sliderCell.slider.maximumValue = [spec[@"max"] doubleValue];
            
            key = spec[@"key"];
            if (!key) {
                key = [NSString stringWithFormat:@"%@%@", spec[@"keyPrefix"], @(self.currentADC + 1)];
            }
            sliderCell.slider.value = [[self.ADCViewController valueForKey:key] doubleValue];

            [self updateSliderReadingLabel:sliderCell];
            break;
    }

    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary* spec = self.specs[section][0];
    NSString* label = NSLocalizedString(spec[@"label"], nil);
    
    return label;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 1:
            self.currentADC = indexPath.row;
            [self.tableView reloadData];
            break;
            
        default:
            break;
    }
}

#pragma mark - Private

- (void)updateSliderReadingLabel:(BLKSliderCell*)sliderCell
{
    sliderCell.readingLabel.text = [NSString stringWithFormat:@"%.2f", sliderCell.slider.value];
}

- (void)updateValueAtIndexPath:(NSIndexPath*)indexPath fromSlider:(UISlider*)slider
{
    NSDictionary* spec = self.specs[indexPath.section][indexPath.row];
    
    NSString* key = spec[@"key"];
    if (!key) {
        key = [NSString stringWithFormat:@"%@%@", spec[@"keyPrefix"], @(self.currentADC + 1)];
    }

    [self.ADCViewController setValue:@(slider.value) forKey:key];
}

#pragma mark - Actions

- (IBAction)sliderValueChanged:(UISlider*)sender
{
    NSIndexPath* indexPath = [NSIndexPath indexPathFromTag:sender.tag];

    BLKSliderCell* sliderCell = (BLKSliderCell*)[self.tableView cellForRowAtIndexPath:indexPath];

    [self updateSliderReadingLabel:sliderCell];
    [self updateValueAtIndexPath:indexPath fromSlider:sender];
}

- (IBAction)minusButtonTapped:(UIButton*)sender
{
    NSIndexPath* indexPath = [NSIndexPath indexPathFromTag:sender.tag];
    BLKSliderCell* sliderCell = (BLKSliderCell*)[self.tableView cellForRowAtIndexPath:indexPath];

    sliderCell.slider.value = sliderCell.slider.value - 0.01;
    [self updateSliderReadingLabel:sliderCell];
    [self updateValueAtIndexPath:indexPath fromSlider:sliderCell.slider];
}

- (IBAction)plusButtonTapped:(UIButton*)sender
{
    NSIndexPath* indexPath = [NSIndexPath indexPathFromTag:sender.tag];
    BLKSliderCell* sliderCell = (BLKSliderCell*)[self.tableView cellForRowAtIndexPath:indexPath];

    sliderCell.slider.value = sliderCell.slider.value + 0.01;
    [self updateSliderReadingLabel:sliderCell];
    [self updateValueAtIndexPath:indexPath fromSlider:sliderCell.slider];
}

#pragma mark - BLKEditorDataSource

- (NSString*)editor:(BLKEditorViewController*)editor titleForSettingsButtonAtPosition:(BLKEditorPosition)position
{
    if (position == BLKEditorPositionBottomCentre) {
        return NSLocalizedString(@"Settings", nil);
    }

    return nil;
}

@end
