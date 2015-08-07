//
//  PhotoCell.m
//  Maps
//
//  Created by Sean Vasquez on 7/14/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import "PhotoCell.h"
#import <Parse/Parse.h>

@implementation PhotoCell

- (void)viewDidLoad {
  
}

- (void)awakeFromNib {
  [super awakeFromNib];
  [self addLinearGradientToView:self.imageView withColor:[UIColor blackColor] transparentToOpaque:NO];
  
}

- (void)addLinearGradientToView:(UIView *)theView withColor:(UIColor *)theColor
            transparentToOpaque:(BOOL)transparentToOpaque {
  CAGradientLayer *gradient = [CAGradientLayer layer];
  CGRect gradientFrame = theView.frame;
  gradientFrame.origin.x = 0;
  gradientFrame.origin.y = 0;
  gradient.frame = gradientFrame;
  
  NSArray *colors = [NSArray arrayWithObjects:
                     (id)[[theColor colorWithAlphaComponent:0.7f] CGColor],
                     (id)[[theColor colorWithAlphaComponent:0.5f] CGColor],
                     (id)[[theColor colorWithAlphaComponent:0.3f] CGColor],
                     (id)[[theColor colorWithAlphaComponent:0.1f] CGColor],
                     (id)[[theColor colorWithAlphaComponent:0.0f] CGColor],
                     (id)[[theColor colorWithAlphaComponent:0.0f] CGColor],
                     (id)[[theColor colorWithAlphaComponent:0.0f] CGColor],
                     (id)[[theColor colorWithAlphaComponent:0.0f] CGColor],
                     (id)[[theColor colorWithAlphaComponent:0.0f] CGColor],
                     (id)[[theColor colorWithAlphaComponent:0.0f] CGColor],
                     nil];
  
  if(transparentToOpaque) {
    colors = [[colors reverseObjectEnumerator] allObjects];
  }
  gradient.colors = colors;
  [theView.layer insertSublayer:gradient atIndex:0];
}

- (void)prepareForReuse {
  [super prepareForReuse];
  [self.imageFile cancel];
  self.imageView.image = nil;
  self.requestText.text = nil;
  self.layer.masksToBounds = YES;
  self.clipsToBounds = YES;
}

- (void)setPhotoObject:(PFObject *)photoObject {
  
  _imageFile = photoObject[@"thumbnail"];
  
  self.imageView.image = nil;
  __weak typeof(self)weakSelf = self;
  [_imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
    if (!error && weakSelf) {
      UIImage *image = [UIImage imageWithData:imageData];
      weakSelf.imageView.image = image;
    }
  }];
  self.requestText.text = nil;
  PFQuery *query = [PFQuery queryWithClassName:@"Request"];
  [query getObjectInBackgroundWithId:photoObject[@"request"] block:^(PFObject *object, NSError *error) {
    if (!error && weakSelf) {
      weakSelf.requestText.text = object[@"words"];
    } else {
      weakSelf.requestText.text = @"";
    }
  }];
}

@end