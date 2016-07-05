//
//  BLKSliderCell.h
//  BLEKit
//
//  Created by Igor Sales on 2014-12-05.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface BLKSliderCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIButton* minusButton;
@property (nonatomic, weak) IBOutlet UIButton* plusButton;
@property (nonatomic, weak) IBOutlet UIButton* resetButton;
@property (nonatomic, weak) IBOutlet UILabel*  readingLabel;

@property (nonatomic, weak) IBOutlet UISlider* slider;

@end
