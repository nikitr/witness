//
//  ProfilePopupViewController.m
//  Maps
//
//  Created by Sean Vasquez on 7/15/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import "ProfilePopupViewController.h"
#import <Parse/Parse.h>

@interface ProfilePopupViewController () <UIPopoverPresentationControllerDelegate>

@property (nonatomic) IBOutlet UILabel *user;
@property (nonatomic) IBOutlet UIImageView *verified;
@property (nonatomic) IBOutlet UIImageView *registered;

@end

@implementation ProfilePopupViewController

#pragma mark Initialization

- (instancetype)init {
  if (self = [super init]) {
    self.modalPresentationStyle = UIModalPresentationPopover;
    self.popoverPresentationController.delegate = self;
  }
  return self;
}

#pragma mark - View Controller's Life Cycle

- (void)viewDidLoad {
  [super viewDidLoad];
  self.user.text = [PFUser currentUser].username;

}

#pragma mark - Actions

- (void)closePopover {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Popover Presentation Controller Delegate

- (void)prepareForPopoverPresentation:(UIPopoverPresentationController *)popoverPresentationController {
  self.popoverPresentationController.sourceView = self.sourceView ? self.sourceView : self.view;
  self.popoverPresentationController.sourceRect = self.sourceRect;
  self.preferredContentSize = self.contentSize;
  
  popoverPresentationController.permittedArrowDirections = self.arrowDirection ? self.arrowDirection : UIPopoverArrowDirectionAny;
  popoverPresentationController.passthroughViews = self.passthroughViews;
  popoverPresentationController.backgroundColor = self.backgroundColor;
  popoverPresentationController.popoverLayoutMargins = self.popoverLayoutMargins;
}

#pragma mark - Adaptive Presentation Controller Delegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
  return UIModalPresentationNone;
}

@end
