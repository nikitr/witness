//
//  MapTableView.m
//  Maps
//
//  Created by Sean Vasquez on 7/9/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import "MapTableView.h"

@implementation MapTableView


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  id hitView = [super hitTest:point withEvent:event];
  if (!self.offset) {
    self.offset = 250;
  }
  if (point.y < self.offset) {
    return nil;
  }
  return hitView;
}
@end
