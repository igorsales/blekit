//
//  BLKDevicesTableViewCell.h
//  BLEKit
//
//  Created by Igor Sales on 2014-09-15.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLKProgressiveBarsView;

@interface BLKDevicesTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@property (nonatomic, weak) IBOutlet UILabel* idLabel;
@property (nonatomic, weak) IBOutlet UILabel* RSSILabel;
@property (nonatomic, weak) IBOutlet UIImageView* RSSIImageView;
@property (nonatomic, weak) IBOutlet UIProgressView* progressView;
@property (nonatomic, weak) IBOutlet UILabel* statusLabel;
@property (nonatomic, weak) IBOutlet UIImageView* statusImageView;
@property (nonatomic, weak) IBOutlet UIView* dropZoneView;
@property (nonatomic, weak) IBOutlet BLKProgressiveBarsView* barsView;

- (void)setStatusString:(NSString*)status;
- (void)setStatusString:(NSString*)status success:(BOOL)success;
- (void)setProgress:(double)progress;

@end
