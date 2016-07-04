//
//  BLEKit.h
//  BLEKit
//
//  Created by Igor Sales on 2014-09-30.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for BLEKit.
FOUNDATION_EXPORT double BLEKitVersionNumber;

//! Project version string for BLEKit.
FOUNDATION_EXPORT const unsigned char BLEKitVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <BLEKit/PublicHeader.h>
#import <BLEKit/BLKLog.h>

#import <BLEKit/BLKUUIDs.h>
#import <BLEKit/BLKManager.h>
#import <BLEKit/BLKLoad.h>
#import <BLEKit/BLKDevice.h>
#import <BLEKit/BLKControl.h>
#import <BLEKit/BLKConfiguration.h>

#import <BLEKit/BLKDiscoveryOperation.h>
#import <BLEKit/BLKFirmwareUpdateOperation.h>
#import <BLEKit/BLKLoadManager.h>
#import <BLEKit/BLKService.h>
#import <BLEKit/BLKDeviceInfoService.h>
#import <BLEKit/BLKOTAUpdateService.h>
#import <BLEKit/BLKPortsService.h>

#import <BLEKit/BLKLoadsViewController.h>
#import <BLEKit/BLKDevicesViewController.h>
#import <BLEKit/BLKFirmwareUpdateViewController.h>
#import <BLEKit/BLKJoystickViewController.h>
#import <BLEKit/BLKControlsViewController.h>
#import <BLEKit/BLKI2CViewController.h>
#import <BLEKit/BLKEditorViewController.h>
#import <BLEKit/BLKContainerViewController.h>
#import <BLEKit/BLKCompassViewController.h>
#import <BLEKit/BLKPWMSliderViewController.h>
#import <BLEKit/BLKADCViewController.h>
#import <BLEKit/BLKAccelerometerViewController.h>
#import <BLEKit/BLKGyroscopeViewController.h>
#import <BLEKit/BLKGPIOsViewController.h>

#import <BLEKit/BLKPort.h>
#import <BLEKit/BLKPWMChannelsPort.h>
#import <BLEKit/BLKI2CControlPort.h>
#import <BLEKit/BLKOTAUpdatePort.h>
#import <BLEKit/BLKADCPort.h>
#import <BLEKit/BLKJoystick.h>
#import <BLEKit/BLKGPIOPort.h>

#import <BLEKit/BLKEditorControl.h>
#import <BLEKit/BLKCompassView.h>
#import <BLEKit/BLKAccelerometerView.h>
#import <BLEKit/BLKGyroscopeView.h>
#import <BLEKit/BLKSliderCell.h>
#import <BLEKit/BLKGaugeView.h>
#import <BLEKit/BLKLEDView.h>
#import <BLEKit/BLKProgressiveBarsView.h>
#import <BLEKit/BLKFirmwareLoadCell.h>

#import <BLEKit/BLKDriver.h>
#import <BLEKit/BLKI2CDriver.h>
#import <BLEKit/BLKSTLIS3MDLDriver.h>
