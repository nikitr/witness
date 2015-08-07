//
//  NewInboxTableViewController.m
//  Witness
//
//  Created by Sean Vasquez on 7/23/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import "InboxTableViewController.h"
#import "InboxTableViewCell.h"
#import <Parse/Parse.h>
#import "Request.h"
#import "MWPhotoBrowser.h"
#import "KLCPopup.h"
#import "InboxPopupView.h"

@interface InboxTableViewController () <MWPhotoBrowserDelegate, PopupDelegate>

@property (nonatomic) NSMutableArray *requestArray;

@property (nonatomic) NSIndexPath *selectedIndexPath;

@property (nonatomic) MWPhotoBrowser *photoBrowser;
@property (nonatomic) NSMutableArray *selections;

@property (nonatomic) KLCPopup *popup;

@end

@implementation InboxTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self fetchAndRefresh];
  
  UINib *feedCellNib = [UINib nibWithNibName:@"InboxTableViewCell" bundle:nil];
  [self.tableView registerNib:feedCellNib forCellReuseIdentifier:@"TableViewCell"];
  
  self.tableView.backgroundColor = [UIColor whiteColor];
  self.refreshControl = [[UIRefreshControl alloc] init];
  [self.refreshControl addTarget:self action:@selector(fetchAndRefresh) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - UITableViewDelegate / UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.requestArray.count;
}

- (InboxTableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  InboxTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell" forIndexPath:indexPath];
  if (cell == nil) {
    cell = [[InboxTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TableViewCell"];
  }
  if (cell.shadow == nil) {
    cell.shadow = [[UIView alloc] initWithFrame:CGRectMake(0, 102, self.tableView.bounds.size.width, 8)];
    CAGradientLayer *topShadow = [CAGradientLayer layer];
    topShadow.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, 8);
    topShadow.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0 alpha:0.4f] CGColor],
                                                 (id)[[UIColor colorWithWhite:0.0 alpha:0.1f] CGColor],
                                                 (id)[[UIColor colorWithWhite:0.0 alpha:0.0f] CGColor],
                                                 nil];
    topShadow.colors = [[topShadow.colors reverseObjectEnumerator] allObjects];
    [cell.shadow.layer insertSublayer:topShadow atIndex:0];
    [cell.contentView addSubview:cell.shadow];
  }
  cell.request = self.requestArray[indexPath.row];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  self.selectedIndexPath = indexPath;
  
  Request *request = self.requestArray[indexPath.row];

  NSArray *photos =  ((Request *)self.requestArray[indexPath.row]).photos;

  MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
  browser.displayNavArrows = YES;
  browser.displaySelectionButtons = request.isActive;
  browser.displayActionButton = YES;
  browser.alwaysShowControls = YES;
  browser.zoomPhotosToFill = YES;
  browser.enableGrid = YES;
  browser.startOnGrid = YES;
  browser.enableSwipeToDismiss = YES;
  browser.autoPlayOnAppear = NO;
  [browser setCurrentPhotoIndex:0];
  self.photoBrowser = browser;
  
  self.selections = [[NSMutableArray alloc] init];
  for (int i = 0; i < photos.count; i++) {
    [self.selections addObject:[NSNumber numberWithBool:NO]];
  }
  UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
  nc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
  [self presentViewController:nc animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 110;
}

# pragma mark - photoBrowser delegate

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {

  NSArray *photos = ((Request *)self.requestArray[self.selectedIndexPath.row]).photos;
  NSInteger count = 0;
  for (NSUInteger i = 0; i < photos.count; i++) {
    if ([self photoBrowser:photoBrowser isPhotoSelectedAtIndex:i]) {
      count += 1;
    }
  }
  if (count != 0) {
    InboxPopupView *contentView = [[InboxPopupView alloc] init];
    contentView.saveDetails.text = [NSString stringWithFormat:@"%zd saved photos, %zd deletions", count, photos.count - count];
    contentView.popupDelegate = self;
    contentView.frame = CGRectMake(0.0, 0.0, 300, 200);
    KLCPopup *popup = [KLCPopup popupWithContentView:contentView
                                            showType:KLCPopupShowTypeBounceIn
                                         dismissType:KLCPopupDismissTypeBounceOutToBottom
                                            maskType:KLCPopupMaskTypeDimmed
                            dismissOnBackgroundTouch:YES
                               dismissOnContentTouch:NO];
    self.popup = popup;
    [popup show];
  } else {
    [self dismissViewControllerAnimated:self.photoBrowser completion:nil];
  }
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
  NSArray *photos = ((Request *)self.requestArray[self.selectedIndexPath.row]).photos;
  return photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
  NSArray *photoObjects = ((Request *)self.requestArray[self.selectedIndexPath.row]).photos;
  if (index < photoObjects.count) {
    PFObject *photo = photoObjects[index];
    PFFile *file = photo[@"thumbnail"];
    return [MWPhoto photoWithURL:[NSURL URLWithString:file.url]];
  }
  return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
  NSArray *photoObjects = ((Request *)self.requestArray[self.selectedIndexPath.row]).photos;
  if (index < photoObjects.count) {
    PFObject *photo = photoObjects[index];
    PFFile *file = photo[@"thumbnail"]; //eventually use full resolution @"imageFile"
    return [MWPhoto photoWithURL:[NSURL URLWithString:file.url]];
  }
  return nil;
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
  if (self.selections.count != 0) {
    return [[self.selections objectAtIndex:index] boolValue];
  }
  return nil;
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
  [self.selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
}

#pragma mark - PopupDelegate

- (void)savePressed {
  Request *request = self.requestArray[self.selectedIndexPath.row];

  NSMutableArray *requestPhotos = request.photos;
  NSMutableIndexSet *indexesToDelete = [[NSMutableIndexSet alloc] init];
  for (NSUInteger i = 0; i < requestPhotos.count; i++) {
    if (![self photoBrowser:self.photoBrowser isPhotoSelectedAtIndex:i]) {
      [indexesToDelete addIndex:i];
    }
  }
  [request.photos removeObjectsAtIndexes:indexesToDelete];
  request[@"isActive"] = @NO;
  [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    [self dismissViewControllerAnimated:self.photoBrowser completion:nil];
    [self.popup dismiss:YES];
  }];
  
  InboxTableViewCell * cell = (InboxTableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
  cell.numPhotos.text = [NSString stringWithFormat:@"%lu approved photos", request.photos.count - indexesToDelete.count];
  cell.numPhotos.textColor = [UIColor blackColor];
  
  [self.tableView beginUpdates];
  [self.tableView reloadRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
  [self.tableView endUpdates];
}

- (void)dontSavePressed {
  [self dismissViewControllerAnimated:self.photoBrowser completion:nil];
  [self.popup dismiss:YES];
}

#pragma mark - convenience

- (void)fetchAndRefresh {
  PFQuery *query = [Request query];
  [query whereKeyExists:@"photos"];
  [query orderByDescending:@"createdAt"];
  [query includeKey:@"photos"];
  [query whereKey:@"user" equalTo:[PFUser currentUser]];
  
  [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (!error) {
      self.requestArray = [objects copy];
      [self.tableView reloadData];
    } else {
      NSLog(@"Error:%@ %@", error, [error userInfo]);
    }
    [self.refreshControl endRefreshing];
  }];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
