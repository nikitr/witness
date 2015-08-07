//
//  PhotoBrowserViewController.h
//  Maps
//
//  Created by Sean Vasquez on 7/15/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSMapClustering.h"
@class PhotoGridViewController;

@interface MapBrowserViewController : UIViewController

@property (nonatomic) IBOutlet UIButton *instruction;
@property (nonatomic) PhotoGridViewController *photoGrid;

@end
