//
//  NSFileManager+Dirs.m
//  BLEKit
//
//  Created by Igor Sales on 2014-10-28.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "NSFileManager+Dirs.h"

@implementation NSFileManager (Dirs)

+ (NSString*)documentsDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    return paths.count ? paths[0] : nil;
}

@end
