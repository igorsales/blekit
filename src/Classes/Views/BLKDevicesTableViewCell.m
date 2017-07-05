//
//  BLKDevicesTableViewCell.m
//  BLEKit
//
//  Created by Igor Sales on 2014-09-15.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKDevicesTableViewCell.h"
#import "UIImage+BLK.h"
#import <QuartzCore/QuartzCore.h>

@implementation BLKDevicesTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.dropZoneView.layer.borderWidth  = 2.5;
    self.dropZoneView.layer.borderColor  = [UIColor blueColor].CGColor;
    self.dropZoneView.layer.cornerRadius = 8.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setStatusString:(NSString *)status
{
    if (status.length) {
        self.statusLabel.textColor = [UIColor blackColor];
        self.statusLabel.hidden    = NO;
        self.statusLabel.text      = status;
    } else {
        self.statusLabel.hidden    = YES;
    }
}

- (void)setStatusString:(NSString *)status success:(BOOL)success
{
    if (status.length) {
        self.statusLabel.hidden = NO;
        self.statusImageView.hidden = NO;
        self.progressView.hidden = YES;
        self.statusLabel.text = status;
        
        if (success) {
            self.statusLabel.textColor = [UIColor blackColor];
            self.statusImageView.image = [UIImage BLKIconCheckImage];
        } else {
            self.statusLabel.textColor = [UIColor redColor];
            self.statusImageView.image = [UIImage BLKIconErrorImage];
        }
    } else {
        self.statusLabel.hidden = self.statusImageView.hidden = YES;
    }
}

- (void)setProgress:(double)progress
{
    self.statusLabel.hidden     = YES;
    self.statusImageView.hidden = YES;
    self.progressView.hidden    = NO;
    self.progressView.progress  = progress;
}

@end
