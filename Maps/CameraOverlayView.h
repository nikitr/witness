//
//  CameraOverlayView.h
//  Witness
//
//  Created by Nikita Rau on 7/22/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MainViewController;

@protocol ImageDelegate <NSObject>
@required
- (void)selectedPhoto:(UIImage *)photo;
- (void)savePhoto:(UIImage *)photo;
@end

@interface CameraOverlayView : UIView <UIImagePickerControllerDelegate>

@property (nonatomic) UIImagePickerController *pickerReference;
@property (nonatomic) MainViewController *mainVC;
@property (nonatomic, weak) id <ImageDelegate> imageDelegate;

@end
