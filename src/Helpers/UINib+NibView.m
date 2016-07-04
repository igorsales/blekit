//
//  UINib+NibView.m
//  Igor Sales
//
//  Created by Igor Sales on 2012-12-19.
//  Copyright (c) 2012 Igor Sales. All rights reserved.
//

#import "UINib+NibView.h"

@implementation UINib (NibView)

+ (UIView*)viewFromNibNamed:(NSString*)nibName bundle:(NSBundle*)bundleOrNil
{
    return [self viewFromNibNamed:nibName bundle:bundleOrNil owner:nil];
}

+ (UIView*)viewFromNibNamed:(NSString*)nibName bundle:(NSBundle*)bundleOrNil owner:(id)owner
{
    UINib* nib = [UINib nibWithNibName:nibName bundle:bundleOrNil];
    NSArray* views = [nib instantiateWithOwner:owner options:nil];
    
    if (views.count) {
        return [views objectAtIndex:0];
    }
    
    return nil;
}

@end
