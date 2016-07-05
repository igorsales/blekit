//
//  BLKEditorUnderview.h
//  BLEKit
//
//  Created by Igor Sales on 2014-10-18.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface BLKEditorControl : UIControl

@property (nonatomic, assign) CGFloat draggableBorderWidth;

@property (nonatomic, readonly) CGSize delta;

@end
