//
//  MapSearchViewController.m
//  Maps
//
//  Created by Sean Vasquez on 7/7/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import "MapSearchViewController.h"
#import <MapKit/MapKit.h>
#import "MapTableView.h"
#import <AddressBookUI/AddressBookUI.h>
#import "ResultCell.h"
#import "MapAnnotation.h"
#import <Parse/Parse.h>
#import "PopoverViewController.h"

static const CLLocationDegrees setPinThresholdLongitudeDelta = 1.3;
static const CGFloat screenRadiusPointSize = 110;
static const CGFloat sectionHeaderHeight = 44;

@interface MapSearchViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) IBOutlet MapTableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *Done;
@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) PopoverViewController *pvc;

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocation *userLocation;

@property (nonatomic) NSMutableArray *places;
@property (nonatomic) MKCoordinateRegion defaultRegion;
@property (nonatomic) MKCoordinateRegion predictedRegion;
@property (nonatomic) CGFloat lastScale;

@end

/* fix table when 10+ results */

@implementation MapSearchViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
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
  
  self.instruction.text = @"Search or zoom to a desired location";
  [self hideDisplayButtons];
  
  [self addGestureRecognizerToMapView];

}

#pragma mark - MKMapView

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
  MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
  circleRenderer.fillColor = [UIColor colorWithRed:120/255. green:42/255. blue:118/255. alpha:1];
  circleRenderer.alpha = .2;
  return circleRenderer;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
  MKPinAnnotationView *view = nil;
  if(annotation != self.mapView.userLocation) {
    view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@""];
    view.pinColor = MKPinAnnotationColorRed;
    view.animatesDrop = YES;
  }
  return view;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
  [self setAnimationForInstruction];
  if (self.mapView.region.span.longitudeDelta > setPinThresholdLongitudeDelta && self.mapView.userInteractionEnabled) {
    self.instruction.text = @"Search or zoom to a desired location";
  }
  if (self.mapView.region.span.longitudeDelta <= setPinThresholdLongitudeDelta && self.mapView.userInteractionEnabled) {
    self.instruction.text = @"Hold to drop pin";
  }
}

- (void)addGestureRecognizerToMapView {
  UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(handlePinchGesture:)];
  UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(addPinToMap:)];
  lpgr.minimumPressDuration = 0.5;
  
  [self.mapView addGestureRecognizer:lpgr];
  [self.view addGestureRecognizer:pinch];
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer {
  if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
    self.lastScale = self.mapView.region.span.longitudeDelta;
  }
  if ([gestureRecognizer state] == UIGestureRecognizerStateBegan ||
      [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
    MKCoordinateRegion newRegion;
    newRegion.center = self.mapView.centerCoordinate;
    CLLocationDegrees delta = MIN(setPinThresholdLongitudeDelta, powf(gestureRecognizer.scale, -2) * self.lastScale);
    newRegion.span = MKCoordinateSpanMake(delta, delta);
    [self.mapView setRegion:newRegion];
  }
}

- (void)addPinToMap:(UIGestureRecognizer *)gestureRecognizer {
  if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
    return;
  }
  if (self.mapView.region.span.longitudeDelta < setPinThresholdLongitudeDelta) {
    [UIView animateWithDuration:.3 animations:^{
      self.circleView.alpha = 0;
    }];
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoord = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    MapAnnotation *toAdd = [[MapAnnotation alloc] init];
    toAdd.coordinate = touchMapCoord;
    [self.mapView addAnnotation:toAdd];
    self.currentAnnotation = toAdd;
    
    MKCoordinateRegion newRegion;
    newRegion.center =  touchMapCoord;
    CLLocationDegrees span = MIN(self.mapView.region.span.longitudeDelta, setPinThresholdLongitudeDelta);
    newRegion.span = MKCoordinateSpanMake(span, span);
    
    [self.searchBar endEditing:YES];
    [self.searchBar resignFirstResponder];
    [UIView animateWithDuration:.25 animations:^{
      [self.tableView setContentOffset:CGPointMake(0, 0)];
    }];
    
    [self setAnimationForInstruction];
    self.instruction.text = @"Zoom to adjust radius";
    
    [UIView animateWithDuration:.5
                     animations:^{
                       [self.mapView setRegion:newRegion animated:YES];
                     }
                     completion:^(BOOL finished){
                       CGPoint center = [self.mapView convertCoordinate:toAdd.coordinate toPointToView:self.mapView];
                       CGRect circleViewFrame = CGRectMake(center.x - screenRadiusPointSize,
                                                           center.y - screenRadiusPointSize,
                                                           screenRadiusPointSize * 2,
                                                           screenRadiusPointSize * 2);
                       self.circleView = [[UIView alloc] initWithFrame:circleViewFrame];
                       self.circleView.alpha = 0;
                       self.circleView.layer.cornerRadius = screenRadiusPointSize;

                       self.circleView.backgroundColor = [UIColor lightGrayColor];
                       self.circleView.userInteractionEnabled = NO;
                       [self.mapView addSubview:self.circleView];
                       [UIView animateWithDuration:.3 animations:^{
                         self.circleView.alpha = .3;
                       }];
                       [self showDisplayButtons];
                     }];
  }
}

- (IBAction)cancelPinPressed:(id)sender {
  [self hideDisplayButtons];
  [self setAnimationForInstruction];
  self.instruction.text = @"Hold to drop pin";
  self.detailsText = nil;
  self.durationText = nil;
}

- (IBAction)setRegionPressed:(id)sender {
  [self setAnimationForInstruction];
  self.instruction.text = @"Add additional specifications";
  
  PopoverViewController *popoverController = [[PopoverViewController alloc] init];
  popoverController.sourceView = self.mapView;
  popoverController.sourceRect = CGRectMake(self.mapView.center.x, self.mapView.center.y - 10, 0, 0);
  popoverController.contentSize = CGSizeMake(300, 210);
  popoverController.arrowDirection = UIPopoverArrowDirectionDown;
  popoverController.containingVC = self;
  self.pvc = popoverController;
  [self presentViewController:popoverController animated:YES completion:nil];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  self.userLocation = locations.lastObject;
  CLGeocoder *geocoder = [[CLGeocoder alloc] init];

  [geocoder reverseGeocodeLocation:self.userLocation completionHandler:^(NSArray *placemarks, NSError *error) {
    if (placemarks) {
      [self.locationManager stopUpdatingLocation];
    } else {
      NSLog(@"Geocode failed with error %@", error);
      NSLog(@"\nCurrent Location Not Detected\n");
    }
  }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  scrollView.bounces = (scrollView.contentOffset.y > 50);
}

#pragma mark - KeyboardNotifications

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
  if (!self.pvc.isVisible) {
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
  self.detailsText = nil;
  self.durationText = nil;
  if (self.tableView.contentOffset.y == 0) {
    [UIView animateWithDuration:1 animations:^{
      [self.mapView setRegion:self.defaultRegion animated:YES];
    }];
  }
  if (!self.circleView.isHidden) {
    [self hideDisplayButtons];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.places.count;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, sectionHeaderHeight)];
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

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)setAnimationForInstruction {
  CATransition *animation = [CATransition animation];
  animation.duration = .5;
  animation.type = kCATransitionFade;
  animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  animation.removedOnCompletion = NO;
  [self.instruction.layer addAnimation:animation forKey:@"changeTextTransition"];
}

- (void)hideDisplayButtons {
  [self.mapView removeAnnotation:self.currentAnnotation];
  self.mapView.userInteractionEnabled = YES;
  [UIView animateWithDuration:.25
                   animations:^{
                     self.circleView.alpha = 0;
                     self.setRegion.alpha = 0;
                     self.cancelPin.alpha = 0;
                   }
                   completion:^(BOOL finished) {
                     [self.circleView setHidden:YES];
                     [self.setRegion setHidden:YES];
                     [self.cancelPin setHidden:YES];
                   }];
}

- (void)showDisplayButtons {
  self.mapView.userInteractionEnabled = NO;
  self.cancelPin.alpha = 1;
  self.setRegion.alpha = 1;
  [self.circleView setHidden:NO];
  [self.setRegion setHidden:NO];
  [self.cancelPin setHidden:NO];
}

- (IBAction)donePressed:(id)sender {
  [self.searchBar resignFirstResponder];
  [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
