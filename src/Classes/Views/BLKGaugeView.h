//
//  BLKGaugeView.h
//  BLEKit
//
//  Created by Igor Sales on 2015-06-10.
//  Copyright (c) 2015 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface BLKGaugeView : UIView

@property (nonatomic, strong) UIColor* fillColor;
@property (nonatomic, assign) CGFloat minimumValue;
@property (nonatomic, assign) CGFloat maximumValue;
@property (nonatomic, assign) CGFloat value;

@property (nonatomic, weak)   IBOutlet UILabel* readingLabel;

@end
