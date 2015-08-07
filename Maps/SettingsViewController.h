//
//  SettingsTableViewController.h
//  Witness
//
//  Created by Nikita Rau on 8/2/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "User.h"

@interface SettingsViewController : UIViewController<iCarouselDataSource, iCarouselDelegate>

@property (nonatomic) User *user;
@property (nonatomic, strong) IBOutlet iCarousel *carousel;

@end
