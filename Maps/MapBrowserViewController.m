//
//  PhotoBrowserViewController.m
//  Maps
//
//  Created by Sean Vasquez on 7/15/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import "MapBrowserViewController.h"
#import <MapKit/MapKit.h>
#import "MapTableView.h"
#import "ResultCell.h"
#import <Parse/Parse.h>
#import "Request.h"
#import "MSMapClustering.h"
#import "MSMapClusteringDelegate.h"
#import "MSAnnotation.h"
#import "PhotoAnnotation.h"
#import "PhotoGridViewController.h"

static const CGFloat sectionHeaderHeight = 44;

@interface MapBrowserViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic) IBOutlet MapTableView *tableView;

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) MSMapClusteringDelegate *mapViewDelegate;
@property (nonatomic) MKCoordinateRegion defaultRegion;

@property (nonatomic) UISearchBar *searchBar;

@property (nonatomic) IBOutlet MSMapClustering *mapView;
@property (nonatomic) MSMapClusteringDelegate *delegate;

@property (nonatomic) NSMutableArray *photosInRect;
@property (nonatomic) NSMutableArray *photos;
@property (nonatomic) NSMutableArray *places;

@end

@implementation MapBrowserViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self automaticallyAdjustsScrollViewInsets];
  
  self.mapViewDelegate = [[MSMapClusteringDelegate alloc] initWithMapView:self.mapView];
  self.mapView.delegate = self;
  self.defaultRegion = self.mapView.region;
  
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self;
  if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
    [self.locationManager requestWhenInUseAuthorization];
  }
  [self.locationManager startUpdatingLocation];
  
  CGFloat width = self.tableView.frame.size.width;
  CGRect headerFrame = CGRectMake(0, 0, width, self.mapView.frame.size.height - self.tableView.frame.origin.y - sectionHeaderHeight);
  UITableViewHeaderFooterView *header = [[UITableViewHeaderFooterView alloc] initWithFrame:headerFrame];
  
  self.tableView.tableHeaderView = header;
  self.tableView.backgroundColor = [UIColor clearColor];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.sectionHeaderHeight = sectionHeaderHeight;
  self.tableView.offset = self.mapView.frame.size.height - self.tableView.frame.origin.y - sectionHeaderHeight;
  UINib *nib = [UINib nibWithNibName:@"ResultCell" bundle:nil];
  [self.tableView registerNib:nib forCellReuseIdentifier:@"resultCell"];
  
  self.searchBar = [[UISearchBar alloc] init];
  self.searchBar.delegate = self;
  self.searchBar.placeholder = @"Search Locations";
  self.searchBar.translucent = NO;
  self.searchBar.keyboardType = UIKeyboardTypeASCIICapable;
  self.searchBar.barTintColor = [UIColor colorWithRed:135/255. green:110/255. blue:159/255. alpha:1];
  [self registerForKeyboardNotifications];
  
  [self.instruction setTitle:@"Search or zoom to a desired location" forState:UIControlStateNormal];
  [self.instruction setEnabled:NO];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  PFQuery *query = [PFQuery queryWithClassName:@"PhotoObj"];
  [query whereKeyExists:@"geopoint"];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (!error) {
      NSMutableArray *annotations = [[NSMutableArray alloc] init];
      for (PFObject *object in objects) {
        PFGeoPoint *geopoint = object[@"geopoint"];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(geopoint.latitude, geopoint.longitude);
        PhotoAnnotation *annotation = [[PhotoAnnotation alloc] initWithCoordinates:coord title:@"" photo:object];
        [annotations addObject:annotation];
      }
      [self.mapView addMSAnnotations:annotations];
    } else {
      NSLog(@"Error:%@ %@", error, [error userInfo]);
    }
  }];
}

- (MKMapView *)_allAnnotationsMapView {
  return self.mapViewDelegate._allAnnotationsMapView;
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)aMapView regionDidChangeAnimated:(BOOL)animated {
  [self.mapViewDelegate mapView:aMapView regionDidChangeAnimated:animated];
  [self setAnimationForInstruction];
  if (self.mapView.region.span.longitudeDelta > 2.5) {
    [self.instruction setTitle:@"Search or zoom to a desired location" forState:UIControlStateNormal];
    [self.instruction setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.instruction setEnabled:NO];
  }
  if (self.mapView.region.span.longitudeDelta <= 2.5  && self.mapView.userInteractionEnabled) {
    [self.instruction setTitle:@"Press here to view photos in this region" forState:UIControlStateNormal];
    [self.instruction setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.instruction setEnabled:YES];
  }
}

- (void)mapView:(MKMapView *)aMapView didAddAnnotationViews:(NSArray *)views {
  for (id<MKAnnotation> annotation in aMapView.selectedAnnotations) {
    [aMapView deselectAnnotation:annotation animated:YES];
  }
  [self.mapViewDelegate mapView:aMapView didAddAnnotationViews:views];
}

- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)annotation {
  MKAnnotationView *annotationView = [self.mapViewDelegate mapView:aMapView viewForAnnotation:annotation];
  if (annotation != self.mapView.userLocation) {
    annotationView.leftCalloutAccessoryView  = [UIButton buttonWithType:UIButtonTypeInfoDark];
  }
  return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
  
  PhotoAnnotation *annotation = (PhotoAnnotation *)view.annotation;
  NSMutableArray *photos = [[NSMutableArray alloc] init];
  [photos addObject:annotation.photo];
  
  CLLocationDistance maxDistance = -1 * CLLocationDistanceMax;
  CLLocation *annotationLocation = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude
                                                              longitude:annotation.coordinate.longitude];
  
  for (PhotoAnnotation *photoAnnotation in annotation.containedAnnotations) {
    [photos addObject:photoAnnotation.photo];
    
    CLLocation *containtedLocation = [[CLLocation alloc] initWithLatitude:photoAnnotation.coordinate.latitude
                                                                longitude:photoAnnotation.coordinate.longitude];
    maxDistance = MAX(maxDistance, [containtedLocation distanceFromLocation:annotationLocation]);
  }
  self.photoGrid.photos = photos;
  [self.photoGrid.carousel reloadData];
  
  CLGeocoder *geocoder = [[CLGeocoder alloc]init];
  [geocoder reverseGeocodeLocation:annotationLocation completionHandler:^(NSArray *placemarks, NSError *error) {
    CLPlacemark *placemark = [placemarks objectAtIndex:0];
    NSString *centerAddress = [NSString stringWithFormat:@"%@, %@", placemark.subAdministrativeArea, placemark.country];
    CLLocationDegrees radius = MAX(2, 0.000621371 * maxDistance);
    NSString *collectionTitle = [NSString stringWithFormat:@"Viewing Photos within %.0f miles of \n %@", radius, centerAddress];
    self.photoGrid.collectionTitle.text = collectionTitle;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
  }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  CLLocation *userLocation = locations.lastObject;
  CLGeocoder *geocoder = [[CLGeocoder alloc] init];
  [geocoder reverseGeocodeLocation:userLocation completionHandler:^(NSArray *placemarks, NSError *error) {
    if (placemarks) {
      [self.locationManager stopUpdatingLocation];
    } else {
      NSLog(@"Geocode failed with error %@", error);
      NSLog(@"\nCurrent Location Not Detected\n");
    }
  }];
  return;
}

#pragma mark - User events

- (IBAction)donePressed:(id)sender {
  [self.searchBar resignFirstResponder];
  [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)instructionPressed:(id)sender {
  MKMapRect visible = self.mapView.visibleMapRect;
  MKMapPoint SWPoint = MKMapPointMake(visible.origin.x, visible.origin.y + visible.size.height);
  CLLocationCoordinate2D SWCoord = MKCoordinateForMapPoint(SWPoint);
  MKMapPoint NEPoint = MKMapPointMake(visible.origin.x + visible.size.width, visible.origin.y);
  CLLocationCoordinate2D NECoord = MKCoordinateForMapPoint(NEPoint);
  
  CLGeocoder *geocoder = [[CLGeocoder alloc]init];
  
  CLLocationCoordinate2D mapCenter2D = self.mapView.centerCoordinate;
  CLLocation *mapCenter = [[CLLocation alloc] initWithLatitude:mapCenter2D.latitude longitude:mapCenter2D.longitude];
  
  [geocoder reverseGeocodeLocation: mapCenter completionHandler:^(NSArray *placemarks, NSError *error) {
    CLPlacemark *placemark = [placemarks objectAtIndex:0];
    NSString *centerAddress = [NSString stringWithFormat:@"%@, %@", placemark.subAdministrativeArea, placemark.country];
    CLLocationDegrees radius = MAX(2, 69 * self.mapView.region.span.latitudeDelta / 2);
    NSString *collectionTitle = [NSString stringWithFormat:@"Viewing Photos within %.0f miles of \n %@", radius, centerAddress];
    self.photoGrid.collectionTitle.text = collectionTitle;
  }];
  
  PFGeoPoint *SWCorner = [PFGeoPoint geoPointWithLatitude:SWCoord.latitude longitude:SWCoord.longitude];
  PFGeoPoint *NECorner = [PFGeoPoint geoPointWithLatitude:NECoord.latitude longitude:NECoord.longitude];
  self.photoGrid.photos = [[NSMutableArray alloc] init];
  PFQuery *query = [PFQuery queryWithClassName:@"PhotoObj"];
  [query whereKey:@"geopoint" withinGeoBoxFromSouthwest:SWCorner toNortheast:NECorner];
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (!error) {
      for (PFObject *object in objects) {
        [self.photoGrid.photos addObject:object];
      }
      [self.photoGrid.carousel reloadData];
    } else {
      NSLog(@"Error:%@ %@", error, [error userInfo]);
    }
    [self.searchBar resignFirstResponder];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
  }];
}

#pragma mark - Keyboard Events

- (void)registerForKeyboardNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillBeHidden:)
                                               name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
  NSDictionary* info = [aNotification userInfo];
  
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:[info[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
  [UIView setAnimationCurve:[info[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
  [UIView setAnimationBeginsFromCurrentState:YES];
  
  [self.searchBar setShowsCancelButton:NO animated:YES];
  self.tableView.scrollEnabled = NO;
  [self.tableView setContentOffset:CGPointMake(0, 0)];
  
  [UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification*)aNotification {
  NSDictionary* info = [aNotification userInfo];
  CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
  self.searchBar.placeholder = @"Search Locations";
  
  [UIView beginAnimations:nil context:NULL];
  
  [UIView setAnimationDuration:[info[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
  [UIView setAnimationCurve:[info[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
  [UIView setAnimationBeginsFromCurrentState:YES];
  
  [self.searchBar setShowsCancelButton:YES animated:YES];
  [self.tableView setContentOffset:CGPointMake(0, keyboardSize.height)];
  self.tableView.scrollEnabled = NO;
  
  [UIView commitAnimations];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  scrollView.bounces = (scrollView.contentOffset.y > 50);
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  [self.searchBar endEditing:YES];
  [self.searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  CLGeocoder *geocoder = [[CLGeocoder alloc] init];
  self.places = [[NSMutableArray alloc] init];
  [geocoder geocodeAddressString:self.searchBar.text completionHandler:^(NSArray *placemarks, NSError *error) {
    if([placemarks count]) {
      for (CLPlacemark *placemark in placemarks) {
        [self.places addObject:placemark];
      }
    } else {
      NSLog(@"location error");
    }
    [self.tableView reloadData];
    [UIView animateWithDuration:.25 animations:^{
      if (self.places.count) {
        // NSIndexPath *myIP = [NSIndexPath indexPathForRow:0 inSection:0];
        //[self.tableView scrollToRowAtIndexPath:myIP atScrollPosition:UITableViewScrollPositionTop animated:NO];
      } else {
        self.searchBar.text = @"";
        self.searchBar.placeholder = @"No Results Found, Search Again";
      }
      [self.tableView setContentOffset:CGPointMake(0, 44 * self.places.count)];
    }];
    [self.searchBar endEditing:YES];
    [self.searchBar resignFirstResponder];
  }];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
  if (self.tableView.contentOffset.y == 0) {
    [UIView animateWithDuration:1 animations:^{
      [self.mapView setRegion:self.defaultRegion animated:YES];
    }];
    self.mapView.userInteractionEnabled = YES;
  }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  ResultCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"resultCell" forIndexPath:indexPath];
  if (indexPath.row < 15 && indexPath.row < self.places.count) {
    CLPlacemark *place = (CLPlacemark *)self.places[indexPath.row];
    NSDictionary *data = place.addressDictionary;
    NSArray *resultArray = (NSArray *)data[@"FormattedAddressLines"];
    NSString *resultString = @"";
    for (int i = 1; i < resultArray.count; i++) {
      resultString = [resultString stringByAppendingString:resultArray[i]];
      resultString = [resultString stringByAppendingString:@"  "];
    }
    cell.name.text = place.name;
    cell.subName.text = resultString;
  }
  return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.places.count;
}

#pragma mark - UITableViewDelegate

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
  self.searchBar.frame = view.frame;
  [view addSubview:self.searchBar];
  return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  CLPlacemark *place = (CLPlacemark *)self.places[indexPath.row];
  CLCircularRegion *pmCircularRegion = (CLCircularRegion *)place.region;
  MKCoordinateRegion regionZoomed = MKCoordinateRegionMakeWithDistance(pmCircularRegion.center,
                                                                       pmCircularRegion.radius,
                                                                       pmCircularRegion.radius);
  MKCoordinateRegion regionCentered = MKCoordinateRegionMake(pmCircularRegion.center,
                                                             self.mapView.region.span);
  [UIView animateWithDuration:.25 animations:^{
    [self.tableView setContentOffset:CGPointMake(0, 0)];
  }];
  [UIView animateWithDuration:.5
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     [self.mapView setRegion:regionCentered animated:YES];
                   }
                   completion:^(BOOL finished) {
                     [UIView animateWithDuration:1.5 animations:^{
                       [self.mapView setRegion:regionZoomed animated:YES];
                     }];
                   }];
}

#pragma mark - convenience methods and other stuff

- (void)setAnimationForInstruction {
  CATransition *animation = [CATransition animation];
  animation.duration = .5;
  animation.type = kCATransitionFade;
  animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  animation.removedOnCompletion = NO;
  [self.instruction.layer addAnimation:animation forKey:@"changeTextTransition"];
}

@end