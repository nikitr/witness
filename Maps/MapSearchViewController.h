//
//  MapSearchViewController.h
//  Maps
//
//  Created by Sean Vasquez on 7/7/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapAnnotation.h"

@interface MapSearchViewController : UIViewController

@property (nonatomic) IBOutlet UILabel *instruction;
@property (nonatomic) IBOutlet UIButton *setRegion;
@property (nonatomic) IBOutlet UIButton *cancelPin;
@property (nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) UIView *circleView;
@property (nonatomic) NSString *durationText;
@property (nonatomic) NSString *detailsText;
@property (nonatomic) MapAnnotation *currentAnnotation;

- (void)setAnimationForInstruction;

@end
