//
//  Request.h
//  Maps
//
//  Created by Nikita Rau on 7/15/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import <Parse/Parse.h>

@interface Request : PFObject<PFSubclassing>

+ (NSString *)parseClassName;
@property (nonatomic, strong) NSString *words;
@property (nonatomic, strong) NSNumber *duration;
@property (nonatomic, strong) PFGeoPoint *geopoint;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSNumber *radius;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;
@property (nonatomic, strong) NSDate *expDate;
@property (nonatomic, strong) NSMutableArray *fulfillers;
@property (nonatomic) BOOL isActive;

@end
