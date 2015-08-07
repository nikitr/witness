//
//  InboxPopupVIew.m
//  Witness
//
//  Created by Sean Vasquez on 7/25/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import "InboxPopupView.h"

@interface InboxPopupView ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) NSMutableArray *customConstraints;

@end


@implementation InboxPopupView

@synthesize popupDelegate;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (void)commonInit
{
  _customConstraints = [[NSMutableArray alloc] init];
  
  UIView *view = nil;
  NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"InboxPopupView"
                                                   owner:self
                                                 options:nil];
  for (id object in objects) {
    if ([object isKindOfClass:[UIView class]]) {
      view = object;
      break;
    }
  }
  
  if (view != nil) {
    _containerView = view;
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.layer.cornerRadius = 15;
    [self addSubview:view];
    [self setNeedsUpdateConstraints];
  }
}

- (IBAction)dontSavePressed:(id)sender {
  self.dontSave.enabled = NO;
  [[self popupDelegate] dontSavePressed];
  
}

- (IBAction)savePressed:(id)sender {
  self.save.enabled = NO;
  [[self popupDelegate] savePressed];
}

- (void)updateConstraints
{
  [self removeConstraints:self.customConstraints];
  [self.customConstraints removeAllObjects];
  
  if (self.containerView != nil) {
    UIView *view = self.containerView;
    NSDictionary *views = NSDictionaryOfVariableBindings(view);
    
    [self.customConstraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:
      @"H:|[view]|" options:0 metrics:nil views:views]];
    [self.customConstraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:
      @"V:|[view]|" options:0 metrics:nil views:views]];
    
    [self addConstraints:self.customConstraints];
  }
  
  [super updateConstraints];
}

@end