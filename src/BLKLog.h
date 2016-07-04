//
//  BLKLog.h
//  BLEKit
//
//  Created by Igor Sales on 2014-09-15.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#ifdef DEBUG
#define BLK_LOG(X, ARGS...) NSLog(@"BLEKit: %s:" X, __FUNCTION__, ## ARGS);
#else
#define BLK_LOG(X, ARGS...)
#endif