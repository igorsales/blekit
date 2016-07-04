//
//  BLKLoad.h
//  BLEKit
//
//  Created by Igor Sales on 2014-09-19.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLKLoad : NSObject

@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSString* hardwareID;
@property (nonatomic, readonly) NSString* firmwareID;
@property (nonatomic, readonly) NSString* hardwareVersion;
@property (nonatomic, readonly) NSString* firmwareVersion;
@property (nonatomic, readonly) NSURL* iconURL;
@property (nonatomic, readonly) NSURL* firmwareURL;

@property (nonatomic, readonly) NSDate* updatedTime;

- (id)initWithDictionary:(NSDictionary*)dict;

@end
