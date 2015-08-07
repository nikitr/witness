//
//  RequestTableCell.h
//  Maps
//
//  Created by Nikita Rau on 7/13/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Request.h"

@interface RequestTableCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic) Request *request;

@end
