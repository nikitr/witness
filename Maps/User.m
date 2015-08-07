//
//  User.m
//  Witness
//
//  Created by Nikita Rau on 7/30/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import "User.h"

@implementation User

@dynamic FBVerified;
@dynamic photosTaken;
@dynamic requestsFulfilled;

+ (void)load {
  [self registerSubclass];
}

+ (NSString *)parseClassName {
  return [super parseClassName];
}

@end
