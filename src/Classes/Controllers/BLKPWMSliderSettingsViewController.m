//
//  BLKPWMSliderSettingsViewController.m
//  BLEKit
//
//  Created by Igor Sales on 2015-05-27.
//  Copyright (c) 2015 IgorSales.ca. All rights reserved.
//

#import "BLKPWMSliderSettingsViewController.h"
#import "BLKPWMSliderViewController.h"
#import "BLKEditorViewController.h"

@interface BLKPWMSliderSettingsViewController () <BLKEditorDataSource>

@end

@implementation BLKPWMSliderSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Private

- (NSString*)wireTitle
{
    return [self wireTitleForIndex:self.PWMSliderViewController.channel];
}

- (NSString*)wireTitleForIndex:(NSInteger)index
{
    switch (index) {
        case NSNotFound:
            return @"Not connected"; break;
            
        default:
            return [NSString stringWithFormat:@"Channel %d", (int)index+1];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: return 5; // TODO
        case 1: return 2;
            
        default:
            break;
    }

    return 0;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0: return @"PWM Channel";
        case 1: return @"Range";
    }

    return nil;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                cell.textLabel.text = [self wireTitleForIndex:NSNotFound];
                if (self.PWMSliderViewController.channel == NSNotFound) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            } else {
                cell.textLabel.text = [self wireTitleForIndex:indexPath.row - 1];
                if (self.PWMSliderViewController.channel == indexPath.row - 1) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
            break;
            
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Minimum";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d (0x%04x)",
                                                 (int)self.PWMSliderViewController.slider.minimumValue,
                                                 (int)self.PWMSliderViewController.slider.minimumValue];
                    break;
                    
                case 1:
                    cell.textLabel.text = @"Maximum";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d (0x%04x)",
                                                 (int)self.PWMSliderViewController.slider.maximumValue,
                                                 (int)self.PWMSliderViewController.slider.maximumValue];
                    break;
                    
                default:
                    break;
            }
            break;
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0: self.PWMSliderViewController.channel = NSNotFound; break;
                    
                default:
                    self.PWMSliderViewController.channel = indexPath.row - 1; break;
            }
            [tableView reloadData];
            break;
            
        default:
            break;
    }
}

#pragma mark - BLKEditorDataSource

- (NSString*)editor:(BLKEditorViewController*)editor titleForSettingsButtonAtPosition:(BLKEditorPosition)position
{
    switch (position) {
        case BLKEditorPositionTopCentre:
            return self.wireTitle;
            break;
            
        default:
            return nil;
    }
}

@end
