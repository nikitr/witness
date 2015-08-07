//
//  PhotoCell.h
//  Maps
//
//  Created by Sean Vasquez on 7/14/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface PhotoCell : UICollectionViewCell

@property (nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) PFFile *imageFile;
@property (nonatomic) PFObject *photoObject;
@property (nonatomic) IBOutlet UITextView *requestText;

@end
