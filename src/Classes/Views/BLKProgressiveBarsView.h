//
//  BLKProgressiveBarsView.h
//  BLEKit
//
//  Created by Igor Sales on 2014-12-01.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface BLKProgressiveBarsView : UIView

@property (nonatomic, assign) CGFloat signalLowerBound;
@property (nonatomic, assign) CGFloat signalUpperBound;
@property (nonatomic, assign) CGFloat signal;

@end
