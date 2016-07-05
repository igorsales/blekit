//
//  BLKContainerViewController.m
//  BLEKit
//
//  Created by Igor Sales on 2014-10-18.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKContainerViewController.h"
#import "BLKEditorViewController.h"
#import "BLKControlViewControllerProtocol.h"
#import "BLKControl.h"
#import "BLKConfiguration.h"
#import "BLKManager.h"
#import "BLKPort.h"
#import "BLKDevice.h"
#import "BLKProgressiveBarsView.h"
#import "BLKControllerRotationManager.h"

#import <QuartzCore/QuartzCore.h>

@interface BLKContainerViewController () <BLKEditorContainerDelegate, BLKControllerRotationManagerDelegate> {
    BOOL _setupEditButtonItem;
    BOOL _avoidUpdatingControlsOnViewWillAppear;
}

@property (nonatomic, strong) BLKConfiguration* placeholderConfiguration;
@property (nonatomic, strong) NSArray* editorViewControllers;

@property (nonatomic, strong) IBOutlet BLKControllerRotationManager* rotationManager;

@property (nonatomic, weak) IBOutlet UIView* contentView;
@property (nonatomic, weak) IBOutlet BLKProgressiveBarsView* barsView;
@property (nonatomic, weak) IBOutlet UIView* connectionStatusView;
@property (nonatomic, weak) IBOutlet UISwitch* lockOrientationSwitch;

@end

@implementation BLKContainerViewController

#pragma mark - Setup/teardown

- (void)dealloc
{
    [self unbindFromConfiguration:_configuration];
}

#pragma mark - Accessors

@synthesize configuration = _configuration;

- (BLKConfiguration*)placeholderConfiguration
{
    if (!_placeholderConfiguration) {
        _placeholderConfiguration = [self.manager deserializedConfigurationForDevice:nil];
        if (!_placeholderConfiguration) {
            _placeholderConfiguration = [BLKConfiguration new];
        }
    }

    return _placeholderConfiguration;
}

- (BLKConfiguration*)configuration
{
    if (!_configuration) {
        return self.placeholderConfiguration;
    }

    return _configuration;
}

- (void)setConfiguration:(BLKConfiguration *)configuration
{
    if (_configuration != configuration) {
        [self serializeConfiguration];
        
        [self unbindFromConfiguration:_configuration];

        if (self.editing) {
            [self setEditing:NO animated:NO];
        }
        
        _configuration = configuration;
        
        [self bindToConfiguration:_configuration];
        
        [self updateContainedViews];
        [self connectControlsToPorts];
    }
}

#pragma mark - Private

- (void)serializeConfiguration
{
    if (!_configuration) { // store the placeholder configuration
        [self.manager serializeConfiguration:_placeholderConfiguration];
    } else {
        [self.manager serializeConfiguration:_configuration];
    }
}

- (void)deserializePlaceholderConfiguration
{
    _placeholderConfiguration = [self.manager deserializedConfigurationForDevice:nil];
}

- (NSArray*)nonEditorViewControllers
{
    NSMutableArray* vcs = [NSMutableArray new];

    [self.childViewControllers enumerateObjectsUsingBlock:^(UIViewController* vc, NSUInteger idx, BOOL *stop) {
        if (![vc isKindOfClass:[BLKEditorViewController class]]) {
            [vcs addObject:vc];
        }
    }];

    return vcs;
}

- (NSArray*)attachedEditorsToContainerViewControllers:(NSArray*)vcs
{
    NSMutableArray* evcs = [NSMutableArray new];

    for (UIViewController* vc in vcs) {
        BLKEditorViewController* editor = [BLKEditorViewController new];
        
        [self addChildViewController:editor];
        [self.contentView addSubview:editor.view];
        editor.delegate = vc;
        editor.containerDelegate = self;
        editor.editingViewController = vc;
        
        [evcs addObject:editor];
    }

    return evcs;
}

- (void)detachEditorsFromContainerViewControllers:(NSArray*)vcs
{
    for (BLKEditorViewController* editorVC in vcs) {
        if ([editorVC isKindOfClass:[BLKEditorViewController class]]) {
            [editorVC didMoveToParentViewController:nil];
            [editorVC removeFromParentViewController];
            [editorVC.view removeFromSuperview];
            editorVC.editingViewController = nil;
        }
    }
}

- (UIViewController*)addNewWidgetForControl:(BLKControl*)control
{
    if (!self.contentView) {
        // TODO: Improve this, so we don't have to force the view to load
        if (self.view) {
            NSLog(@"Loaded view");
        }
    }
    UIViewController* newVC = [[control.viewControllerClass alloc] initWithNibName:nil bundle:nil];
    
    if ([newVC respondsToSelector:@selector(setControl:)]) {
        [(id<BLKControlViewControllerProtocol>)newVC setControl:control];
    }
    
    [self addChildViewController:newVC];
    [self.contentView addSubview:newVC.view];
    [newVC didMoveToParentViewController:self];
    
    if (self.editing) {
        BLKEditorViewController* editorVC = [BLKEditorViewController new];
        
        [self addChildViewController:editorVC];
        [self.contentView addSubview:editorVC.view];
        editorVC.delegate = newVC;
        editorVC.editingViewController = newVC;
        editorVC.containerDelegate = self;
        
        self.editorViewControllers = [self.editorViewControllers arrayByAddingObject:editorVC];
        
        [editorVC centreInParentAndFadeToShowAnimated:YES];
    }
    
    return newVC;
}

- (UIViewController*)addNewWidgetForClass:(Class)cls
{
    BLKControl* control = [[BLKControl alloc] initWithViewControllerClass:cls];
    [self.configuration addControl:control];

    UIViewController* vc = [self addNewWidgetForControl:control];

    return vc;
}

- (void)connectControlsToPorts
{
    // TODO: Re-do this in a much better fashion
    [self.childViewControllers enumerateObjectsUsingBlock:^(UIViewController* vc, NSUInteger idx, BOOL *stop) {
        id<BLKControlViewControllerProtocol> controlSource = (id<BLKControlViewControllerProtocol>)vc;
        if ([controlSource respondsToSelector:@selector(control)]) {
            BLKControl* control = controlSource.control;
            
            if ([controlSource respondsToSelector:@selector(setControl:)]) {
                controlSource.control = control;
            }

            [BLKPort enumeratePortTypesForViewControllerClass:[vc class]
                                                      withBlock:^(NSString* type, NSString *identifier, NSInteger subindex, NSDictionary* options) {
                                                          if (!type || ![type isEqualToString:kBLKPortTypeUnknown]) {
                                                              BLKPort* port = [self.configuration.device portOfType:type
                                                                                                              atIndex:0
                                                                                                             subIndex:subindex
                                                                                                          withOptions:options];

                                                              [(id)controlSource setValue:port forKey:identifier];
                                                          }
                                                      }];
        }
        
        if ([controlSource respondsToSelector:@selector(apply:)]) {
            [controlSource apply:self];
        }
    }];
}

- (void)updateContainedViews
{
    [self.childViewControllers enumerateObjectsUsingBlock:^(UIViewController* vc, NSUInteger idx, BOOL *stop) {
        [vc didMoveToParentViewController:nil];
        [vc removeFromParentViewController];
        [vc.view removeFromSuperview];
    }];
    
    [self.configuration.controls enumerateObjectsUsingBlock:^(BLKControl* control, NSUInteger idx, BOOL *stop) {
        if (control.viewControllerClass) {
            CGRect vcFrame = control.frame;
            UIViewController* vc = [self addNewWidgetForControl:control];
            if (vcFrame.size.width && vcFrame.size.height) {
                vc.view.frame = vcFrame;
            }
        } else {
            NSLog(@"Discarding control with no view controller information");
        }
    }];
}

- (void)bindToConfiguration:(BLKConfiguration*)cfg
{
    [cfg addObserver:self forKeyPath:@"device.state" options:0 context:nil];
    [cfg addObserver:self forKeyPath:@"device.signalStrength" options:0 context:nil];
}

- (void)unbindFromConfiguration:(BLKConfiguration*)cfg
{
    [cfg removeObserver:self forKeyPath:@"device.state"];
    [cfg removeObserver:self forKeyPath:@"device.signalStrength"];
}

- (void)prepareConnectionStatusView
{
    self.connectionStatusView.layer.cornerRadius = self.connectionStatusView.bounds.size.width / 2;
    self.connectionStatusView.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.73].CGColor;
    self.connectionStatusView.layer.borderWidth = 2.0;
    self.connectionStatusView.layer.masksToBounds = YES;
}

- (void)updateSignalStrength
{
    if (self.configuration.device) {
        self.barsView.hidden = NO;
        // update with formula: 10 ^ [ (RSSI - A)/n ]
        self.barsView.signal = (127.0 + self.configuration.device.signalStrength) / 255.0;
    } else {
        self.barsView.hidden = YES;
    }
}

- (void)updateConnectionStatus
{
    self.connectionStatusView.hidden = self.configuration.device == nil;

    BOOL hideStatusView = NO;
    UIColor* colour = nil;
    switch (self.configuration.device.state) {
        case BLKDeviceStateConnected: colour = nil; hideStatusView = YES; break;
        case BLKDeviceStateConnecting: colour = [UIColor orangeColor]; break;
        case BLKDeviceStateDisconnected: colour = [UIColor yellowColor]; break;

        default: colour = [UIColor redColor]; break;
    }
    
    self.connectionStatusView.hidden = hideStatusView;
    self.connectionStatusView.backgroundColor = [colour colorWithAlphaComponent:0.73];
    self.barsView.hidden = colour != nil;
}

- (void)bringOutOfSightControllersIn
{
    [self.childViewControllers enumerateObjectsUsingBlock:^(UIViewController* vc, NSUInteger idx, BOOL *stop) {
        CGRect frame = vc.view.frame;
        if (frame.origin.x < 0 || frame.origin.y < 0) {
            frame.origin.x = frame.origin.y = 0;
            vc.view.frame = frame;
        } else {
            BOOL update = NO;
            if (frame.origin.x + frame.size.width > self.view.bounds.size.width) {
                frame.origin.x = self.view.bounds.size.width - frame.size.width;
                update = YES;
            }
            
            if (frame.origin.y + frame.size.height > self.view.bounds.size.height) {
                frame.origin.y = self.view.bounds.size.height - frame.size.height;
                update = YES;
            }
            
            if (update) {
                vc.view.frame = frame;
            }
        }
    }];
}

#pragma mark - Overrides

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self prepareConnectionStatusView];
    [self deserializePlaceholderConfiguration];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNavigationBar:)]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (!_setupEditButtonItem) {
        _setupEditButtonItem = YES;
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }

    if (_avoidUpdatingControlsOnViewWillAppear) {
        _avoidUpdatingControlsOnViewWillAppear = YES;
        [self updateContainedViews];
        [self connectControlsToPorts];
    }

    [self updateSignalStrength];
    [self updateConnectionStatus];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.rotationManager.orientation = [UIDevice currentDevice].orientation;
    [self.rotationManager start:self];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.rotationManager stop:self];

    [super viewDidDisappear:animated];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (BOOL)shouldAutorotate
{
    return !self.lockOrientationSwitch.on;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    if (!editing) {
        [self saveConfiguration:self];
        [self setToolbarItems:nil animated:YES];
        [self.navigationController setToolbarHidden:YES animated:YES];
        [self detachEditorsFromContainerViewControllers:self.editorViewControllers];
        self.editorViewControllers = nil;
        [self connectControlsToPorts];
    } else {
        [self bringOutOfSightControllersIn];
        UIBarButtonItem* spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:nil
                                                                                action:nil];
        UIBarButtonItem* addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                   target:self
                                                                                   action:@selector(addWidget:)];
        NSArray* items = @[spacer, addButton];
        [self setToolbarItems:items animated:NO];
        [self.navigationController setToolbarHidden:NO animated:YES];
        self.editorViewControllers = [self attachedEditorsToContainerViewControllers:self.childViewControllers];
    }
}

#pragma mark - Operations

#pragma mark - Actions

- (IBAction)addWidget:(UIBarButtonItem*)sender
{
    UIAlertController* sheet = [UIAlertController alertControllerWithTitle:@"Add Widget"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (NSDictionary* portType in [BLKPort controlPortTypes]) {
        [sheet addAction:[UIAlertAction actionWithTitle:portType[kBLKPortWidgetName]
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction* action) {
                                                    Class klass = NSClassFromString(portType[kBLKPortViewControllerClassName]);
                                                    [self addNewWidgetForClass:klass];
                                                }]];
    }
    
    [sheet addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];

    
    [self presentViewController:sheet animated:YES completion:nil];
}

- (IBAction)saveConfiguration:(id)sender
{
    [self.manager serializeConfiguration:self.configuration];
}

- (IBAction)toggleNavigationBar:(id)sender
{
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
}

#pragma mark - BLKEditorContainerDelegate

- (void)editor:(BLKEditorViewController *)editor wantsViewControllerDeleted:(UIViewController *)viewController
{
    BLKControl* control = nil;
    if ([viewController respondsToSelector:@selector(control)]) {
        control = [(id<BLKControlViewControllerProtocol>)viewController control];
    }

    [self detachEditorsFromContainerViewControllers:@[editor]];

    [viewController didMoveToParentViewController:nil];
    [viewController removeFromParentViewController];
    [viewController.view removeFromSuperview];
    
    [self.configuration removeControl:control];
}

- (void)editor:(BLKEditorViewController *)editor movedViewController:(UIViewController *)viewController
{
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"device.state"]) {
        [self updateConnectionStatus];
    } else if ([keyPath isEqualToString:@"device.signalStrength"]) {
        [self updateSignalStrength];
    }
}

#pragma mark - BLKControllerRotationManagerDelegate

- (void)manager:(BLKControllerRotationManager *)manager userDidTiltToDegrees:(CGFloat)tilt angle:(CGFloat)angle
{
    [self.childViewControllers enumerateObjectsUsingBlock:^(id cvc, NSUInteger idx, BOOL *stop) {
        if ([cvc conformsToProtocol:@protocol(BLKControllerRotationObserver)]) {
            [cvc observeAngle:angle tilt:tilt];
        }
    }];
}

@end
