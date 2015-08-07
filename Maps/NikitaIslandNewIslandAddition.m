//
//  MainViewController.m
//  Maps
//
//  Created by Sean Vasquez on 7/13/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import <ImageIO/CGImageSource.h>
#import <ImageIO/CGImageProperties.h>
#import "NikitaIslandNewIslandAddition.h"
#import "ProfilePopupViewController.h"
#import "RequestTableCell.h"
#import "User.h"

@interface NikitaIslandNewIslandAddition ()<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, ImageDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *profile;
@property (nonatomic) NSMutableArray *requests;
@property (nonatomic) BOOL isRefreshing;
@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) NSCalendar *gregorianCalendar;
@property (nonatomic) NSDateFormatter *countDownDateFormatter;
@property (nonatomic) NSString *strTimeRemaining;

@end

@implementation NikitaIslandNewIslandAddition

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(refreshData) userInfo:nil repeats:YES];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  //self.gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  self.countDownDateFormatter = [[NSDateFormatter alloc] init];
  self.requests = [NSMutableArray array];
  
  // Initialize the refresh control
  self.refreshControl = [[UIRefreshControl alloc] init];
  self.refreshControl.backgroundColor = [UIColor whiteColor];
  self.refreshControl.tintColor = [UIColor purpleColor];
  [self.refreshControl addTarget:self
                     action:@selector(refresh)
           forControlEvents:UIControlEventValueChanged];
  [self.tableView addSubview:self.refreshControl];
  //self.refreshControl.backgroundColor = [UIColor colorWithRed:247/255.0 green:243/255.0 blue:232/255.0 alpha:1.0];
  //self.tableView.backgroundColor = [UIColor colorWithRed:247/255.0 green:243/255.0 blue:232/255.0 alpha:1.0];
}

- (void)refresh {
  self.isRefreshing = YES;
  [self refreshData];
}

- (void)refreshData {
  // Fill cells with data for specific location
  [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
    if (!error) {
      NSMutableArray *queriedRequests = [NSMutableArray array];
      PFQuery *locationBasedQuery = [Request query];
      // Ensure each user has a constant radius and only gets requests within that radius
      [locationBasedQuery whereKey:@"geopoint" nearGeoPoint:geoPoint withinKilometers:10000];
//      [locationBasedQuery whereKey:@"user" notEqualTo:[PFUser currentUser]]; //if you created this request, don't show it
      //if you fulfilled this request, don't show it
      CLLocation *userLocation = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
      [locationBasedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
          for (Request *object in objects) {
            NSTimeInterval diff = [object.expDate timeIntervalSinceDate:[NSDate date]];
            if (diff > 0) { //if todays date has not surpassed expiration date
              if (object.isActive) {
                CLLocation *requestLocation = [[CLLocation alloc] initWithLatitude:object.geopoint.latitude longitude:object.geopoint.longitude];
                CLLocationDistance distance = [userLocation distanceFromLocation:requestLocation];
                NSNumber *numDistance = [NSNumber numberWithDouble:distance];
                NSNumber *objRadius = object.radius;
                if ([objRadius doubleValue] > [numDistance doubleValue]) {
                  [queriedRequests addObject:object];
                }
                if (self.isRefreshing) {
                  [self.refreshControl endRefreshing];
                }
                self.isRefreshing = NO;
              }
            }
          }
          self.requests = queriedRequests;
          [self reloadData];
        } else {
          NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
      }];
    }
  }];
}

- (void)reloadData {
  [self.tableView reloadData];
  if (self.refreshControl) {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor purpleColor] forKey:NSForegroundColorAttributeName];
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
    self.refreshControl.attributedTitle = attributedTitle;
    self.isRefreshing = NO;
  }
}

- (IBAction)profilePressed:(id)sender {
  ProfilePopupViewController *popoverController = [[ProfilePopupViewController alloc] init];
  popoverController.sourceView = self.view;
  popoverController.sourceRect = CGRectMake(20,55,0,0);
  popoverController.contentSize = CGSizeMake(187, 187);
  popoverController.arrowDirection = UIPopoverArrowDirectionUp;
  [self presentViewController:popoverController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.requests.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *requestTableIdentifier = @"RequestTableCell";
  RequestTableCell *cell = (RequestTableCell *)[tableView dequeueReusableCellWithIdentifier:requestTableIdentifier];
  
  if (cell == nil) {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RequestTableCell" owner:self options:nil];
    cell = [nib objectAtIndex:0];
  }
  cell.request = self.requests[indexPath.row];
  Request *cellRequest = cell.request;

  cell.descriptionTextView.text = cellRequest.words;
  
  [self.countDownDateFormatter setDateFormat:@"hh:mm:ss"];
  NSDate *now = [NSDate date];
  //NSDateComponents *comp = [self.gregorianCalendar components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:now toDate:cellRequest.expDate options:0];
  if ([now compare:cellRequest.expDate] == NSOrderedAscending) {
    //self.strTimeRemaining = [[NSString alloc] initWithFormat:@"%02ld:%02ld:%02ld", (long)[comp hour], (long)[comp minute], (long)[comp second]];
  }
  cell.dateLabel.text = [NSString stringWithFormat: @"%@", self.strTimeRemaining];
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 78;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  self.selectedIndexPath = indexPath;
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  self.request = self.requests[indexPath.row];
  CGRect screenRect = [[UIScreen mainScreen]bounds];
  self.picker =
  [[UIImagePickerController alloc] init];
  self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
  self.picker.showsCameraControls = NO;
  self.picker.navigationBarHidden = YES;
  self.picker.cameraViewTransform =
  CGAffineTransformScale(self.picker.cameraViewTransform,
                         2,
                         2); //change to fix image warp-lens way more zoomed than it should be in view but not in photo preview
  
  self.overlay = [[CameraOverlayView alloc]
                  initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
  self.overlay.pickerReference = self.picker;
  //self.overlay.mainVC = self;
  self.overlay.imageDelegate = self;
  self.picker.cameraOverlayView = self.overlay;
  
  [self presentViewController:self.picker animated:YES completion:NULL];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
  if (!error) {

  }
}

#pragma mark - Image Delegate
- (void)selectedPhoto:(UIImage *)photo {
  // Send photo to database
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
  photoObj[@"request"] = self.request.objectId;
  photoObj[@"isApproved"] = @NO;
  [photoObj saveInBackground];
  
  [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
    if (!error) {
      photoObj[@"geopoint"] = geoPoint; // future-get user location instead from within photo
      [photoObj saveInBackground];
    }
  }];
  
  [_request.photos addObject:photoObj];
  NSMutableArray *completers = [[NSMutableArray alloc] init];
  [completers addObject:[PFUser currentUser]];
  _request.fulfillers = completers;
  [_request saveInBackground];
  
  User *user = (User *)[PFUser currentUser];
  [user.photosTaken addObject:photoObj];
  [user.requestsFulfilled addObject:_request];
  [user saveInBackground];
}

- (void)savePhoto:(UIImage *)photo {
  UIImageWriteToSavedPhotosAlbum(photo, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

@end
