//
//  InboxTableViewCell.h
//  Witness
//
//  Created by Sean Vasquez on 7/23/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Request.h"

@interface InboxTableViewCell : UITableViewCell

@property (nonatomic) IBOutlet UIImageView *thumbnail;
@property (nonatomic) IBOutlet UILabel *requestWords;
@property (nonatomic) IBOutlet UILabel *requestCreatedDate;
@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic) Request *request;
@property (nonatomic) IBOutlet UIView *view;
@property (nonatomic) UIView *shadow;
@property (nonatomic) IBOutlet UILabel *numPhotos;

@end
