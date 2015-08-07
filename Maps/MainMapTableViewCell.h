//
//  MainMapTableViewCell.h
//  Witness
//
//  Created by Sean Vasquez on 7/30/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapAnnotation.h"
#import "MGSwipeTableCell.h"

@interface MainMapTableViewCell : MGSwipeTableCell

@property (nonatomic) MapAnnotation *annotation;

@end
