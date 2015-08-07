//
//  User.h
//  Witness
//
//  Created by Nikita Rau on 7/30/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import <Parse/Parse.h>

@interface User : PFUser<PFSubclassing>

+ (NSString *)parseClassName;
@property (nonatomic) BOOL FBVerified;
@property (nonatomic, strong) NSMutableArray *photosTaken;
@property (nonatomic, strong) NSMutableArray *requestsFulfilled;

@end
