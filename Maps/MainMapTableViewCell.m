//
//  MainMapTableViewCell.m
//  Witness
//
//  Created by Sean Vasquez on 7/30/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import "MainMapTableViewCell.h"
#import "Request.h"
#import "MGSwipeButton.h"

@interface MainMapTableViewCell ()

@property (nonatomic) IBOutlet UITextView *requestText;
@property (nonatomic) IBOutlet UILabel *timeRemaining;
@property (nonatomic) Request *request;

@property (nonatomic) NSCalendar *gregorianCalendar;
@property (nonatomic) NSDateFormatter *countDownDateFormatter;
@property (nonatomic) NSString *strTimeRemaining;

@end

@implementation MainMapTableViewCell

- (void)awakeFromNib {
    // Initialization code
  MGSwipeButton *button = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"aperture"] backgroundColor:[UIColor blackColor]];//colorWithRed:135/255. green:110/255. blue:159/255. alpha:1]];
  //[button setPadding:0];
  //[button setEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
  self.leftButtons = @[button];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAnnotation:(MapAnnotation *)annotation {
  _annotation = annotation;
  _request = annotation.request;
  _requestText.text = _request.words;
  
  NSTimeInterval timeRemainingDouble = _request.expDate.timeIntervalSinceNow;
  
  int timeRemainingInt = round(timeRemainingDouble);
  int days = (timeRemainingInt / (60 * 60 * 24));
  int hours  = (timeRemainingInt / (60 * 60)) % 24;
  int minutes = (timeRemainingInt / 60) % 60;
  NSString *timeRemainingString;
  if (days == 0 && hours == 0) {
    timeRemainingString = [NSString stringWithFormat:@"Expires in %d minutes", minutes];
  } else if (days == 0) {
    timeRemainingString = [NSString stringWithFormat:@"Expires in %d hours, %d minutes",
                                     hours, minutes];
  } else {
    timeRemainingString = [NSString stringWithFormat:@"Expires in %d days, %d hours, %d minutes",
                                     days, hours, minutes];
  }
  _timeRemaining.text = timeRemainingString;

}


@end
