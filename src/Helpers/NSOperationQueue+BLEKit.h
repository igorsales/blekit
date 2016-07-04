//
//  NSOperationQueue+BLEKit.h
//  BLEKit
//
//  Created by Igor Sales on 2014-10-26.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOperationQueue (BLEKit)

+ (dispatch_queue_t)BLEKitQueue;

@end
