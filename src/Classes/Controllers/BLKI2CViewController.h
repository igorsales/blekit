//
//  BLKI2CViewController.h
//  BLEKit
//
//  Created by Igor Sales on 2014-10-07.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLKControlViewControllerProtocol.h"

@class BLKI2CControlPort;

@interface BLKI2CViewController : UIViewController <BLKControlViewControllerProtocol>

@property (nonatomic, readonly) IBOutlet BLKI2CControlPort*  I2CPort;

@property (nonatomic, weak)   IBOutlet UIPickerView* slaveAddressPicker;
@property (nonatomic, weak)   IBOutlet UIPickerView* regAddressPicker;
@property (nonatomic, weak)   IBOutlet UIPickerView* lengthPicker;
@property (nonatomic, weak)   IBOutlet UITextField*  hexTextField;
@property (nonatomic, weak)   IBOutlet UISwitch*     stopSwitch;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray* digitButtons;

- (IBAction)readTapped:(id)sender;
- (IBAction)writeTapped:(id)sender;
- (IBAction)hexDigitTapped:(id)sender;
- (IBAction)delTapped:(id)sender;
- (IBAction)clearTapped:(id)sender;

@end
