//
//  BLKDevicesViewController.m
//  BLEKit
//
//  Created by Igor Sales on 2014-10-05.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKDevicesViewController.h"
#import "BLKDiscoveryOperation.h"
#import "BLKDevice.h"
#import "BLKManager.h"
#import "BLKDevicesTableViewCell.h"
#import "BLKLoadManager.h"
#import "BLKLoadsTableViewController.h"
#import "BLKFirmwareUpdateOperation.h"
#import "BLKLoad.h"
#import "BLKOTAUpdatePort.h"
#import "BLKDeviceInfoService.h"
#import "BLKDevice+Private.h"
#import "BLKProgressiveBarsView.h"

@interface BLKDevicesViewController () <BLKLoadsTableViewControllerDelegate, BLKFirmwareUpdateOperationDelegate>

@property (nonatomic, strong) NSArray* dataSource;
@property (nonatomic, strong) UIPopoverController* loadsPopoverController;

@end

@implementation BLKDevicesViewController

#pragma mark - Overrides

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.discoveryOperation start];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.discoveryOperation stop];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

#pragma mark - Private

- (NSIndexPath*)indexPathForPeripheral:(CBPeripheral*)peripheral
{
    __block NSInteger index = NSNotFound;
    
    [self.dataSource enumerateObjectsUsingBlock:^(BLKDevice* dev, NSUInteger idx, BOOL *stop) {
        if ([dev.peripheralIdentifier isEqual:peripheral.identifier]) {
            index = idx;
            *stop = YES;
        }
    }];
    
    if (index != NSNotFound) {
        return [NSIndexPath indexPathForRow:index inSection:0];
    }
    
    return nil;
}

- (NSIndexPath*)indexPathForDevice:(BLKDevice*)dev
{
    __block NSInteger index = [self.dataSource indexOfObject:dev];

    if (index != NSNotFound) {
        return [NSIndexPath indexPathForRow:index inSection:0];
    } else {
        [self.dataSource enumerateObjectsUsingBlock:^(BLKDevice* device, NSUInteger idx, BOOL *stop) {
            if ([dev.peripheralIdentifier isEqual:device.peripheral.identifier]) {
                index = idx;
                *stop = YES;
            }
        }];

        if (index != NSNotFound) {
            return [NSIndexPath indexPathForRow:index inSection:0];
        }
    }

    return nil;
}

- (void)updateCell:(BLKDevicesTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    BLKDevice* device = [self.dataSource objectAtIndex:indexPath.row];
    
    NSString* hardwareID = device.info.hardwareID;
    NSString* hardwareRev = device.info.hardwareRevision;
    NSString* firmwareID = device.info.firmwareID;
    NSString* firmwareRev = device.info.firmwareRevision;
    
    cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", device.peripheral.name, hardwareID ? hardwareID : @""];
    cell.RSSILabel.text = [NSString stringWithFormat:@"%d", (int)device.signalStrength];
    // update with formula: 10 ^ [ (RSSI - A)/n ]
    cell.barsView.signal = (127.0 + device.signalStrength) / 255.0;
    cell.idLabel.text = [NSString stringWithFormat:@"%@ %@: %@ %@",
                         hardwareID ? hardwareID : @"Unknown",
                         hardwareRev ? hardwareRev : @"",
                         firmwareID ? firmwareID : @"firmware",
                         firmwareRev ? firmwareRev : @""];
    cell.detailTextLabel.text = device.peripheralIdentifier.UUIDString;
    cell.statusLabel.text = [self statusForDevice:device];
    
    switch (device.state) {
        case BLKDeviceStateDisconnected:
        default:
            cell.accessoryType = [self.loadsManager hasNewerFirmwareRevisionForDevice:device] ||
                                 [self.loadsManager hasStarterFirmwareRevisionForDevice:device] ?
                                     UITableViewCellAccessoryDetailButton : UITableViewCellAccessoryNone;
            cell.progressView.hidden = YES;
            break;
            
        case BLKDeviceStateConnecting:
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.progressView.hidden = YES;
            break;
            
        case BLKDeviceStateConnected:
            cell.accessoryType = [self.loadsManager hasNewerFirmwareRevisionForDevice:device] ||
                                 [self.loadsManager hasStarterFirmwareRevisionForDevice:device] ?
                                     UITableViewCellAccessoryDetailButton : UITableViewCellAccessoryNone;
            cell.progressView.hidden = YES;
            break;
            
        case BLKDeviceStateUpdatingFirmware:
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.progressView.hidden = NO;
            cell.progressView.progress = device.updateOperation.progress;
    }
    
    [device.peripheral readRSSI];
}

- (void)bindCell:(BLKDevicesTableViewCell*)cell toDeviceAtIndexPath:(NSIndexPath*)indexPath
{
    BLKDevice* device = [self.dataSource objectAtIndex:indexPath.row];

    [device addObserver:self forKeyPath:@"state" options:0 context:nil];
    [device addObserver:self forKeyPath:@"info.firmwareID" options:0 context:nil];
    [device addObserver:self forKeyPath:@"signalStrength" options:0 context:nil];
}

- (void)unbindCell:(BLKDevicesTableViewCell*)cell fromDevice:(BLKDevice*)device
{
    [device removeObserver:self forKeyPath:@"state"];
    [device removeObserver:self forKeyPath:@"info.firmwareID"];
    [device removeObserver:self forKeyPath:@"signalStrength"];
}

- (void)updateCellForDevice:(BLKDevice*)device
{
    NSIndexPath* indexPath = [self indexPathForDevice:device];
    if (indexPath) {
        BLKDevicesTableViewCell* cell = (BLKDevicesTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        [self updateCell:cell atIndexPath:indexPath];
    }
}

- (NSString*)statusForDevice:(BLKDevice*)device
{
    switch (device.state) {
        case BLKDeviceStateDisconnected:
            return @"";
            
        case BLKDeviceStateConnecting:         return @"Connecting...";
        case BLKDeviceStateConnected:          return @"Connected";
        case BLKDeviceStateUpdatingFirmware:   return [self statusForUpdateOperation:device.updateOperation];
        case BLKDeviceStateUnavailable:        return @"Unavailable";
    }
}
    
- (NSString*)statusForUpdateOperation:(BLKFirmwareUpdateOperation*)operation
{
    NSString* status = nil;
    switch (operation.state) {
        case BLKFirmwareUpdateOperationStatePreparing:   status = @"Preparing"; break;
        case BLKFirmwareUpdateOperationStateDownloading: status = @"Downloading"; break;
        case BLKFirmwareUpdateOperationStateErasing:     status = @"Erasing"; break;
        case BLKFirmwareUpdateOperationStateUploading:   status = @"Uploading"; break;
        case BLKFirmwareUpdateOperationStateRestarting:  status = @"Restarting"; break;
        case BLKFirmwareUpdateOperationStateDone:        status = @"Success"; break;
        case BLKFirmwareUpdateOperationStateError:
            return [NSString stringWithFormat:@"Error: %@", operation.lastError.localizedDescription];
            
        default:
            break;
    }
    
    if (status) {
        status = [NSString stringWithFormat:@"F/W Update: %@", status];
    }

    return status;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    BLKDevicesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BLKDevicesViewControllerCell" forIndexPath:indexPath];
    
    [self updateCell:cell atIndexPath:indexPath];
    [self bindCell:cell toDeviceAtIndexPath:indexPath];

    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] == NSNotFound) {
        BLKDevice* device = [self.dataSource objectAtIndex:indexPath.row];
        [self unbindCell:(BLKDevicesTableViewCell*)cell fromDevice:device];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BLKDevice* device = [self.dataSource objectAtIndex:indexPath.row];
    [self.delegate devicesViewController:self didSelectDevice:device];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* tappedCell = [tableView cellForRowAtIndexPath:indexPath];
    BLKLoadsTableViewController* tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"BLKLoadsTableViewController"];
    tvc.loadsManager = self.loadsManager;
    tvc.device = [self.dataSource objectAtIndex:indexPath.row];
    tvc.delegate = self;

    if (UIUserInterfaceIdiomPad == [UIDevice currentDevice].userInterfaceIdiom) {
        self.loadsPopoverController = [[UIPopoverController alloc] initWithContentViewController:tvc];
        
        [self.loadsPopoverController presentPopoverFromRect:CGRectInset(tappedCell.frame, 8, 8)
                            inView:tableView
          permittedArrowDirections:UIPopoverArrowDirectionLeft
                          animated:YES];
    } else {
        [self.navigationController pushViewController:tvc animated:YES];
    }
}

#pragma mark - BLKDiscoveryActionDelegate

- (void)discoveryOperationDidUpdateDiscoveredPeripherals:(BLKDiscoveryOperation *)operation
{
    self.dataSource = operation.discoveredDevices;
    [self.tableView reloadData];
}

- (void)discoveryOperation:(BLKDiscoveryOperation *)operation didUpdateDevice:(BLKDevice *)device
{
    __block NSInteger idx = NSNotFound;
    [self.dataSource enumerateObjectsUsingBlock:^(BLKDevice* device, NSUInteger i, BOOL *stop) {
        if ([device.peripheralIdentifier isEqual:device.peripheralIdentifier]) {
            *stop = YES;
            idx = i;
        }
    }];
    if (idx == NSNotFound) {
        return;
    }

    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
    BLKDevicesTableViewCell* cell = (BLKDevicesTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    
    [self updateCell:cell atIndexPath:indexPath];
}

#pragma mark - BLKLoadsTableViewControllerDelegate

- (void)loadsController:(BLKLoadsTableViewController *)controller didSelectLoadToInstall:(BLKLoad *)load
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.loadsPopoverController dismissPopoverAnimated:YES];
        self.loadsPopoverController = nil;
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    BLKOTAUpdatePort* port   = (BLKOTAUpdatePort*)[controller.device portOfType:kBLKPortTypeOTAUpdate atIndex:0 subIndex:0 withOptions:nil];

    BLKFirmwareUpdateOperation* updateOperation = [[BLKFirmwareUpdateOperation alloc] initWithOTAUpdatePort:port];
    updateOperation.deviceManager = self.manager;
    updateOperation.delegate = self;
    
    controller.device.updateOperation = updateOperation;

    [updateOperation setFirmwareFromURL:load.firmwareURL];
    [updateOperation start];
}

#pragma mark - BLKFirmwareUpdateOperationDelegate

- (void)firmwareUpdateOperationDidChangeState:(BLKFirmwareUpdateOperation *)operation
{
    NSIndexPath* indexPath = [self indexPathForPeripheral:operation.port.peripheral];
    BLKDevice* device    = [self.manager deviceForPeripheral:operation.port.peripheral];
    if (indexPath) {
        NSString* status = [self statusForUpdateOperation:operation];

        if (status) {
            BLKDevicesTableViewCell* cell = (BLKDevicesTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            cell.statusLabel.text = status;
            cell.statusLabel.textColor = [UIColor blackColor];
        }
    }
    
    if (operation.state == BLKFirmwareUpdateOperationStateDone) {
        device.updateOperation = nil;
    }
}

- (void)firmwareUpdateOperation:(BLKFirmwareUpdateOperation *)action progressedTo:(double)progress
{
    NSIndexPath* indexPath = [self indexPathForPeripheral:action.port.peripheral];
    if (indexPath) {
        BLKDevicesTableViewCell* cell = (BLKDevicesTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.progressView.hidden   = NO;
        cell.progressView.progress = progress;
    }
}

- (void)firmwareUpdateOperation:(BLKFirmwareUpdateOperation *)action finishedWithError:(NSError *)error
{
    NSIndexPath* indexPath = [self indexPathForPeripheral:action.port.peripheral];
    if (indexPath) {
        BLKDevicesTableViewCell* cell = (BLKDevicesTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.progressView.hidden = YES;
        cell.statusLabel.text    = error.localizedDescription;
        cell.statusLabel.textColor = [UIColor redColor];
    } else {
        NSLog(@"firmware update operation error: %@", error);
    }
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:[BLKDevice class]]) {
        BLKDevice* device = object;
        NSIndexPath* indexPath = [self indexPathForDevice:device];
        if (indexPath) {
            BLKDevicesTableViewCell* cell = (BLKDevicesTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            [self updateCell:cell atIndexPath:indexPath];
        }
    }
}

@end
