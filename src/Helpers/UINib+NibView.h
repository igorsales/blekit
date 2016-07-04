//
//  UINib+NibView.h
//  Igor Sales
//
//  Created by Igor Sales on 2012-12-19.
//  Copyright (c) 2012 Igor Sales. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINib (NibView)

+ (UIView*)viewFromNibNamed:(NSString*)nibName bundle:(NSBundle*)bundleOrNil;
+ (UIView*)viewFromNibNamed:(NSString*)nibName bundle:(NSBundle*)bundleOrNil owner:(id)owner;

@end
