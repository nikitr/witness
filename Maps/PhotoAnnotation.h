//
//  PhotoAnnotation.h
//  Maps
//
//  Created by Sean Vasquez on 7/17/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import "MSAnnotation.h"
#import "Request.h"

@interface PhotoAnnotation : MSAnnotation

@property (nonatomic) PFObject *photo;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location title:(NSString *)title photo:(PFObject *)photo;

@end
