//
//  MapAnnotation.h
//  Maps
//
//  Created by Sean Vasquez on 7/9/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Request.h"

@interface MapAnnotation : NSObject<MKAnnotation> {
    NSString *title;
    NSString *subtitle;
    NSString *note;
    CLLocationCoordinate2D coordinate;

}
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * subtitle;
@property (nonatomic, assign)CLLocationCoordinate2D coordinate;
@property (nonatomic) Request *request;

@end
