//
//  SettingsTableViewController.m
//  Witness
//
//  Created by Nikita Rau on 8/2/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import "SettingsViewController.h"
#import "PhotoCell.h"

@interface SettingsViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) NSMutableArray *options;
@property (nonatomic) NSMutableArray *photosTaken;
@property (nonatomic) NSMutableArray *photoObjects;

@end

@implementation SettingsViewController

- (void) dealloc {
  _carousel.delegate = nil;
  _carousel.dataSource = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
  User *user = (User *)[PFUser currentUser];
  self.options = [NSMutableArray array];
  [self.options addObject:@"Create an account"];
  [self.options addObject:@"Get verified"];
  [self.options addObject:@"Only receive photos from verifed users"];
  self.photosTaken = [NSMutableArray array];
  self.photosTaken = user.photosTaken; //returns photo object ids
  _carousel.type = iCarouselTypeRotary;
  _carousel.pagingEnabled = YES;
}

#pragma mark - iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
  return self.photosTaken.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
  PhotoCell *cellView = [[PhotoCell alloc] init];
  
  cellView = [[[NSBundle mainBundle] loadNibNamed:@"PhotoCell" owner:self options:nil] lastObject];

  for (int i = 0; i < self.photosTaken.count; i++) {
    NSString *photoID = self.photosTaken[i];
    PFQuery *userPhotosQuery = [PFQuery queryWithClassName:@"PhotoObj"];
    [userPhotosQuery getObjectInBackgroundWithId:photoID block:^(PFObject *object, NSError *error) {
      if (!error) {
        cellView.photoObject = object;
      }
    }];
  }
  
  return cellView;
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
  if ((long)carousel.currentItemIndex < 0) {
    return;
  }
//  PFObject *photoObj = self.photosTaken[(long)carousel.currentItemIndex];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.options count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *settingsTableIdentiifer = @"SettingsTableIdentifier";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:settingsTableIdentiifer];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:settingsTableIdentiifer];
    if (indexPath.row == 2) {
      UISwitch *mySwitch  = [[UISwitch alloc] initWithFrame:CGRectZero];
      cell.accessoryView = mySwitch;
      [mySwitch setOn:NO animated:NO];
//      [mySwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];

    }
  }
  [[cell textLabel] setFont:[UIFont fontWithName:@"Heiti TC" size: 16.5]];
  cell.textLabel.text = [self.options objectAtIndex:indexPath.row];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  if (indexPath.row == 0) {
    [self performSegueWithIdentifier:@"accountSegue" sender:self];
  } else if (indexPath.row == 1) {
    [self performSegueWithIdentifier:@"verifySegue" sender:self];
  } else if (indexPath.row == 2) {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  }
 }

@end
