//
//  BLKFirmwareLoadCell.h
//  BLEKit
//
//  Created by Igor Sales on 2014-09-19.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface BLKFirmwareLoadCell : UIView

@property (nonatomic, weak) IBOutlet UIView* backdropView;
@property (nonatomic, weak) IBOutlet UIImageView* imageView;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UILabel* subtitleLabel;

@end
