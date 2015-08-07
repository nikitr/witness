//
//  PhotoViewerViewController.m
//  Maps
//
//  Created by Sean Vasquez on 7/16/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import "PhotoGridViewController.h"
#import "MapBrowserViewController.h"
#import <Parse/Parse.h>
#import "MSAnnotation.h"
#import "PhotoCell.h"
#import "PagingPhotoLayout.h"
#import <MapKit/MapKit.h>
#import "MapAnnotation.h"

@interface PhotoGridViewController () <MKMapViewDelegate>

@property (nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) CLLocation *userLocation;
@property (nonatomic) MKMapCamera *camera;
@property (nonatomic) CGFloat lastScale;
@property (nonatomic) NSMutableArray *requestText;

@end

@implementation PhotoGridViewController

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (!self.photos) {
    self.photos = [[NSMutableArray alloc] init];
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
      if (!error) {
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
        self.mapView.centerCoordinate = loc.coordinate;
        self.userLocation = loc;
        PFQuery *query = [PFQuery queryWithClassName:@"PhotoObj"];
        [query whereKey:@"geopoint" nearGeoPoint:geoPoint withinMiles:100];
        [query orderByDescending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
          if (!error) {
            self.photos = [objects copy];
            MKMapCamera *camera = self.mapView.camera;
            camera.centerCoordinate = self.userLocation.coordinate;
            camera.altitude = 2000;
            camera.pitch = 45;
            self.camera = camera;
            
            [self.mapView removeAnnotations:self.mapView.annotations];
            MapAnnotation *toAdd = [[MapAnnotation alloc] init];
            toAdd.coordinate =  self.userLocation.coordinate;
            [self.mapView addAnnotation:toAdd];

            [self.carousel reloadData];
          } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
          }
        }];
      }
    }];
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  _carousel.type = iCarouselTypeRotary;
  _carousel.pagingEnabled = YES;

  UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(handlePinchGesture:)];
  [self.view addGestureRecognizer:pinch];
  
  self.mapView.delegate = self;
  self.mapView.userInteractionEnabled = NO;
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer {
  if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
    self.lastScale = self.mapView.camera.altitude;
  }
  if ([gestureRecognizer state] == UIGestureRecognizerStateBegan ||
      [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
    self.mapView.camera.centerCoordinate = self.mapView.centerCoordinate;
    CLLocationDegrees delta = MIN(25000,powf(gestureRecognizer.scale, -2) * self.lastScale);
    self.mapView.camera.altitude = delta;
  }
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
  return self.photos.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
  PhotoCell *cellView = [[PhotoCell alloc] init];

  cellView = [[[NSBundle mainBundle] loadNibNamed:@"PhotoCell" owner:self options:nil] lastObject];
  PFObject *photoObj = self.photos[index];
  cellView.photoObject = photoObj;
  cellView.requestText.text = self.requestText[index];
  
  return cellView;
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
  if ((long)carousel.currentItemIndex < 0) {
    return;
  }
  PFObject *photoObj = self.photos[(long)carousel.currentItemIndex];
  PFGeoPoint *geoPoint = photoObj[@"geopoint"];

  //CLLocationCoordinate2D currentCamCoord = self.camera.centerCoordinate;
  //CLLocation *currentCamLocation = [[CLLocation alloc] initWithLatitude:currentCamCoord.latitude
  //                                                          longitude:currentCamCoord.longitude];
  //CLLocationCoordinate2D eyeloc = CLLocationCoordinate2DMake((geoPoint.latitude*9 + currentCamCoord.latitude)/10,
  // (geoPoint.longitude*9 + currentCamCoord.longitude)/10);
  
  //CLLocationDistance distanceToMove = [currentCamLocation distanceFromLocation:nextLocation];
 
  CLLocation *nextLocation  = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
  
  if (self.mapView.annotations.count == 0) {
    [self.mapView removeAnnotations:self.mapView.annotations];
    MapAnnotation *toAdd = [[MapAnnotation alloc] init];
    toAdd.coordinate =  nextLocation.coordinate;
  }
  
  MapAnnotation *annotation = self.mapView.annotations.firstObject;
  [UIView animateWithDuration:1.0 animations:^(void){
    [annotation setCoordinate:nextLocation.coordinate];
  }];
  
  MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:nextLocation.coordinate
                                                   fromEyeCoordinate:nextLocation.coordinate
                                                         eyeAltitude:2000];
  camera.pitch = 45;
  [self.mapView setCamera:camera animated:YES];
}

- (CGFloat)carousel:(__unused iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {

  switch (option)
  {
    case iCarouselOptionWrap:
    {
      return YES;
    }
    case iCarouselOptionSpacing:
    {
      //add a bit of spacing between the item views
      return value;
    }
    case iCarouselOptionFadeMax:
    {
      if (self.carousel.type == iCarouselTypeCustom)
      {
        //set opacity based on distance from camera
        return 0.0f;
      }
      return value;
    }
    case iCarouselOptionShowBackfaces:
    case iCarouselOptionRadius:
    case iCarouselOptionAngle:
    case iCarouselOptionArc:
    case iCarouselOptionTilt:
    case iCarouselOptionCount:
    case iCarouselOptionFadeMin:
    case iCarouselOptionFadeMinAlpha:
    case iCarouselOptionFadeRange:
    case iCarouselOptionOffsetMultiplier:
    case iCarouselOptionVisibleItems:
    {
      return value;
    }
  }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  UINavigationController *navController = segue.destinationViewController;
  MapBrowserViewController *mapBrowser = (MapBrowserViewController *)navController.topViewController;
  mapBrowser.photoGrid = self;
}

@end
