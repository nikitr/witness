//
//  ARSPopover.h
//  Popover
//
//  Created by Yaroslav Arsenkin on 27.05.15.
//  Copyright (c) 2015 Iaroslav Arsenkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapSearchViewController.h"

@interface PopoverViewController : UIViewController

/// The view containing the anchor rectangle for the popover.
@property (nonatomic, weak) UIView *sourceView;

/// The rectangle in the specified view in which to anchor the popover.
@property (nonatomic, assign) CGRect sourceRect;

/// An array of views that the user can interact with while the popover is visible.
@property (nonatomic, strong) NSArray *passthroughViews;

///The margins that define the portion of the screen in which it is permissible to display the popover.
@property (nonatomic, assign) UIEdgeInsets popoverLayoutMargins;

@property (nonatomic, assign) UIPopoverArrowDirection arrowDirection;
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic) BOOL isVisible;
@property (nonatomic) MapSearchViewController *containingVC;
@property (nonatomic) IBOutlet UITextField *durationField;
@property (nonatomic) IBOutlet UITextView *detailsTextView;

@end
