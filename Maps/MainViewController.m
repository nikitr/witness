//
//  MainMapViewController.m
//  Witness
//
//  Created by Sean Vasquez on 7/30/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import "MainViewController.h"
#import <MapKit/MapKit.h>
#import "MainMapTableViewCell.h"
#import <Parse/Parse.h>
#import "Request.h"
#import "MapAnnotation.h"
#import "MGSwipeTableCell.h"
#import "CameraOverlayView.h"
#import "User.h"

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate, ImageDelegate, MGSwipeTableCellDelegate>

@property (nonatomic) MKMapView *mapView;

@property (nonatomic) CLLocation *userLocation;
@property (nonatomic) NSMutableArray *annotations;

@property (nonatomic) MKPolyline *path;
@property (nonatomic) MKDirections *directions;

@property (nonatomic) NSIndexPath *selectedIndex;

@property (nonatomic) CameraOverlayView *overlay;

@property (nonatomic) BOOL notFirstLoad;

@end

@implementation MainViewController

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self initiateRequest];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.mapView = [[MKMapView alloc] init];
  self.mapView.rotateEnabled = NO;
  self.mapView.showsUserLocation = YES;
  self.mapView.delegate = self;
  self.mapView.zoomEnabled = YES;
  
  self.tableView.sectionHeaderHeight = 250;
  
  self.refreshControl = [[UIRefreshControl alloc] init];
  [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
  
  
  [self refreshData];
  
  UINib *nib = [UINib nibWithNibName:@"MainMapTableViewCell" bundle:nil];
  [self.tableView registerNib:nib forCellReuseIdentifier:@"MainMapTableViewCell"];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.annotations.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 250)];
  view.backgroundColor = [UIColor colorWithRed:135/255. green:110/255. blue:159/255. alpha:1];
  
  view.layer.shadowOpacity = .5;
  view.layer.masksToBounds = NO;
  view.layer.shadowRadius = 5;
  view.layer.shadowOffset = CGSizeMake(0,-3);
  
  self.mapView.frame = view.frame;
  [view addSubview:self.mapView];
  
  return view;
}

- (MainMapTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  MainMapTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MainMapTableViewCell" forIndexPath:indexPath];
  cell.annotation = self.annotations[indexPath.row];
  cell.delegate = self;
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 75;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (self.selectedIndex) {
    MainMapTableViewCell *cell = (MainMapTableViewCell *)[tableView cellForRowAtIndexPath:self.selectedIndex];
    [cell hideSwipeAnimated:YES];
  }
  
  self.selectedIndex = indexPath;
  
  MainMapTableViewCell *cell = (MainMapTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
  
  [cell showSwipe:MGSwipeDirectionLeftToRight animated:YES];
  
  MapAnnotation *annotation = cell.annotation;
  
  if (self.directions.calculating) {
    [self.directions cancel];
  }
  
  MKDirectionsRequest *directionRequest = [MKDirectionsRequest new];
  [directionRequest setSource:[MKMapItem mapItemForCurrentLocation]];
  MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:annotation.coordinate
                                                            addressDictionary:nil];
  [directionRequest setDestination:[[MKMapItem alloc] initWithPlacemark:destinationPlacemark]];
  directionRequest.transportType = MKDirectionsTransportTypeWalking;
  
  self.directions = [[MKDirections alloc] initWithRequest:directionRequest];
  [self.directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
    if (!error) {
      MKRoute *route = [response.routes firstObject];
      MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:route.polyline];
      
      [self.mapView removeOverlays:self.mapView.overlays];
      
      CLLocationCoordinate2D sourceCoordinates[2];
      sourceCoordinates[0] = self.mapView.userLocation.coordinate;
      MKMapPoint source = route.polyline.points[0];
      CLLocationCoordinate2D sourceCoordinate = MKCoordinateForMapPoint(source);
      sourceCoordinates[1] = sourceCoordinate;
      MKPolyline *sourcePolyline = [MKPolyline polylineWithCoordinates:sourceCoordinates count:2];
      
      CLLocationCoordinate2D destCoordinates[2];
      destCoordinates[0] = annotation.coordinate;
      MKMapPoint dest = route.polyline.points[route.polyline.pointCount - 1];
      CLLocationCoordinate2D destCoordinate = MKCoordinateForMapPoint(dest);
      destCoordinates[1] = destCoordinate;
      MKPolyline *destPolyline = [MKPolyline polylineWithCoordinates:destCoordinates count:2];
      
      [self.mapView addOverlay:sourcePolyline];
      [self.mapView addOverlay:destPolyline];
      [self.mapView addOverlay:renderer.polyline];
      [self centerMapToPolyline:route.polyline];
    }
  }];
}

#pragma mark - MGSWipeTableCell

- (BOOL)swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion {
  CGRect screenRect = [[UIScreen mainScreen]bounds];
  self.picker = [[UIImagePickerController alloc] init];
  self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
  self.picker.showsCameraControls = NO;
  self.picker.navigationBarHidden = YES;
  
  self.picker.cameraViewTransform = CGAffineTransformTranslate(self.picker.cameraViewTransform, 0, 55);
  
  self.overlay = [[CameraOverlayView alloc]
                  initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
  self.overlay.pickerReference = self.picker;
  self.overlay.mainVC = self;
  self.overlay.imageDelegate = self;
  self.picker.cameraOverlayView = self.overlay;
  
  [self presentViewController:self.picker animated:YES completion:NULL];
  
  return YES;
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
  NSUInteger index = 0;
  for (NSUInteger i = 0; i < self.annotations.count; i++) {
    if (self.annotations[i] == view.annotation) {
      index = i;
    }
  }
  NSUInteger indexes[2];
  indexes[0] = 0;
  indexes[1] = index;
  //self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
  NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
  
  
  
  [UIView animateWithDuration:.25 animations:^{
    if (indexPath.row <= 1) {
      [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }else if (indexPath.row >= self.annotations.count - 2){
      [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }else {
      
      self.tableView.contentOffset = CGPointMake(0, indexPath.row * 75 - 115);
    }
  }
                   completion:^(BOOL finished) {
                     [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
                   }];
  [self.mapView deselectAnnotation:view.annotation animated:NO];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay  {
  MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
  renderer.strokeColor = [UIColor colorWithRed:135/255. green:110/255. blue:159/255. alpha:1];
  renderer.lineWidth = 5;
  renderer.alpha = .8;
  return renderer;
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id<MKAnnotation>)anno {
  if (anno == self.mapView.userLocation) {
    MapAnnotation *toAdd = [[MapAnnotation alloc] init];
    toAdd.coordinate =  self.userLocation.coordinate;
    MKPinAnnotationView *view = [[MKPinAnnotationView alloc] initWithAnnotation:toAdd reuseIdentifier:nil];
    view.pinColor = MKPinAnnotationColorPurple;
    view.animatesDrop = YES;
    view.layer.zPosition = 1000;
    return view;
  } else {
    MKPinAnnotationView *view = (MKPinAnnotationView *)[map dequeueReusableAnnotationViewWithIdentifier:@"pin"];
    if (!view) {
      MKPinAnnotationView *view = [[MKPinAnnotationView alloc] initWithAnnotation:anno reuseIdentifier:@"pin"];
      view.animatesDrop = YES;
    }
    view.animatesDrop = YES;
    return view;
  }
}

#pragma mark - ImageDelegate

- (void)selectedPhoto:(UIImage *)photo {
  
  NSIndexPath *indexPath = self.selectedIndex;
  MapAnnotation *annotation = self.annotations[indexPath.row];
  Request *request = annotation.request;
  
  NSData *imageData = UIImageJPEGRepresentation(photo, 1);
  PFFile *imageFile = [PFFile fileWithName:@"image.jpg" data:imageData];
  [imageFile saveInBackground];
  
  NSData *thumbnailData = UIImageJPEGRepresentation(photo, .5);
  PFFile *thumbnailFile = [PFFile fileWithName:@"smallimage.jpg" data:thumbnailData];
  [thumbnailFile saveInBackground];
  
  PFObject *photoObj = [PFObject objectWithClassName:@"PhotoObj"];
  photoObj[@"imageFile"] = imageFile;
  photoObj[@"thumbnail"] = thumbnailFile;
  photoObj[@"user"] = [PFUser currentUser];
  photoObj[@"request"] = request.objectId;
  photoObj[@"isApproved"] = @NO;
  [photoObj saveInBackground];
  
  [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
    if (!error) {
      photoObj[@"geopoint"] = geoPoint; // future-get user location instead from within photo
      [photoObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        User *user = (User *)[PFUser currentUser];
        NSMutableArray *userPhotos = [[NSMutableArray alloc] init];
        [userPhotos addObject:photoObj.objectId];
        [userPhotos addObjectsFromArray:user.photosTaken];
        user.photosTaken = userPhotos;

        NSMutableArray *userRequests = [[NSMutableArray alloc] init];
        [userRequests addObject:request.objectId];
        [userRequests addObjectsFromArray:user.requestsFulfilled];
        user.requestsFulfilled = userRequests;

        [user saveInBackground];
      }];
    }
  }];
  
  [request.photos addObject:photoObj];
  NSMutableArray *completers = [[NSMutableArray alloc] init];
  [completers addObject:[PFUser currentUser]];
  [completers addObjectsFromArray:request.photos];
  request.fulfillers = completers;
  [request saveInBackground];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
  if (!error) {
  }
}

- (void)savePhoto:(UIImage *)photo {
  UIImageWriteToSavedPhotosAlbum(photo, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

#pragma mark - convenience methods

- (void)centerMapToPolyline:(MKPolyline *)polyline {
  MKMapRect boundingRect = polyline.boundingMapRect;
  MKMapSize boundingSize = boundingRect.size;
  MKMapPoint boundingOrigin = boundingRect.origin;
  MKMapPoint boundingCenter = MKMapPointMake(boundingOrigin.x + boundingSize.width / 2.0,
                                             boundingOrigin.y + boundingSize.height / 2.0);
  
  MKMapSize bufferedSize = MKMapSizeMake(boundingSize.width * 2, boundingSize.height * 2);
  MKMapPoint bufferedOrigin = MKMapPointMake(boundingCenter.x - bufferedSize.width / 2.0,
                                             boundingCenter.y - bufferedSize.height / 2.0);
  
  MKMapPoint source = MKMapPointForCoordinate(self.userLocation.coordinate);
  MKMapPoint dest = MKMapPointForCoordinate(((MapAnnotation *)self.annotations[self.selectedIndex.row]).coordinate);
  
  MKMapRect mapRect = MKMapRectMake(MIN(bufferedOrigin.x, MIN(source.x, dest.x) - 15),
                                    MIN(bufferedOrigin.y, MIN(source.y, dest.y) - 15),
                                    MAX(bufferedSize.width, fabs(source.x - dest.x) * 2),
                                    MAX(bufferedSize.height, fabs(source.y - dest.y) * 2));
  
  [UIView animateWithDuration:1.5 animations:^{
    [self.mapView setVisibleMapRect:mapRect];
  }];
}

- (CLLocation *)locationFromGeoPoint:(PFGeoPoint *)gp {
  CLLocation *location = [[CLLocation alloc] initWithLatitude:gp.latitude longitude:gp.longitude];
  return location;
}

- (void)addAnnotationsFromRequests:(NSArray *)requests {
  NSMutableArray *annotations = [[NSMutableArray alloc] init];
  for (Request *request in requests) {
    CLLocation *requestLocation = [self locationFromGeoPoint:request.geopoint];
    MapAnnotation *toAdd = [[MapAnnotation alloc] init];
    toAdd.coordinate =  requestLocation.coordinate;
    toAdd.request = request;
    [annotations addObject:toAdd];
  }
  self.annotations = annotations;
  [self.mapView addAnnotations:annotations];
}

- (void)refreshData {
  [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
    if (!error) {
      
      self.userLocation = [self locationFromGeoPoint:geoPoint];
      
      if (!self.notFirstLoad) {
        self.mapView.camera.centerCoordinate = self.userLocation.coordinate;
        self.mapView.camera.altitude = 25000;
        self.notFirstLoad = YES;
      }
      
      PFQuery *query = [Request query];
      query.limit = 100;
      [query whereKey:@"geopoint" nearGeoPoint:geoPoint withinKilometers:33.8062];
      
      [query whereKey:@"user" notEqualTo:[PFUser currentUser]]; //if you created this request, don't show it
      
      User *currUser = (User *)[PFUser currentUser];
      for (int i = 0; i < currUser.requestsFulfilled.count; i++) {
        [query whereKey:@"objectId" notEqualTo:currUser.requestsFulfilled[i]]; //if you fulfilled this request, don't show it
      }
      
      [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
          NSMutableArray *requests = [NSMutableArray array];
          
          for (Request *object in objects) {
            //NSTimeInterval timeRemaining = [object.expDate timeIntervalSinceDate:[NSDate date]];
            //if (timeRemaining > 0 && object.isActive) {
            CLLocation *requestLocation = [self locationFromGeoPoint:object.geopoint];
            
            CLLocationDistance distance = [self.userLocation distanceFromLocation:requestLocation];
            CLLocationDistance requestRadius = [object.radius doubleValue];
            
            if (requestRadius > distance) {
              [requests addObject:object];
            }
            //}
          }
          [self.mapView removeAnnotations:self.mapView.annotations];
          [self addAnnotationsFromRequests:requests];
          [self.tableView reloadData];
          [self.refreshControl endRefreshing];
        } else {
          NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
      }];
    }
  }];
}

- (void)initiateRequest {
  MKDirectionsRequest *directionRequest = [MKDirectionsRequest new];
  [directionRequest setSource:[MKMapItem mapItemForCurrentLocation]];
  MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:self.userLocation.coordinate
                                                            addressDictionary:nil];
  [directionRequest setDestination:[[MKMapItem alloc] initWithPlacemark:destinationPlacemark]];
  directionRequest.transportType = MKDirectionsTransportTypeWalking;
  
  self.directions = [[MKDirections alloc] initWithRequest:directionRequest];
  [self.directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
  }];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
