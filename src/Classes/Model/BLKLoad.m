//
//  BLKLoad.m
//  BLEKit
//
//  Created by Igor Sales on 2014-09-19.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKLoad.h"
#import "NSDictionary+TypedAccessors.h"

@interface BLKLoad() <NSCoding>

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* hardwareID;
@property (nonatomic, strong) NSString* firmwareID;
@property (nonatomic, strong) NSString* hardwareVersion;
@property (nonatomic, strong) NSString* firmwareVersion;
@property (nonatomic, strong) NSURL* iconURL;
@property (nonatomic, strong) NSURL* firmwareURL;

@property (nonatomic, strong) NSDate* updatedTime;

@end

static NSDateFormatter* sParser = nil;

@implementation BLKLoad

#pragma mark - Class methods

+ (void)initialize
{
    if (sParser == nil) {
        sParser = [NSDateFormatter new];
        sParser.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZ";
    }
}

#pragma mark - Setup/teardown

- (id)initWithDictionary:(NSDictionary *)dict
{
    if ((self = [super init])) {
        self.name            = [dict stringForKey:@"name"];
        self.hardwareID      = [dict stringForKey:@"hw_id"];
        self.firmwareID      = [dict stringForKey:@"fw_id"];
        self.firmwareVersion = [dict stringForKey:@"fw_version"];
        self.hardwareVersion = [dict stringForKey:@"hw_version"];
        self.firmwareURL     = [NSURL URLWithString:[dict stringForKey:@"fw_url"]];
        self.iconURL         = [NSURL URLWithString:[dict stringForKey:@"icon_url"]];
        self.updatedTime     = [sParser dateFromString:[dict stringForKey:@"updated_at"]];
    }

    return self;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init])) {
        self.name            = [aDecoder decodeObjectForKey:@"name"];
        self.firmwareID      = [aDecoder decodeObjectForKey:@"hw_id"];
        self.hardwareID      = [aDecoder decodeObjectForKey:@"fw_id"];
        self.firmwareVersion = [aDecoder decodeObjectForKey:@"hw_version"];
        self.hardwareVersion = [aDecoder decodeObjectForKey:@"fw_version"];
        self.firmwareURL     = [aDecoder decodeObjectForKey:@"fw_url"];
        self.iconURL         = [aDecoder decodeObjectForKey:@"icon_url"];
        self.updatedTime     = [aDecoder decodeObjectForKey:@"updated_at"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.hardwareID forKey:@"hw_id"];
    [aCoder encodeObject:self.firmwareID forKey:@"fw_id"];
    [aCoder encodeObject:self.hardwareVersion forKey:@"hw_version"];
    [aCoder encodeObject:self.firmwareVersion forKey:@"fw_version"];
    [aCoder encodeObject:self.firmwareURL forKey:@"fw_url"];
    [aCoder encodeObject:self.iconURL forKey:@"icon_url"];
    [aCoder encodeObject:self.updatedTime forKey:@"updated_at"];
}

@end
