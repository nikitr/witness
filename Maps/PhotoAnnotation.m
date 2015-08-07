//
//  PhotoAnnotation.m
//  Maps
//
//  Created by Sean Vasquez on 7/17/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import "PhotoAnnotation.h"

@implementation PhotoAnnotation


- (id)initWithCoordinates:(CLLocationCoordinate2D)location title:(NSString *)title photo:(PFObject *)photo {
  self = [super initWithCoordinates:location title:title subtitle:nil];
  if (self) {
    self.photo = photo;
  }
  return self;
}

- (NSString *)title {
  if (self.containedAnnotations != 0) {
    return [NSString stringWithFormat:@"View %lu photos", 1 + self.containedAnnotations.count];
  } else {
    return self.photo[@"words"];
  }

}

@end
