//
//  UIImageView+URL.m
//  BLEKit
//
//  Created by Igor Sales on 2014-09-19.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "UIImageView+URL.h"

@implementation UIImageView (URL)

- (void)setImageFromURL:(NSURL *)URL
{
    NSURLRequest* req = [NSURLRequest requestWithURL:URL];

    [NSURLConnection sendAsynchronousRequest:req
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (data.length == 0 || error) {
                                   NSLog(@"Image download failed");
                               } else {
                                   UIImage* image = [UIImage imageWithData:data];
                                   self.image = image;
                               }
                           }];
}

@end
