//
//  RequestTableCell.m
//  Maps
//
//  Created by Nikita Rau on 7/13/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import "RequestTableCell.h"

@implementation RequestTableCell

@synthesize descriptionTextView = _descriptionTextView;
@synthesize dateLabel = _dateLabel;
@synthesize request = _request;

- (void)awakeFromNib {
  [super awakeFromNib];
  // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
  
  // Configure the view for the selected state
}

@end
