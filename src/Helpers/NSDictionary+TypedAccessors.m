//
//  NSDictionary+TypedAccessors.m
//  igorsales.ca
//
//  Created by Igor Sales on 12-10-23.
//  Copyright (c) 2012 Igor Sales. All rights reserved.
//

#import "NSDictionary+TypedAccessors.h"

@implementation NSDictionary (TypedAccessors)

- (NSDictionary*)dictionaryForKey:(NSString *)key
{
    id ret = [self valueForKey:key];
    if ([ret isKindOfClass:[NSDictionary class]]) {
        return ret;
    }

    return nil;
}

- (NSArray*)arrayForKey:(NSString *)key
{
    id ret = [self valueForKey:key];
    if ([ret isKindOfClass:[NSArray class]]) {
        return ret;
    }
    
    return nil;
}

- (NSString*)stringForKey:(NSString *)key
{
    id ret = [self valueForKey:key];
    if ([ret isKindOfClass:[NSString class]]) {
        return ret;
    }
    
    return nil;
}

- (NSNumber*)numberForKey:(NSString *)key
{
    id ret = [self valueForKey:key];
    if ([ret isKindOfClass:[NSNumber class]]) {
        return ret;
    }
    
    return nil;
}

- (NSDate*)dateForKey:(NSString *)key
{
    id ret = [self valueForKey:key];
    if ([ret isKindOfClass:[NSDate class]]) {
        return ret;
    }
    
    return nil;
}

- (NSDictionary*)dictionaryForKeyPath:(NSString *)keyPath
{
    id ret = [self valueForKeyPath:keyPath];
    if ([ret isKindOfClass:[NSDictionary class]]) {
        return ret;
    }
    
    return nil;
}

- (NSArray*)arrayForKeyPath:(NSString *)keyPath
{
    id ret = [self valueForKeyPath:keyPath];
    if ([ret isKindOfClass:[NSArray class]]) {
        return ret;
    }
    
    return nil;
}

- (NSString*)stringForKeyPath:(NSString *)keyPath
{
    id ret = [self valueForKeyPath:keyPath];
    if ([ret isKindOfClass:[NSString class]]) {
        return ret;
    }
    
    return nil;
}

- (NSNumber*)numberForKeyPath:(NSString *)keyPath
{
    id ret = [self valueForKeyPath:keyPath];
    if ([ret isKindOfClass:[NSNumber class]]) {
        return ret;
    }
    
    return nil;
}

- (NSDate*)dateForKeyPath:(NSString *)keyPath
{
    id ret = [self valueForKeyPath:keyPath];
    if ([ret isKindOfClass:[NSDate class]]) {
        return ret;
    }
    
    return nil;
}

@end
