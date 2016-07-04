//
//  BLKEditorViewController.m
//  BLEKit
//
//  Created by Igor Sales on 2014-10-18.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import "BLKEditorViewController.h"
#import "BLKEditorControl.h"
#import "BLKControlViewControllerProtocol.h"
#import <QuartzCore/QuartzCore.h>

@interface BLKEditorViewController ()

@property (nonatomic, weak) BLKEditorControl* overview;
@property (nonatomic, weak) UIButton* deleteButton;
@property (nonatomic, assign) BOOL nextTapConfirmsDelete;

@property (nonatomic, strong) UIViewController* topCentreSettingsViewController;
@property (nonatomic, strong) UIViewController* rightCentreSettingsViewController;
@property (nonatomic, strong) UIViewController* bottomCentreSettingsViewController;
@property (nonatomic, strong) UIViewController* leftCentreSettingsViewController;

@end


static NSString* const settingsVCKey[] = {
    @"topCentreSettingsViewController",
    @"rightCentreSettingsViewController",
    @"bottomCentreSettingsViewController",
    @"leftCentreSettingsViewController",
};

@implementation BLKEditorViewController

#pragma mark - Accessors

- (UIView*)containerView
{
    return self.parentViewController.view;
}

- (UIView*)editingView
{
    return self.editingViewController.view;
}

- (void)setEditingViewController:(UIViewController *)editingViewController
{
    if (_editingViewController != editingViewController) {
        _editingViewController = editingViewController;
        [self updateEditingView];
        [self updateDeleteButton];
    }
}

#pragma mark - Setup/teardown

- (void)unbindFromSettingsControllers
{
    [self unbind:(id<BLKEditorDataSource>)self.topCentreSettingsViewController    fromLabelAtPosition:BLKEditorPositionTopCentre];
    [self unbind:(id<BLKEditorDataSource>)self.rightCentreSettingsViewController  fromLabelAtPosition:BLKEditorPositionRightCentre];
    [self unbind:(id<BLKEditorDataSource>)self.bottomCentreSettingsViewController fromLabelAtPosition:BLKEditorPositionBottomCentre];
    [self unbind:(id<BLKEditorDataSource>)self.leftCentreSettingsViewController   fromLabelAtPosition:BLKEditorPositionLeftCentre];
}

- (void)dealloc
{
    //[self unbindFromSettingsControllers];
}

#pragma mark - View overrides

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateEditingView];
    [self updateDeleteButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self unbindFromSettingsControllers];

    [super viewWillDisappear:animated];
}

#pragma mark - Private

- (void)updateEditingView
{
    [self.overview removeFromSuperview];

    if (self.editingView && self.containerView) {
        CGRect frame = [self.containerView convertRect:self.editingView.bounds fromView:self.editingView];
        BLKEditorControl* overview = [[BLKEditorControl alloc] initWithFrame:CGRectInset(frame, -32, -32)];
        overview.draggableBorderWidth = 32.0;

        [self.containerView insertSubview:overview aboveSubview:self.editingView];
        
        overview.backgroundColor  = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
        overview.layer.cornerRadius = 8.0;
        overview.layer.shadowColor  = [UIColor darkGrayColor].CGColor;
        overview.layer.shadowOffset = CGSizeMake(1, 1);
        overview.layer.borderColor  = [UIColor blackColor].CGColor;
        overview.layer.borderWidth  = 1.0;
        
        [overview addTarget:self action:@selector(viewMoved:) forControlEvents:UIControlEventValueChanged];

        self.overview = overview;
        [self updateControlButtonsOnOverview:self.overview];
    }
}

- (void)updateDeleteButton
{
    if (!self.overview) {
        return;
    }

    // Add the delete button
    UIButton* delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [delBtn setImage:[UIImage imageNamed:@"red_delete_minus"] forState:UIControlStateNormal];
    delBtn.bounds = CGRectMake(0, 0, self.overview.draggableBorderWidth, self.overview.draggableBorderWidth);
    delBtn.autoresizingMask = UIViewAutoresizingNone;
    [self.overview addSubview:delBtn];
    delBtn.center = CGPointMake(self.overview.bounds.size.width - 1.5 * self.overview.draggableBorderWidth - 4,
                                1.5 * self.overview.draggableBorderWidth + 4);
    [delBtn addTarget:self action:@selector(deleteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.deleteButton = delBtn;
}

- (void)updateDraggingHandlesOnOverview:(BLKEditorControl*)overview
{
    UIImage*     image     = [UIImage imageNamed:@"dragging_handle"];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    [overview addSubview:imageView];
}

- (void)adjustButton:(UIButton*)button toOverview:(UIView*)overview
{
    CGSize size = [[button titleForState:UIControlStateNormal] sizeWithAttributes:@{
                                                                                    NSFontAttributeName: button.titleLabel.font
                                                                                    }];
    button.bounds = CGRectMake(0, 0, size.width + 8, size.height + 2);
    
    switch (button.tag) {
        case BLKEditorPositionRightCentre: button.transform = CGAffineTransformMakeRotation(M_PI_2); break;
        case BLKEditorPositionLeftCentre:  button.transform = CGAffineTransformMakeRotation(-M_PI_2); break;
    }
}

- (void)addButton:(UIButton*)button toOverview:(UIView*)overview
{
    button.layer.cornerRadius = 8.0;
    button.layer.borderWidth = 1.0;
    button.layer.borderColor = overview.tintColor.CGColor;
    [overview addSubview:button];
    [self adjustButton:button toOverview:overview];
}

- (CGPoint)centreForButtonAtPosition:(BLKEditorPosition)position onOverview:(BLKEditorControl*)overview
{
    switch (position) {
        case BLKEditorPositionTopCentre:    return CGPointMake(overview.bounds.size.width / 2,
                                                                 overview.draggableBorderWidth / 2);
        case BLKEditorPositionRightCentre:  return CGPointMake(overview.bounds.size.width - overview.draggableBorderWidth / 2,
                                                                 overview.bounds.size.height / 2);
        case BLKEditorPositionBottomCentre: return CGPointMake(overview.bounds.size.width / 2,
                                                                 overview.bounds.size.height - overview.draggableBorderWidth / 2);
        case BLKEditorPositionLeftCentre:   return CGPointMake(overview.draggableBorderWidth / 2,
                                                                 overview.bounds.size.height / 2);

        default: return CGPointMake(0, 0);
    }
}

- (void)bind:(id<BLKEditorDataSource>)source toLabelAtPosition:(BLKEditorPosition)position
{
    NSString* keyPath = nil;
    id boundObject = nil;
    if ([source respondsToSelector:@selector(editor:keyPathToBindForPropertyAtPosition:)] &&
        [source respondsToSelector:@selector(editor:objectToBindForPropertyAtPosition:)]) {
        keyPath     = [source editor:self keyPathToBindForPropertyAtPosition:position];
        boundObject = [source editor:self objectToBindForPropertyAtPosition:position];
        
        if (keyPath.length && boundObject) {
            [boundObject addObserver:self
                          forKeyPath:keyPath
                             options:0
                             context:(void*)position];
        }
    }
}

- (void)unbind:(id<BLKEditorDataSource>)source fromLabelAtPosition:(BLKEditorPosition)position
{
    NSString* keyPath = nil;
    id boundObject = nil;
    if ([source respondsToSelector:@selector(editor:keyPathToBindForPropertyAtPosition:)] &&
        [source respondsToSelector:@selector(editor:objectToBindForPropertyAtPosition:)]) {
        keyPath     = [source editor:self keyPathToBindForPropertyAtPosition:position];
        boundObject = [source editor:self objectToBindForPropertyAtPosition:position];
        
        if (keyPath.length && boundObject) {
            [boundObject removeObserver:self forKeyPath:keyPath];
        }
    }
}

- (void)updateControlButtonsOnOverview:(BLKEditorControl*)overview
{
    // query the data source
    if ([self.delegate respondsToSelector:@selector(editor:settingsViewControllerForButtonPosition:)]) {
        UIButton* button = nil;
        UIViewController* contentVC = nil;

        for (BLKEditorPosition position = BLKEditorPositionFirst; position < BLKEditorPositionMax; position++) {
            if ((contentVC = [self.delegate editor:self settingsViewControllerForButtonPosition:position])) {
                button = [UIButton buttonWithType:UIButtonTypeSystem];
                button.center = [self centreForButtonAtPosition:position onOverview:overview];
                button.tag = position;
                
                NSString* title = nil;
                if ([contentVC respondsToSelector:@selector(editor:titleForSettingsButtonAtPosition:)]) {
                    title = [(id<BLKEditorDataSource>)contentVC editor:self titleForSettingsButtonAtPosition:position];
                }
                
                [self bind:(id<BLKEditorDataSource>)contentVC toLabelAtPosition:position];
                
                [button setTitle:title forState:UIControlStateNormal];
                [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
                [self addButton:button toOverview:overview];
                [self setValue:contentVC forKey:settingsVCKey[position]];
            }
        }
    }
}

- (void)presentSettingsViewController:(UIViewController*)contentVC fromView:(UIView*)sender
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIPopoverController* pc = [[UIPopoverController alloc] initWithContentViewController:contentVC];
        
        [pc presentPopoverFromRect:sender.bounds
                            inView:sender
          permittedArrowDirections:UIPopoverArrowDirectionAny
                          animated:YES];
    } else {
        if (self.navigationController.navigationBarHidden) {
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        }
        [self.navigationController pushViewController:contentVC animated:YES];
    }
}

#pragma mark - Operations

- (UIButton*)buttonAtPosition:(BLKEditorPosition)position
{
    for (UIButton* button in self.overview.subviews) {
        if (![button isKindOfClass:[UIButton class]]) {
            continue;
        }
        
        if (button.tag == position) {
            return button;
        }
    }

    return nil;
}

- (void)updateButton:(UIButton*)button withTitle:(NSString*)title atPosition:(BLKEditorPosition)position
{
    [button setTitle:title forState:UIControlStateNormal];
    [self adjustButton:button toOverview:self.overview];
}

- (void)updateButtonTitles
{
    for (UIButton* button in self.overview.subviews) {
        if (![button isKindOfClass:[UIButton class]]) {
            continue;
        }

        BLKEditorPosition position = (BLKEditorPosition)button.tag;
        UIViewController* contentVC = [self valueForKey:settingsVCKey[position]];
        if (contentVC) {
            NSString* title = nil;
            if ([contentVC respondsToSelector:@selector(editor:titleForSettingsButtonAtPosition:)]) {
                title = [(id<BLKEditorDataSource>)contentVC editor:self titleForSettingsButtonAtPosition:position];
                [self updateButton:button withTitle:title atPosition:position];
            }
        }
    }
}

- (void)updateButtonTitleAtPosition:(BLKEditorPosition)position
{
    UIViewController* contentVC = [self valueForKey:settingsVCKey[position]];
    if (contentVC) {
        NSString* title = nil;
        if ([contentVC respondsToSelector:@selector(editor:titleForSettingsButtonAtPosition:)]) {
            title = [(id<BLKEditorDataSource>)contentVC editor:self titleForSettingsButtonAtPosition:position];
            [self updateButton:[self buttonAtPosition:position] withTitle:title atPosition:position];
        }
    }
}

- (void)centreInParentAndFadeToShowAnimated:(BOOL)animated
{
    CGFloat dx = (self.parentViewController.view.bounds.size.width  - self.overview.bounds.size.width) / 2;
    CGFloat dy = (self.parentViewController.view.bounds.size.height - self.overview.bounds.size.height) / 2;

    self.editingView.frame = CGRectMake(self.editingView.frame.origin.x + dx,
                                        self.editingView.frame.origin.y + dy,
                                        self.editingView.frame.size.width,
                                        self.editingView.frame.size.height);
    self.overview.frame    = CGRectMake(self.overview.frame.origin.x + dx,
                                        self.overview.frame.origin.y + dy,
                                        self.overview.frame.size.width,
                                        self.overview.frame.size.height);
    
    if (animated) {
        self.overview.transform = CGAffineTransformMakeScale(0.3, 0.3);
        self.overview.alpha = 0.0;
        self.editingView.transform = CGAffineTransformMakeScale(0.3, 0.3);
        self.editingView.alpha = 0.0;

        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        self.overview.transform = CGAffineTransformIdentity;
        self.overview.alpha = 1.0;
        self.editingView.transform = CGAffineTransformIdentity;
        self.editingView.alpha = 1.0;
        [UIView commitAnimations];
    }
}

#pragma mark - Actions

- (IBAction)viewMoved:(BLKEditorControl*)underview;
{
#define MOVE_VIEW(V) \
    V.frame = CGRectMake(V.frame.origin.x + underview.delta.width, \
                         V.frame.origin.y + underview.delta.height, \
                         V.frame.size.width, V.frame.size.height)
    
    MOVE_VIEW(self.editingView);
    MOVE_VIEW(self.view);
    MOVE_VIEW(self.overview);

    [self.containerDelegate editor:self movedViewController:self.editingViewController];
}

- (IBAction)buttonTapped:(UIButton*)sender
{
    BLKEditorPosition position = (BLKEditorPosition)sender.tag;
    UIViewController* contentVC = [self valueForKey:settingsVCKey[position]];
    
    [self presentSettingsViewController:contentVC fromView:sender];
}

- (IBAction)deleteButtonTapped:(id)sender
{
    if (self.nextTapConfirmsDelete) {
        //[self unbindFromSettingsControllers];
        [self.containerDelegate editor:self wantsViewControllerDeleted:self.editingViewController];
    } else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        self.deleteButton.transform = CGAffineTransformMakeRotation(-M_PI_2);
        [UIView commitAnimations];
        
        UIGestureRecognizer* tapOutsideRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelDelete:)];
        [self.overview addGestureRecognizer:tapOutsideRecognizer];
        self.nextTapConfirmsDelete = YES;
    }
}

- (IBAction)cancelDelete:(id)sender
{
    [self.overview removeGestureRecognizer:sender];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    self.deleteButton.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];

    self.nextTapConfirmsDelete = NO;
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSNumber* kind = [change valueForKey:NSKeyValueChangeKindKey];
    if ([kind integerValue] == NSKeyValueChangeSetting) {
        BLKEditorPosition position = (BLKEditorPosition)context;
        [self updateButtonTitleAtPosition:position];
    }
}

@end
