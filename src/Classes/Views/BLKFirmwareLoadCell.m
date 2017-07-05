//
//  BLKFirmwareLoadCell.m
//  BLEKit
//
//  Created by Igor Sales on 2014-09-19.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKFirmwareLoadCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation BLKFirmwareLoadCell

- (id)initWithFrame:(CGRect)frame
{
    ;
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.backdropView.layer.masksToBounds = YES;
    self.backdropView.layer.cornerRadius  = 8.0;
    self.backdropView.layer.shadowColor   = [UIColor blackColor].CGColor;
    self.backdropView.layer.shadowOffset  = CGSizeMake(2, 2);
    self.backdropView.layer.shadowOpacity = 0.75;
    self.backdropView.layer.shadowRadius  = 3;
}

@end
