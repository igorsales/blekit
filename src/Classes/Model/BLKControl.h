//
//  BLKControl.h
//  BLEKit
//
//  Created by Igor Sales on 2014-10-22.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIkit.h>

@class BLKConfiguration;

@interface BLKControl : NSObject

@property (nonatomic, readonly) Class viewControllerClass;
@property (nonatomic, readonly) CGRect frame;
@property (nonatomic, readonly) CGPoint center;
@property (nonatomic, weak)     BLKConfiguration* configuration;

- (id)initWithViewControllerClass:(Class)viewControllerClass;

- (void)bindTo:(id)object properties:(NSArray*)properties;
- (void)unbindProperties:(NSArray*)properties from:(id)object;
- (void)applyProperties:(NSArray*)properties to:(id)object;

@end
