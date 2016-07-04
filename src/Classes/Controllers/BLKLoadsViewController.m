//
//  BLKLoadsViewController.m
//  BLEKit
//
//  Created by Igor Sales on 2014-09-19.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKLoadsViewController.h"
#import "BLKLoad.h"
#import "BLKFirmwareLoadCell.h"
#import "BLKLoadManager.h"

#import "UINib+NibView.h"
#import "UIImageView+URL.h"

@interface BLKLoadsViewController () <BLKLoadManagerDelegate>

@end

@implementation BLKLoadsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.loadsManager.delegate = self;
    [self.loadsManager refresh];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - BLKLoadManagerDelegate

- (void)loadManagerDidStartRefresh:(BLKLoadManager *)manager
{
    
}

- (void)loadManagerDidEndRefresh:(BLKLoadManager *)manager
{
    
}

- (void)loadManagerDidUpdateLoads:(BLKLoadManager *)manager
{
    [self reloadData];
}

#pragma mark - Operations

- (void)reloadData
{
    for (UIView* view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }

    CGFloat x = 2;
    for (BLKLoad* load in self.loadsManager.loads) {
        BLKFirmwareLoadCell* cell = (BLKFirmwareLoadCell*)[UINib viewFromNibNamed:@"BLKFirmwareLoadCell"
                                                                                   bundle:[NSBundle bundleForClass:[self class]]
                                                                                    owner:nil];
        cell.titleLabel.text = load.name;
        cell.subtitleLabel.text = load.firmwareVersion;
        [cell.imageView setImageFromURL:load.iconURL];
        
        CGSize size = [cell.titleLabel.text sizeWithAttributes:@{
                                                                 NSFontAttributeName: cell.titleLabel.font
                                                                 }];
        if (size.width > cell.titleLabel.bounds.size.width) {
            CGFloat d = size.width - cell.titleLabel.bounds.size.width;
            cell.bounds = CGRectMake(0, 0, cell.bounds.size.width + d, cell.bounds.size.height);
        }
        
        // Drag and drop using pan        
        CGRect frame = cell.frame;
        frame.origin.x = x;
        cell.frame = frame;
        [self.scrollView addSubview:cell];
        x += cell.bounds.size.width + 4;
    }
}

#pragma mark - OBOvumSource

- (UIView*)createDragRepresentationOfSourceView:(BLKFirmwareLoadCell*)sourceView inWindow:(UIWindow*)window
{
    // Create a view that represents this source. It will be place on
    // the overlay window and hence the coordinates conversion to make
    // sure user doesn't see a jump in object location
    CGRect frameInWindow = [self.scrollView convertRect:sourceView.imageView.frame toView:sourceView.window];
    frameInWindow = [window convertRect:frameInWindow fromWindow:sourceView.window];
    
    UIImageView *dragImage = [[UIImageView alloc] initWithFrame:frameInWindow];
    dragImage.image = sourceView.imageView.image;
    dragImage.contentMode = UIViewContentModeScaleAspectFit;
    return dragImage;
}

@end
