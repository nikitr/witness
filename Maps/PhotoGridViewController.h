//
//  PhotoViewerViewController.h
//  Maps
//
//  Created by Sean Vasquez on 7/16/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapBrowserViewController.h"
#import "iCarousel.h"

@interface PhotoGridViewController : UIViewController <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic) NSMutableArray *photos;
@property (nonatomic) IBOutlet UILabel *collectionTitle;
@property (nonatomic, strong) IBOutlet iCarousel *carousel;

@end
