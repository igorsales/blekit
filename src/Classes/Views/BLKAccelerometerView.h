//
//  BLKAccelerometerView.h
//  BLEKit
//
//  Created by Igor Sales on 2014-11-13.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface BLKAccelerometerView : UIView

@property (nonatomic, assign, setter=setXY:) CGPoint xy;
@property (nonatomic, assign) CGFloat z;

@end
