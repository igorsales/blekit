//
//  NSDictionary+TypedAccessors.h
//  igorsales.ca
//
//  Created by Igor Sales on 12-10-23.
//  Copyright (c) 2012 Igor Sales. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (TypedAccessors)

- (NSString*)stringForKey:(NSString*)key;
- (NSArray*)arrayForKey:(NSString*)key;
- (NSDictionary*)dictionaryForKey:(NSString*)key;
- (NSNumber*)numberForKey:(NSString*)key;
- (NSDate*)dateForKey:(NSString*)key;

- (NSString*)stringForKeyPath:(NSString*)keyPath;
- (NSArray*)arrayForKeyPath:(NSString*)keyPath;
- (NSDictionary*)dictionaryForKeyPath:(NSString*)keyPath;
- (NSNumber*)numberForKeyPath:(NSString*)keyPath;
- (NSDate*)dateForKeyPath:(NSString*)keyPath;

@end
