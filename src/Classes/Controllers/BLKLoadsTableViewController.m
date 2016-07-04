//
//  BLKLoadsTableViewController.m
//  BLEKit
//
//  Created by Igor Sales on 2014-10-13.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKLoadsTableViewController.h"
#import "BLKLoadManager.h"
#import "BLKFirmwareLoadCell.h"
#import "UIImageView+URL.h"
#import "BLKLoad.h"

@interface BLKLoadsTableViewController()

@property (nonatomic, strong) NSArray* sameHardwareAndFirmwareLoads;
@property (nonatomic, strong) NSArray* sameHardwareLoads;
@property (nonatomic, strong) NSArray* olderFirmwareLoads;
@property (nonatomic, strong) NSArray* starterLoads;

@property (nonatomic, assign) NSInteger sameHardwareAndFirmwareLoadsSection;
@property (nonatomic, assign) NSInteger sameHardwareLoadsSection;
@property (nonatomic, assign) NSInteger olderFirmwareLoadsSection;
@property (nonatomic, assign) NSInteger starterLoadsSection;

@end

@implementation BLKLoadsTableViewController

#pragma mark - View overrides

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // prepare table data
    self.sameHardwareAndFirmwareLoads = [self.loadsManager newerFirmwareLoadsForDevice:self.device];
    self.sameHardwareLoads            = [self.loadsManager compatibleFirmwareLoadsForDevice:self.device];
    self.olderFirmwareLoads           = [self.loadsManager olderFirmwareLoadsForDevice:self.device];
    
    BLKLoad* starterLoad = [self.loadsManager starterLoadForDevice:self.device];
    if (starterLoad) {
        self.starterLoads = @[ starterLoad ];
    } else {
        self.starterLoads = @[];
    }
}

#pragma mark - Private

- (BLKLoad*)loadForIndexPath:(NSIndexPath*)indexPath
{
    BLKLoad* load = nil;

    if (indexPath.section == self.sameHardwareAndFirmwareLoadsSection) {
        load = self.sameHardwareAndFirmwareLoads[indexPath.row];
    } else if (indexPath.section == self.sameHardwareLoadsSection) {
        load = self.sameHardwareLoads[indexPath.row];
    } else if (indexPath.section == self.olderFirmwareLoadsSection) {
        load = self.olderFirmwareLoads[indexPath.row];
    } else if (indexPath.section == self.starterLoadsSection) {
        load = self.starterLoads[indexPath.row];
    }

    return load;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger section = 0;
    self.sameHardwareAndFirmwareLoadsSection = self.sameHardwareAndFirmwareLoads.count ? section++ : -1;
    self.sameHardwareLoadsSection            = self.sameHardwareLoads.count ? section++ : -1;
    self.olderFirmwareLoadsSection           = self.olderFirmwareLoads.count ? section++ : -1;
    self.starterLoadsSection                 = self.starterLoads.count ? section++ : -1;

    return section;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == self.sameHardwareAndFirmwareLoadsSection) {
        return self.sameHardwareAndFirmwareLoads.count;
    } else if (section == self.sameHardwareLoadsSection) {
        return self.sameHardwareLoads.count;
    } else if (section == self.olderFirmwareLoadsSection) {
        return self.olderFirmwareLoads.count;
    } else if (section == self.starterLoadsSection) {
        return self.starterLoads.count;
    }

    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:@"BLKLoadsTableViewControllerCell" forIndexPath:indexPath];
    
    BLKFirmwareLoadCell* loadCell = (BLKFirmwareLoadCell*)cell.contentView.subviews[0];
    
    BLKLoad* load = [self loadForIndexPath:indexPath];
    
    loadCell.titleLabel.text = load.name;
    loadCell.subtitleLabel.text = load.firmwareVersion;
    [loadCell.imageView setImageFromURL:load.iconURL];
    
    CGSize size = [loadCell.titleLabel.text sizeWithAttributes:@{
                                                                 NSFontAttributeName: loadCell.titleLabel.font
                                                                 }];
    if (size.width > loadCell.titleLabel.bounds.size.width) {
        CGFloat d = size.width - loadCell.titleLabel.bounds.size.width;
        loadCell.frame = CGRectMake(loadCell.frame.origin.x, loadCell.frame.origin.y,
                                    loadCell.frame.size.width + d, loadCell.frame.size.height);
    }
    
#if 0
    OBDragDropManager *dragDropManager = [OBDragDropManager sharedManager];
    
    // Drag and drop using pan
    UIGestureRecognizer *panRecognizer = [dragDropManager createDragDropGestureRecognizerWithClass:[UIPanGestureRecognizer class] source:self];
    [loadCell addGestureRecognizer:panRecognizer];
#endif

    return cell;
}

#pragma mark - UITableViewDelegate

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == self.sameHardwareAndFirmwareLoadsSection) {
        return @"Latest";
    } else if (section == self.sameHardwareLoadsSection) {
        return @"Other";
    } else if (section == self.olderFirmwareLoadsSection) {
        return @"Older";
    } else if (section == self.starterLoadsSection) {
        return @"Factory";
    }

    return nil;
}

/*- (NSArray*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @[ [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                 title:@"Install"
                                               handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                   [tableView setEditing:NO animated:YES];
                                               }] ];
}*/

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Install";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)installFirmwareAtIndexPath:(NSIndexPath*)indexPath
{
    [self.tableView setEditing:NO animated:YES];
    
    BLKLoad* load = [self loadForIndexPath:indexPath];
    [self.delegate loadsController:self didSelectLoadToInstall:load];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self performSelector:@selector(installFirmwareAtIndexPath:) withObject:indexPath afterDelay:0.01];
    }
}

@end
