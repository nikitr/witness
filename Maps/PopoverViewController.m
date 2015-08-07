//
//  ARSPopover.m
//  Popover
//
//  Created by Yaroslav Arsenkin on 27.05.15.
//  Copyright (c) 2015 Iaroslav Arsenkin. All rights reserved.
//

#import "PopoverViewController.h"
#import "MapSearchViewController.h"
#import <Parse/Parse.h>
#import "Request.h"

static const NSInteger charLimit = 100;

@interface PopoverViewController () <UIPopoverPresentationControllerDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic) IBOutlet UIButton *sendRequest;
@property (nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic) IBOutlet UILabel *charactersLeft;

@end

@implementation PopoverViewController

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
  
  self.detailsTextView.text = self.containingVC.detailsText;
  self.durationField.text = self.containingVC.durationText;
  self.isVisible = true;
  self.durationField.delegate = self;
  self.detailsTextView.delegate = self;
  self.detailsTextView.autocorrectionType = UITextAutocorrectionTypeNo;
  [self.durationField becomeFirstResponder];
  
  [self.durationField addTarget:self action:@selector(textFieldEditingChanged) forControlEvents:UIControlEventEditingChanged];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self.detailsTextView becomeFirstResponder];
  return NO;
}

- (void)textFieldEditingChanged {
  NSInteger charLimit = self.segmentedControl.selectedSegmentIndex? 1: 2;
  if (self.durationField.text.length > charLimit) {
    self.durationField.text = [self.durationField.text substringWithRange:NSMakeRange(0, charLimit)];
  }
}

- (void)textViewDidChange:(UITextView *)textView {
  if (self.detailsTextView.text.length > charLimit) {
    self.detailsTextView.text = [self.detailsTextView.text substringWithRange:NSMakeRange(0, charLimit)];
  }
  NSNumber *charsLeft = [NSNumber numberWithInteger: charLimit - self.detailsTextView.text.length];
  self.charactersLeft.text = [charsLeft stringValue];
}

- (IBAction)segmentSwitch:(id)sender {
  NSInteger maxChars;
  if (self.segmentedControl.selectedSegmentIndex == 0) {
    maxChars = MIN(self.durationField.text.length, 2);
    self.durationField.text = [self.durationField.text substringWithRange:NSMakeRange(0, maxChars)];
  }
  else {
    maxChars = MIN(self.durationField.text.length, 1);
    self.durationField.text = [self.durationField.text substringWithRange:NSMakeRange(0, maxChars)];
  }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  self.containingVC.durationText = self.durationField.text;
  
  //Testing
}

- (void)textViewDidEndEditing:(UITextView *)textView {
  self.containingVC.detailsText = self.detailsTextView.text;
}

- (IBAction)sendRequestPressed:(id)sender {
  self.sendRequest.enabled = NO;
  
  [self.containingVC.circleView setHidden: YES];
  self.containingVC.mapView.userInteractionEnabled = YES;
  [self.containingVC.setRegion setHidden:YES];
  [self.containingVC.cancelPin setHidden:YES];
  
  CGPoint circleEdgePoint = CGPointMake(self.containingVC.mapView.center.x + 110, self.containingVC.mapView.center.y);
  CLLocationCoordinate2D edge = [self.containingVC.mapView convertPoint: circleEdgePoint
                                                   toCoordinateFromView:self.containingVC.mapView];
  CLLocationCoordinate2D pinLocation = self.containingVC.currentAnnotation.coordinate;
  CLLocation *CLEdge = [[CLLocation alloc] initWithLatitude:edge.latitude longitude:edge.longitude];
  CLLocation *CLCenter = [[CLLocation alloc] initWithLatitude:self.containingVC.mapView.centerCoordinate.latitude
                                                    longitude:self.containingVC.mapView.centerCoordinate.longitude];
  float dist = [CLEdge distanceFromLocation:CLCenter];
  MKCircle *circle = [MKCircle circleWithCenterCoordinate:self.containingVC.mapView.centerCoordinate radius:dist];
  
  [self.containingVC.mapView addOverlay:circle];
  [self.durationField resignFirstResponder];
  [self.detailsTextView resignFirstResponder];
  self.containingVC.detailsText = nil;
  self.containingVC.durationText = nil;
  
  Request *request = [Request object];
  request.words = self.detailsTextView.text;
  request.user = [PFUser currentUser];
  
  NSInteger duration = [self.durationField.text integerValue];
  NSInteger durationInSeconds = self.segmentedControl.selectedSegmentIndex ? duration * 86400 : duration * 3600;
  request.duration = [NSNumber numberWithInteger:durationInSeconds];
  
  NSDateComponents *secComponent = [[NSDateComponents alloc] init];
  secComponent.second = durationInSeconds;
  NSCalendar *calendar = [NSCalendar currentCalendar];
  request.expDate = [calendar dateByAddingComponents:secComponent toDate:[NSDate date] options:0];
  
  request.radius = [NSNumber numberWithFloat:dist];
  request.geopoint = [PFGeoPoint geoPointWithLatitude:pinLocation.latitude longitude:pinLocation.longitude];
  request.photos = [[NSMutableArray alloc] init];
  request.isActive = @YES;
  [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    if (succeeded) {
      [self closePopover];
      [self.containingVC setAnimationForInstruction];
      self.containingVC.instruction.text = @"Request Sent!";
    } else {
      [self closePopover];
      UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                               message:@"Request Failed to Send"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
      //We add buttons to the alert controller by creating UIAlertActions:
      UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                         style:UIAlertActionStyleDefault
                                                       handler:nil];
      [alertController addAction:actionOk];
      [self.containingVC presentViewController:alertController animated:YES completion:nil];

    }
  }];
}


#pragma mark - Actions

- (void)closePopover {
  self.isVisible = false;
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
  self.isVisible = YES;
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)ppc {
  [self.containingVC setAnimationForInstruction];
  self.containingVC.instruction.text = @"Zoom to adjust radius";
  self.isVisible = NO;
}

#pragma mark - Adaptive Presentation Controller Delegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
  return UIModalPresentationNone;
}

@end
