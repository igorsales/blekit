//
//  BLKJoystickSettingsViewController.m
//  BLEKit
//
//  Created by Igor Sales on 2014-10-21.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKJoystickSettingsViewController.h"
#import "BLKEditorViewController.h"
#import "BLKJoystickViewController.h"
#import "BLKControl.h"
#import "BLKJoystick.h"
#import "NSIndexPath+Tag.h"
#import "BLKSliderCell.h"
#import "UINib+NibView.h"

@interface BLKJoystickSettingsViewController () <BLKEditorDataSource>

@end

@implementation BLKJoystickSettingsViewController

#pragma mark - Private

- (NSString*)wireTitleForIndex:(NSInteger)index
{
    switch (index) {
        case NSNotFound:
            return @"Not connected"; break;
            
        default:
            return [NSString stringWithFormat:@"Channel %d", (int)index+1];
    }
}

- (NSString*)wireTitle
{
    NSInteger channelIndex = NSNotFound;
    switch (self.axis) {
        case BLKAxisX: channelIndex = self.joystickViewController.horizontalChannel; break;
        case BLKAxisY: channelIndex = self.joystickViewController.verticalChannel; break;
        case BLKAxisZ: channelIndex = self.joystickViewController.zChannel; break;
    }

    return [self wireTitleForIndex:channelIndex];
}

- (NSInteger)damperChannelIndex {
    switch(self.axis) {
        case BLKAxisX: return self.joystickViewController.horizontalDamperChannelIndex; break;
        case BLKAxisY: return self.joystickViewController.verticalDamperChannelIndex; break;
        case BLKAxisZ: break; // Not Supported
    }
    
    return NSNotFound;
}

- (void)setDamperChannelIndex:(NSInteger)channelIndex {
    switch (self.axis) {
        case BLKAxisX: self.joystickViewController.horizontalDamperChannelIndex = channelIndex; break;
        case BLKAxisY: self.joystickViewController.verticalDamperChannelIndex   = channelIndex; break;
        case BLKAxisZ: break; // Not Supported
    }
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.tableView reloadData];
}

#pragma mark - BLKEditorDataSource

- (NSString*)editor:(BLKEditorViewController*)editor titleForSettingsButtonAtPosition:(BLKEditorPosition)position
{
    return self.wireTitle;
}

- (NSString*)editor:(BLKEditorViewController *)editor keyPathToBindForPropertyAtPosition:(BLKEditorPosition)position
{
    switch (position) {
        case BLKEditorPositionTopCentre:
        case BLKEditorPositionRightCentre:
            switch (self.axis) {
                case BLKAxisX: return @"horizontalChannel";
                case BLKAxisY: return @"verticalChannel";
                case BLKAxisZ: return @"zChannel";
            }
            
        default:
            return nil;
    }
}

- (id)editor:(BLKEditorViewController *)editor objectToBindForPropertyAtPosition:(BLKEditorPosition)position
{
    return self.joystickViewController;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: //
            return 5; // TODO: Dynamically adapt to nbr of PWM channels

        case 1:
            return 2;
            
        case 2:
            return 1;
            
        case 3:
            return 5;
            
        case 4:
            return 2;
            
        case 5:
            return 2;
            
        case 6:
            return 5; // TODO: Dynamically adapt to nbr of PWM channels
    }

    // Return the number of rows in the section.
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    // cells based on xib files
    if (indexPath.section == 2 && indexPath.row == 0) {
        BLKSliderCell* cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:@"sliderCell"];
        if (!cell) {
            cell = (BLKSliderCell*)[UINib viewFromNibNamed:@"BLKSliderCell" bundle:[NSBundle bundleForClass:[self class]]];
            cell.resetButton.hidden = NO;
            [cell.readingLabel removeFromSuperview];
            [cell.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
            [cell.minusButton addTarget:self action:@selector(minusButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [cell.plusButton addTarget:self action:@selector(plusButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [cell.resetButton addTarget:self action:@selector(resetButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            cell.slider.tag = cell.minusButton.tag = cell.plusButton.tag = cell.resetButton.tag = indexPath.tag;
        }
        
        cell.slider.frame = CGRectInset(cell.bounds, 24.0, 8);
        cell.slider.minimumValue = -0.5;
        cell.slider.maximumValue = 0.5;
        switch (self.axis) {
            case BLKAxisX: cell.slider.value = self.joystickViewController.horizontalTrim; break;
            case BLKAxisY: cell.slider.value = self.joystickViewController.verticalTrim; break;
            case BLKAxisZ: cell.slider.value = self.joystickViewController.zTrim; break;
        }
        
        return cell;
    }
    
    NSString* cellId = @"channelName";
    if (indexPath.section == 1) {
        cellId = @"boolCell";
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    UISwitch* sw = nil;

    UITableViewCellAccessoryType type = UITableViewCellAccessoryNone;
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                cell.textLabel.text = [self wireTitleForIndex:NSNotFound];
                switch (self.axis) {
                    case BLKAxisX:
                        if (self.joystickViewController.horizontalChannel == NSNotFound) {
                            type = UITableViewCellAccessoryCheckmark;
                        }
                        break;
                    case BLKAxisY:
                        if (self.joystickViewController.verticalChannel == NSNotFound) {
                            type = UITableViewCellAccessoryCheckmark;
                        }
                        break;
                    case BLKAxisZ:
                        if (self.joystickViewController.zChannel == NSNotFound) {
                            type = UITableViewCellAccessoryCheckmark;
                        }
                        break;
                }
            } else { // Channel index case
                cell.textLabel.text = [self wireTitleForIndex:indexPath.row - 1];
                switch (self.axis) {
                    case BLKAxisX:
                        if (self.joystickViewController.horizontalChannel == indexPath.row - 1) {
                            type = UITableViewCellAccessoryCheckmark;
                        }
                        break;
                    case BLKAxisY:
                        if (self.joystickViewController.verticalChannel == indexPath.row - 1) {
                            type = UITableViewCellAccessoryCheckmark;
                        }
                        break;
                    case BLKAxisZ:
                        if (self.joystickViewController.zChannel == indexPath.row - 1) {
                            type = UITableViewCellAccessoryCheckmark;
                        }
                        break;
                }
            }
            cell.accessoryType  = type;
            break;
            
        case 1:
            sw = [UISwitch new];
            sw.tag = indexPath.tag;
            [sw addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = sw;
            switch (indexPath.row) {
                case 0: cell.textLabel.text = @"Inverted?";
                    if (self.axis == BLKAxisX) {
                        sw.on = self.joystickViewController.joystick.invertHorizontal;
                    } else if (self.axis == BLKAxisY) {
                        sw.on = self.joystickViewController.joystick.invertVertical;
                    }
                    break;
                case 1: cell.textLabel.text = @"Sticky?";
                    if (self.axis == BLKAxisX) {
                        sw.on = self.joystickViewController.joystick.stickyHorizontal;
                    } else if (self.axis == BLKAxisY) {
                        sw.on = self.joystickViewController.joystick.stickyVertical;
                    }
                    break;
            }
            break;
            
        case 2: // nothing to do
            break;
            
        case 3:
            switch (indexPath.row) {
                case 0: cell.textLabel.text = @"Linear"; break;
                case 1: cell.textLabel.text = @"Divide by 2"; break;
                case 2: cell.textLabel.text = @"Divide by 3"; break;
                case 3: cell.textLabel.text = @"Divide by 4"; break;
                case 4: cell.textLabel.text = @"Logarithmic"; break;
            }
            {
                BLKChannelScale scale = BLKChannelScaleLinear;
                switch (self.axis) {
                    case BLKAxisX: scale = self.joystickViewController.horizontalScale; break;
                    case BLKAxisY: scale = self.joystickViewController.verticalScale; break;
                    case BLKAxisZ: scale = self.joystickViewController.zScale; break;
                }
                cell.accessoryType = indexPath.row == scale ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            }
            break;
            
        case 4:
            switch (indexPath.row) {
                case 0: cell.textLabel.text = @"Set";
                    {
                        CGFloat v = NAN;
                        switch (self.axis) {
                            case BLKAxisX: v = self.joystickViewController.horizontalValueOnDisconnect; break;
                            case BLKAxisY: v = self.joystickViewController.verticalValueOnDisconnect; break;
                            case BLKAxisZ: v = self.joystickViewController.zValueOnDisconnect; break;
                        }
                        cell.accessoryType = cell.accessoryType = isnan(v) ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
                    }
                    break;

                case 1:
                    cell.textLabel.text = @"Clear";
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    break;
            }
            break;
            
        case 5:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Tie to controller roll?";
                    {
                        BOOL checked = NO;
                        switch (self.axis) {
                            case BLKAxisX: checked = self.joystickViewController.horizontalTieToControllerAngle; break;
                            case BLKAxisY: checked = self.joystickViewController.verticalTieToControllerAngle; break;
                            case BLKAxisZ: checked = self.joystickViewController.zTieToControllerAngle; break;
                        }
                        cell.accessoryType = checked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    }
                    break;
                    
                case 1:
                    cell.textLabel.text = @"Tie to controller tilt?";
                    {
                        BOOL checked = NO;
                        switch (self.axis) {
                            case BLKAxisX: checked = self.joystickViewController.horizontalTieToControllerTilt; break;
                            case BLKAxisY: checked = self.joystickViewController.verticalTieToControllerTilt; break;
                            case BLKAxisZ: checked = self.joystickViewController.zTieToControllerTilt; break;
                        }
                        cell.accessoryType = checked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    }
                    break;
            }
            break;

        case 6:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = [self wireTitleForIndex:NSNotFound];
                    if (self.damperChannelIndex == NSNotFound) {
                        type = UITableViewCellAccessoryCheckmark;
                    }
                    break;

                default: // Channel index case
                    cell.textLabel.text = [self wireTitleForIndex:indexPath.row - 1];
                    if (self.damperChannelIndex == indexPath.row - 1) {
                        type = UITableViewCellAccessoryCheckmark;
                    }
                    break;
            }
            cell.accessoryType  = type;
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    if (self.axis == BLKAxisX) {
                        self.joystickViewController.horizontalChannel = NSNotFound;
                    } else if (self.axis == BLKAxisY) {
                        self.joystickViewController.verticalChannel = NSNotFound;
                    } else if (self.axis == BLKAxisZ) {
                        self.joystickViewController.zChannel = NSNotFound;
                    }
                    break;
                    
                default:
                    switch (self.axis) {
                        case BLKAxisX: self.joystickViewController.horizontalChannel = indexPath.row - 1; break;
                        case BLKAxisY: self.joystickViewController.verticalChannel   = indexPath.row - 1; break;
                        case BLKAxisZ: self.joystickViewController.zChannel          = indexPath.row - 1; break;
                    }
                    
                    if (self.damperChannelIndex == indexPath.row - 1) {
                        self.damperChannelIndex = NSNotFound;
                    }
                    break;
            }
            [tableView reloadData];
            break;
        
        case 3:
            switch (self.axis) {
                case BLKAxisX: self.joystickViewController.horizontalScale = (BLKChannelScale)indexPath.row; break;
                case BLKAxisY: self.joystickViewController.verticalScale   = (BLKChannelScale)indexPath.row; break;
                case BLKAxisZ: self.joystickViewController.zScale          = (BLKChannelScale)indexPath.row; break;
            }
            [tableView reloadData];
            break;
            
        case 4:
            switch (indexPath.row) {
                case 0: // Set
                    switch (self.axis) {
                        case BLKAxisX: self.joystickViewController.horizontalValueOnDisconnect = self.joystickViewController.joystick.joystickCentre.x; break;
                        case BLKAxisY: self.joystickViewController.verticalValueOnDisconnect   = self.joystickViewController.joystick.joystickCentre.y; break;
                        case BLKAxisZ: self.joystickViewController.zValueOnDisconnect          = self.joystickViewController.joystick.joystickWheelPosition;        break;
                    }
                    break;

                case 1: // Clear
                    switch (self.axis) {
                        case BLKAxisX: self.joystickViewController.horizontalValueOnDisconnect = NAN; break;
                        case BLKAxisY: self.joystickViewController.verticalValueOnDisconnect   = NAN; break;
                        case BLKAxisZ: self.joystickViewController.zValueOnDisconnect          = NAN; break;
                    }
                    break;
            }
            [tableView reloadData];
            break;
            
        case 5:
            switch (indexPath.row) {
                case 0:
                    switch (self.axis) {
                        case BLKAxisX:
                            self.joystickViewController.horizontalTieToControllerAngle = !self.joystickViewController.horizontalTieToControllerAngle;
                            self.joystickViewController.verticalTieToControllerAngle   = NO;
                            self.joystickViewController.zTieToControllerAngle          = NO;
                            break;
                        case BLKAxisY:
                            self.joystickViewController.horizontalTieToControllerAngle = NO;
                            self.joystickViewController.verticalTieToControllerAngle   = !self.joystickViewController.verticalTieToControllerAngle;
                            self.joystickViewController.zTieToControllerAngle          = NO;
                            break;
                        case BLKAxisZ:
                            self.joystickViewController.horizontalTieToControllerAngle = NO;
                            self.joystickViewController.verticalTieToControllerAngle   = NO;
                            self.joystickViewController.zTieToControllerAngle          = !self.joystickViewController.zTieToControllerAngle;
                            break;
                    }
                    break;
                
                case 1:
                    switch (self.axis) {
                        case BLKAxisX:
                            self.joystickViewController.horizontalTieToControllerTilt = !self.joystickViewController.horizontalTieToControllerTilt;
                            self.joystickViewController.verticalTieToControllerTilt   = NO;
                            self.joystickViewController.zTieToControllerTilt          = NO;
                            break;
                        case BLKAxisY:
                            self.joystickViewController.horizontalTieToControllerTilt = NO;
                            self.joystickViewController.verticalTieToControllerTilt   = !self.joystickViewController.verticalTieToControllerTilt;
                            self.joystickViewController.zTieToControllerTilt          = NO;
                            break;
                        case BLKAxisZ:
                            self.joystickViewController.horizontalTieToControllerTilt = NO;
                            self.joystickViewController.verticalTieToControllerTilt   = NO;
                            self.joystickViewController.zTieToControllerTilt          = !self.joystickViewController.zTieToControllerTilt;
                            break;
                    }
                    break;
            }
            [tableView reloadData];
            break;

        case 6:
            switch (indexPath.row) {
                case 0:
                    self.damperChannelIndex = NSNotFound;
                    break;
                    
                default:
                    {
                        NSInteger signalChannelIndex = NSNotFound;
                        switch(self.axis) {
                            case BLKAxisX: signalChannelIndex = self.joystickViewController.horizontalChannel; break;
                            case BLKAxisY: signalChannelIndex = self.joystickViewController.verticalChannel;   break;
                            case BLKAxisZ: signalChannelIndex = self.joystickViewController.zChannel;          break;
                        }

                        if (signalChannelIndex != indexPath.row - 1) {
                            self.damperChannelIndex = indexPath.row - 1;
                        } else {
                            signalChannelIndex = NSNotFound;
                        }
                    }
                    break;
            }
            [tableView reloadData];
            
        default:
            break;
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0: return @"PWM Channel";
        case 1: return @"Options";
        case 2: return @"Trim";
        case 3: return @"Scale";
        case 4: return @"On Disconnection";
        case 5: return @"Controller Motion";
        case 6: return @"Inversely proportional to modulo of";
    }

    return nil;
}

#pragma mark - Actions

- (IBAction)switchValueChanged:(UISwitch*)sw
{
    NSIndexPath* indexPath = [NSIndexPath indexPathFromTag:sw.tag];

    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: if (self.axis == BLKAxisX) {
                        self.joystickViewController.joystick.invertHorizontal = sw.on;
                    } else if (self.axis == BLKAxisY) {
                        self.joystickViewController.joystick.invertVertical = sw.on;
                    }
                break;
            
            case 1: if (self.axis == BLKAxisX) {
                        self.joystickViewController.joystick.stickyHorizontal = sw.on;
                    } else if (self.axis == BLKAxisY) {
                        self.joystickViewController.joystick.stickyVertical = sw.on;
                    }
                break;
        }
    }
}

- (CGFloat)incrementPerPixelForSlider:(UISlider*)slider
{
    CGFloat range = slider.maximumValue - slider.minimumValue;

    return range / slider.bounds.size.width;
}

- (void)minusButtonTapped:(UIButton*)button
{
    NSIndexPath* indexPath = [NSIndexPath indexPathFromTag:button.tag];
    
    BLKSliderCell* cell = (BLKSliderCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    
    cell.slider.value = cell.slider.value - [self incrementPerPixelForSlider:cell.slider];
    [self sliderValueChanged:cell.slider];
}

- (void)plusButtonTapped:(UIButton*)button
{
    NSIndexPath* indexPath = [NSIndexPath indexPathFromTag:button.tag];
    
    BLKSliderCell* cell = (BLKSliderCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    
    cell.slider.value = cell.slider.value + [self incrementPerPixelForSlider:cell.slider];
    [self sliderValueChanged:cell.slider];
}

- (void)resetButtonTapped:(UIButton*)button
{
    NSIndexPath* indexPath = [NSIndexPath indexPathFromTag:button.tag];

    BLKSliderCell* cell = (BLKSliderCell*)[self.tableView cellForRowAtIndexPath:indexPath];

    cell.slider.value = 0.0;
    [self sliderValueChanged:cell.slider];
}

- (void)sliderValueChanged:(UISlider*)slider
{
    switch (self.axis) {
        case BLKAxisX: self.joystickViewController.horizontalTrim = slider.value; break;
        case BLKAxisY: self.joystickViewController.verticalTrim = slider.value; break;
        case BLKAxisZ: self.joystickViewController.zTrim = slider.value; break;
    }
}

@end
