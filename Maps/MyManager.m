//
//  SharedDateFormatter.m
//  Witness
//
//  Created by Sean Vasquez on 7/27/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import "MyManager.h"

@implementation MyManager

@synthesize dateFormatter;

+ (id)sharedManager {
  static MyManager *sharedMyManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedMyManager = [[self alloc] init];
  });
  return sharedMyManager;
}

- (id)init {
  if (self = [super init]) {
    self.dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
  }
  return self;
}






@end
