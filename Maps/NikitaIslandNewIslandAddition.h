//
//  MainViewController.h
//  Maps
//
//  Created by Sean Vasquez on 7/13/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraOverlayView.h"
#import "RequestTableCell.h"
#import "Request.h"

@interface NikitaIslandNewIslandAddition : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSIndexPath *selectedIndexPath;
@property (nonatomic) Request *request;
@property (nonatomic) UIImagePickerController *picker;
@property (nonatomic) CameraOverlayView *overlay;

@end
