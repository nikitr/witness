//
//  Request.m
//  Maps
//
//  Created by Nikita Rau on 7/15/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>
#import "Request.h"

@implementation Request

@dynamic words;
@dynamic duration;
@dynamic geopoint;
@dynamic photos;
@dynamic radius;
@dynamic user;
@dynamic createdAt;
@dynamic updatedAt;
@dynamic expDate;
@dynamic fulfillers;
@dynamic isActive;

+ (void)load {
  [self registerSubclass];
}

+ (NSString *)parseClassName {
  return @"Request";
}

@end
