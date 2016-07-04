//
//  NSArray+SelectCollect.h
//  BLEKit
//
//  Created by Igor Sales on 2014-10-30.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (SelectCollect)

- (id)firstObjectFromPredicate:(NSPredicate*)predicate;

@end
