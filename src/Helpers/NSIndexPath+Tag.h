//
//  NSIndexPath+Tag.h
//  BLEKit
//
//  Created by Igor Sales on 2014-10-22.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIkit.h>

@interface NSIndexPath (Tag)

+ (NSIndexPath*)indexPathFromTag:(NSInteger)tag;
- (NSInteger)tag;

@end
