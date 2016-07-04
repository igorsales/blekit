//
//  BLKNavigationController.m
//  BLEKit
//
//  Created by Igor Sales on 2015-04-14.
//  Copyright (c) 2015 IgorSales.ca. All rights reserved.
//

#import "BLKNavigationController.h"

@interface BLKNavigationController ()

@end

@implementation BLKNavigationController

- (BOOL)shouldAutorotate
{
    if (self.topViewController) {
        return [self.topViewController shouldAutorotate];
    }

    return [super shouldAutorotate];
}

@end
