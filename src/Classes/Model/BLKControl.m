//
//  BLKControl.m
//  BLEKit
//
//  Created by Igor Sales on 2014-10-22.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKControl.h"

#import <objc/runtime.h>

@interface BLKControl() <NSCoding>

@property (nonatomic, strong) Class viewControllerClass;
@property (nonatomic, strong) NSMutableDictionary* controlProperties;

@end


@implementation BLKControl

+ (NSString*)propertyNameForSelector:(SEL)sel
{
    NSString* selStr = NSStringFromSelector(sel);
    
    if (!selStr || !selStr.length) {
        return nil;
    }
    
    NSString* propertyName = nil;
    if ([selStr hasPrefix:@"set"] && [selStr characterAtIndex:selStr.length-1] == ':') {
        // setter
        propertyName = [selStr substringWithRange:NSMakeRange(3, selStr.length-4)];
    } else {
        propertyName = selStr;
    }

    return propertyName;
}

- (CGRect)frame
{
    NSValue* value = [self.controlProperties valueForKey:@"frame"];
    return [value CGRectValue];
}

- (CGPoint)center
{
    NSValue* value = [self.controlProperties valueForKey:@"center"];
    return [value CGPointValue];
}

- (void)_setup
{
    self.controlProperties = [NSMutableDictionary new];
}

- (id)init
{
    if ((self = [super init])) {
        [self _setup];
    }
    
    return self;
}

- (id)initWithViewControllerClass:(Class)viewClass
{
    if ((self = [super init])) {
        [self _setup];
        self.viewControllerClass = viewClass;
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init])) {
        NSString* className = [aDecoder decodeObjectForKey:@"viewControllerClassName"];
        if (className) {
            self.viewControllerClass = NSClassFromString(className);
        }
        self.controlProperties = [[aDecoder decodeObjectForKey:@"controlProperties"] mutableCopy];
        if (!self.controlProperties) {
            self.controlProperties = [NSMutableDictionary new];
        }
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if (self.viewControllerClass) {
        [aCoder encodeObject:NSStringFromClass(self.viewControllerClass) forKey:@"viewControllerClassName"];
    }
    [aCoder encodeObject:self.controlProperties forKey:@"controlProperties"];
}

- (void)bindTo:(id)object properties:(NSArray*)properties
{
    for (NSString* property in properties) {
        [object addObserver:self forKeyPath:property options:NSKeyValueObservingOptionNew context:nil];
        id v = [object valueForKeyPath:property];
        if (v) {
            [self.controlProperties setValue:v forKey:property];
        }
    }
}

- (void)unbindProperties:(NSArray *)properties from:(id)object
{
    for (NSString* property in properties) {
        [object removeObserver:self forKeyPath:property];
    }
}

- (void)applyProperties:(NSArray*)properties to:(id)object
{
    [properties enumerateObjectsUsingBlock:^(NSString* key, NSUInteger idx, BOOL *stop) {
        @try {
            id v = [self.controlProperties valueForKey:key];
            if (v) {
                [object setValue:v forKeyPath:key];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Unable to set value '%@' to keyPath: '%@' on %@", object, key, self);
        }
    }];
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    NSNumber* kind = [change valueForKey:NSKeyValueChangeKindKey];
    if (kind.integerValue == NSKeyValueChangeSetting) {
        id v = [change valueForKey:NSKeyValueChangeNewKey];
        if (v) {
            [self.controlProperties setValue:v forKey:keyPath];
        }
    }
}

@end
