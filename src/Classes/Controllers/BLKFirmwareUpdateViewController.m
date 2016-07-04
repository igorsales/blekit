//
//  BLKFirmwareUpdateViewController.m
//  BLEKit
//
//  Created by Igor Sales on 2014-09-14.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKFirmwareUpdateViewController.h"
#import "BLKDevicesTableViewCell.h"
#import "BLKLoadsViewController.h"
#import "BLKDevice.h"
#import "BLKManager.h"
#import "BLKLoad.h"
#import "BLKFirmwareUpdateOperation.h"
#import "BLKDiscoveryOperation.h"
#import "BLKOTAUpdatePort.h"
#import "BLKDeviceInfoService.h"

@interface BLKFirmwareUpdateViewController () <BLKFirmwareUpdateOperationDelegate>

@property (nonatomic, strong) NSArray* dataSource;
@property (nonatomic, strong) NSMutableSet* updateActions;

@end

@implementation BLKFirmwareUpdateViewController

#pragma mark - Class

+ (BLKFirmwareUpdateViewController*)firmwareUpdateViewController
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"BLKFirmwareUpdate_iPhone" bundle:[NSBundle bundleForClass:[self class]]];

    return [storyboard instantiateInitialViewController];
}

#pragma mark - Setup/Teardown

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.updateActions = [NSMutableSet new];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        self.updateActions = [NSMutableSet new];
    }

    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Overload

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"loadsController"]) {
        self.loadsController = segue.destinationViewController;
        self.loadsController.loadsManager = self.loadManager;
    }
}

#pragma mark - BLKManagerDelegate

- (void)managerDidBecomeReady:(BLKManager *)manager
{
    [self.discoveryAction start];
}

- (void)managerDidBecomeUnavailable:(BLKManager *)manager
{
    [self.discoveryAction stop];
}

- (void)manager:(BLKManager *)manager didUpdateListOfOTAUpdatableDevices:(NSArray *)devs
{
    self.dataSource = devs;
    [self.tableView reloadData];
}

- (void)manager:(BLKManager *)manager didConnectToPeripheral:(CBPeripheral*)peripheral
{
    BLKDevicesTableViewCell* cell = [self cellForPeripheral:peripheral];

    [cell setStatusString:@"Connected"];
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

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BLKDevicesTableViewCell* cell = (BLKDevicesTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"BLKDevice" forIndexPath:indexPath];
    
    BLKDevice* dev = self.dataSource[indexPath.row];

    NSString* title = dev.peripheral.name;
    if (dev.info.manufacturer) {
        title = [title stringByAppendingFormat:@" by %@", dev.info.manufacturer];
    }
    cell.nameLabel.text = title;
    
#if 0 // TODO: Use better RSSI label
    cell.RSSILabel.text = dev.peripheral.RSSI.description;
#endif
    
    cell.progressView.hidden = ![self isPeripheralUpdating:dev.peripheral];

    cell.idLabel.text = [NSString stringWithFormat:@"%@ %@ running %@ %@",
                         dev.info.hardwareID ? dev.info.hardwareID : @"Unknown",
                         dev.info.hardwareRevision ? dev.info.hardwareRevision : @"",
                         dev.info.firmwareID ? dev.info.firmwareID : @"firmware",
                         dev.info.firmwareRevision ? dev.info.firmwareRevision : @""];

#if 0
    cell.dropZoneHandler = self;
#endif 

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Private

- (BLKDevicesTableViewCell*)cellForPeripheral:(CBPeripheral*)peripheral
{
    __block BLKDevicesTableViewCell* cell = nil;
    [self.dataSource enumerateObjectsUsingBlock:^(BLKDevice* dev, NSUInteger idx, BOOL *stop) {
        if ([dev.peripheral isEqual:peripheral]) {
            *stop = YES;
            cell = (BLKDevicesTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
        }
    }];

    return cell;
}

- (BOOL)isPeripheralUpdating:(CBPeripheral*)peripheral
{
    __block BOOL updating = NO;
    [self.updateActions enumerateObjectsUsingBlock:^(BLKFirmwareUpdateOperation* action, BOOL *stop) {
        if (action.port.peripheral == peripheral) {
            updating = YES;
            *stop = YES;
        }
    }];

    return updating;
}

#pragma mark - BLKfirmwareUpdateOperationDelegate

- (void)firmwareUpdateOperation:(BLKFirmwareUpdateOperation *)action finishedWithError:(NSError *)error
{
    BLKDevicesTableViewCell* cell = [self cellForPeripheral:action.port.peripheral];
    
    cell.progressView.hidden = YES;
    
    [cell setStatusString:error.localizedDescription success:NO];
    
    [self.updateActions removeObject:action];
}

- (void)firmwareUpdateOperation:(BLKFirmwareUpdateOperation *)action progressedTo:(double)progress
{
    BLKDevicesTableViewCell* cell = [self cellForPeripheral:action.port.peripheral];

    [cell setProgress:progress];
}

- (void)firmwareUpdateOperationDownloading:(BLKFirmwareUpdateOperation *)action
{
    BLKDevicesTableViewCell* cell = [self cellForPeripheral:action.port.peripheral];
    
    [cell setStatusString:@"Downloading"];
}

- (void)firmwareUpdateOperationStarted:(BLKFirmwareUpdateOperation *)action
{
    BLKDevicesTableViewCell* cell = [self cellForPeripheral:action.port.peripheral];
    
    [cell setStatusString:@"Updating"];
}

- (void)firmwareUpdateOperationEnded:(BLKFirmwareUpdateOperation *)action
{
    BLKDevicesTableViewCell* cell = [self cellForPeripheral:action.port.peripheral];
    
    [cell setStatusString:@"Success" success:YES];

    [self.updateActions removeObject:action];
}

#if 0

#pragma mark - OBDropZoneHandler

- (OBDropAction)ovumEntered:(OBOvum*)ovum inView:(BLKDevicesTableViewCell*)view atLocation:(CGPoint)location
{
    //self.view.backgroundColor = [UIColor redColor];
    view.dropZoneView.hidden = NO;
    return OBDropActionCopy;    // Return OBDropActionNone if view is not currently accepting this ovum
}

- (void)ovumExited:(OBOvum*)ovum inView:(BLKDevicesTableViewCell*)view atLocation:(CGPoint)location
{
    view.dropZoneView.hidden = YES;
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)ovumDropped:(OBOvum*)ovum inView:(BLKDevicesTableViewCell*)cell atLocation:(CGPoint)location
{
    cell.dropZoneView.hidden = YES;

    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    //CBPeripheral* p = [self.dataSource objectAtIndex:indexPath.row];
    
    BLKFirmwareUpdateOperation* action = [[BLKFirmwareUpdateOperation alloc] initWithOTAUpdatePort:nil]; // TODO: Fix
    action.delegate = self;
    
    [self.updateActions addObject:action];
    
    BLKLoad* load = ovum.dataObject;
    [action setFirmwareFromURL:load.firmwareURL];
}

#endif 

@end
