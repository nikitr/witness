//
//  InboxTableViewCell.m
//  Witness
//
//  Created by Sean Vasquez on 7/23/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import "InboxTableViewCell.h"
#import "MyManager.h"
#import <MapKit/MapKit.h>


@interface InboxSnapshotManager : NSObject
+ (id)sharedInboxSnapshotManager;
- (void)getSnapshotForRequest:(Request *)request withCompletion:(void (^)(Request *request, UIImage *snapshot))completion;
@end

@interface InboxSnapshotManager ()
// Request.objectId => UIImage
@property (nonatomic, strong) NSCache *snapshotCache;
@end

@implementation InboxSnapshotManager

+ (id)sharedInboxSnapshotManager {
  static InboxSnapshotManager *sharedManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedManager = [[self alloc] init];
  });
  return sharedManager;
}

- (id)init {
  if (self = [super init]) {
    self.snapshotCache = [[NSCache alloc] init];
  }
  return self;
}


- (void)getSnapshotForRequest:(Request *)request withCompletion:(void (^)(Request *request, UIImage *snapshot))completion {
  UIImage *cachedImage = [self.snapshotCache objectForKey:request.objectId];
  if (cachedImage) {
    completion(request, cachedImage);
  } else {
    PFGeoPoint *geoPoint = request.geopoint;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
    
    MKCoordinateRegion mapRegion;
    mapRegion.center = location.coordinate;
    mapRegion.span = MKCoordinateSpanMake(.5,.5);
    
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.region = mapRegion;
    options.size = CGSizeMake(630, 110);
    options.showsPointsOfInterest = NO;
    
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    
    __weak typeof(self)weakSelf = self;
    [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
      if (!error) {
        [weakSelf.snapshotCache setObject:snapshot.image forKey:request.objectId];
        completion(request, snapshot.image);
    }
  }];
  }
}

@end


@interface InboxTableViewCell ()

@property (nonatomic, strong) NSString *photoObjectID;
@property (nonatomic) IBOutlet UIImageView *mapSnapshot;
@property (nonatomic) MKMapSnapshotter *snapshotter;
@property (nonatomic) IBOutlet UIView *fadeView;
@property (nonatomic) UIImageView *pinImageView;

@end

@implementation InboxTableViewCell

- (void)awakeFromNib {
  [self addLinearGradientToView:self.fadeView withColor:[UIColor whiteColor] transparentToOpaque:YES];
  
  
  UIImage *annotationImage = [UIImage imageNamed:@"pin.png"];
  CGRect imageFrame = CGRectMake(self.fadeView.frame.size.width - 315 - 20,
                                55 - 40, 40, 40);
  UIImageView *annotationView = [[UIImageView alloc] initWithFrame:imageFrame];
  annotationView.alpha = .75;
  self.pinImageView = annotationView;
  self.pinImageView.image = annotationImage;
  [self.fadeView addSubview:self.pinImageView];
  self.pinImageView.hidden = YES;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  [self.snapshotter cancel];
  self.mapSnapshot.image = nil;
  self.pinImageView.hidden = YES;
}

- (void)addLinearGradientToView:(UIView *)theView withColor:(UIColor *)theColor
            transparentToOpaque:(BOOL)transparentToOpaque {
  CAGradientLayer *gradient = [CAGradientLayer layer];
  CGRect gradientFrame = theView.frame;
  gradientFrame.origin.x = 0;
  gradientFrame.origin.y = 0;
  gradient.frame = gradientFrame;
  
  NSArray *colors = [NSArray arrayWithObjects:
                     (id)[theColor CGColor],
                     (id)[[theColor colorWithAlphaComponent:0.9f] CGColor],
                     (id)[[theColor colorWithAlphaComponent:0.8f] CGColor],
                     (id)[[theColor colorWithAlphaComponent:0.6f] CGColor],
                     (id)[[theColor colorWithAlphaComponent:0.3f] CGColor],
                     (id)[[theColor colorWithAlphaComponent:0.0f] CGColor],
                     nil];
  
  if(transparentToOpaque) {
    colors = [[colors reverseObjectEnumerator] allObjects];
  }
  gradient.startPoint = CGPointMake(0, .5);
  gradient.endPoint = CGPointMake(1, .5);
  gradient.colors = colors;
  [theView.layer insertSublayer:gradient atIndex:0];
}

- (void)setRequest:(Request *)request {
  _request = request;
  
  [self updateNumPhotosLabel];
  
  __weak typeof(self)weakSelf = self;
  [[InboxSnapshotManager sharedInboxSnapshotManager] getSnapshotForRequest:request withCompletion:^(Request *request, UIImage *snapshot) {
    if (weakSelf.request == request) {
      weakSelf.mapSnapshot.image = snapshot;
      weakSelf.pinImageView.hidden = NO;
    }
  }];
  
  MyManager *sharedManager = [MyManager sharedManager];
  NSDateFormatter *dateFormatter = sharedManager.dateFormatter;
  _requestWords.text = request.words;
  _requestCreatedDate.text = [@"Requested: " stringByAppendingString:[dateFormatter stringFromDate:request.createdAt]];
}

- (void)updateNumPhotosLabel {
  NSInteger numPhotos = self.request.photos.count;
  if (!self.request.isActive) {
    self.numPhotos.text = [NSString stringWithFormat:@"%lu approved photos", numPhotos];
    self.numPhotos.textColor = [UIColor blackColor];
  } else {
    self.numPhotos.text = [NSString stringWithFormat:@"%lu pending photos", numPhotos];
    self.numPhotos.textColor = [UIColor colorWithRed:190/255. green:30/255. blue:39/255. alpha:1];
  }
  if (numPhotos == 1) {
    self.numPhotos.text = [self.numPhotos.text substringToIndex:self.numPhotos.text.length - 1];
  }
}

@end
