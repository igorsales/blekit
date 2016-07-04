//
//  BLKEditorViewController.h
//  BLEKit
//
//  Created by Igor Sales on 2014-10-18.
//  Copyright (c) 2014 IgorSales.ca. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    BLKEditorPositionTopCentre,
    BLKEditorPositionRightCentre,
    BLKEditorPositionBottomCentre,
    BLKEditorPositionLeftCentre,

    BLKEditorPositionMax,
    BLKEditorPositionFirst = BLKEditorPositionTopCentre,
} BLKEditorPosition;

@class BLKEditorViewController;

@protocol BLKEditorContainerDelegate <NSObject>

- (void)editor:(BLKEditorViewController*)editor wantsViewControllerDeleted:(UIViewController*)viewController;
- (void)editor:(BLKEditorViewController *)editor movedViewController:(UIViewController*)viewController;

@end

@protocol BLKEditorDelegate <NSObject>

@optional
- (UIViewController*)editor:(BLKEditorViewController*)editor settingsViewControllerForButtonPosition:(BLKEditorPosition)position;

@end

@protocol BLKEditorDataSource <NSObject>

@optional
- (NSString*)editor:(BLKEditorViewController*)editor titleForSettingsButtonAtPosition:(BLKEditorPosition)position;
- (NSString*)editor:(BLKEditorViewController *)editor keyPathToBindForPropertyAtPosition:(BLKEditorPosition)position;
- (id)editor:(BLKEditorViewController*)editor objectToBindForPropertyAtPosition:(BLKEditorPosition)position;

@end

@interface BLKEditorViewController : UIViewController

@property (nonatomic, readonly) UIView*           editingView;
@property (nonatomic, weak)     UIViewController* editingViewController;

@property (nonatomic, weak)     id containerDelegate;
@property (nonatomic, weak)     id delegate;

- (void)centreInParentAndFadeToShowAnimated:(BOOL)animated;
- (void)updateButtonTitles;
- (void)updateButtonTitleAtPosition:(BLKEditorPosition)position;
- (void)updateButton:(UIButton*)button withTitle:(NSString*)title atPosition:(BLKEditorPosition)position;
- (UIButton*)buttonAtPosition:(BLKEditorPosition)position;

@end
