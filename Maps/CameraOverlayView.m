//
//  CameraOverlayView.m
//  Witness
//
//  Created by Nikita Rau on 7/22/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import "CameraOverlayView.h"
#import "MainViewController.h"

@interface CameraOverlayView () <UINavigationControllerDelegate>
@property (nonatomic) UIButton *flashButton;
@property (nonatomic) UIButton *shutterButton;
@property (nonatomic) UIButton *selfieButton;
@property (nonatomic) UIButton *backButton;
@property (nonatomic) UIButton *sendButton;
@property (nonatomic) UIButton *cancelButton;
@property (nonatomic) UIButton *saveButton;
@property (nonatomic) UIImageView *photoPreviewView;
@property (nonatomic) UIView *camRect;
@property (nonatomic) UIView *photoRect;
@end

@implementation CameraOverlayView

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    
    self.shutterButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.shutterButton addTarget:self
                           action:@selector(viewPhoto:)
            forControlEvents:UIControlEventTouchUpInside];
    [self.shutterButton setBackgroundImage:[UIImage imageNamed:@"Shutter"] forState:UIControlStateNormal];
    self.shutterButton.frame = CGRectMake(130, 560, 120, 120);
    [self addSubview:self.shutterButton];
    
    self.camRect = [[UIView alloc] initWithFrame:CGRectMake(-10, -5, 500, 60)];
    self.camRect.backgroundColor = [UIColor colorWithRed:135/255.0 green:110/255.0 blue:159/255.0 alpha:0.4];
    [self addSubview:self.camRect];
    self.camRect.hidden = NO;
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.backButton addTarget:self action:@selector(backSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
    self.backButton.frame = CGRectMake(0, 0, 75, 75);
    [self.camRect addSubview:self.backButton];
    
    self.flashButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.flashButton addTarget:self action:@selector(flashSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.flashButton setBackgroundImage:[UIImage imageNamed:@"Flash"] forState:UIControlStateNormal];
    self.flashButton.frame = CGRectMake(120, 0, 70, 70);
    [self.camRect addSubview:self.flashButton];
    
    self.selfieButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.selfieButton addTarget:self action:@selector(selfieSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.selfieButton setBackgroundImage:[UIImage imageNamed:@"Selfie"] forState:UIControlStateNormal];
    self.selfieButton.frame = CGRectMake(190, 0, 70, 70);
    [self.camRect addSubview:self.selfieButton];
    
    self.photoPreviewView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 55, self.bounds.size.width, self.bounds.size.height)];
    self.photoPreviewView.contentMode = UIViewContentModeScaleAspectFit;
    self.photoPreviewView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.photoPreviewView];
    self.photoPreviewView.hidden = YES;
    
    self.photoRect = [[UIView alloc] initWithFrame:CGRectMake(-10, -5, 500, 60)];
    self.photoRect.backgroundColor = [UIColor colorWithRed:135/255.0 green:110/255.0 blue:159/255.0 alpha:0.4];
    [self addSubview:self.photoRect];
    self.photoRect.hidden = YES;
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.cancelButton addTarget:self action:@selector(cancelSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"Cancel"] forState:UIControlStateNormal];
    self.cancelButton.frame = CGRectMake(0, 0, 70, 70);
    [self.photoRect addSubview:self.cancelButton];
    
    self.saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.saveButton addTarget:self action:@selector(saveSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.saveButton setBackgroundImage:[UIImage imageNamed:@"Save"] forState:UIControlStateNormal];
    self.saveButton.frame = CGRectMake(160, -5, 70, 70);
    [self.photoRect addSubview:self.saveButton];
    
    self.sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.sendButton addTarget:self action:@selector(sendSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendButton setBackgroundImage:[UIImage imageNamed:@"Send"] forState:UIControlStateNormal];
    self.sendButton.frame = CGRectMake(320, 0, 70, 70);
    [self.photoRect addSubview:self.sendButton];
  }
  return self;
}

- (IBAction)flashSelected:(id)sender {
  if (self.pickerReference.cameraFlashMode == UIImagePickerControllerCameraFlashModeOff) {
    [self.flashButton setBackgroundImage:[UIImage imageNamed:@"Flashon"] forState:UIControlStateNormal];
    self.pickerReference.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
  } else {
    [self.flashButton setBackgroundImage:[UIImage imageNamed:@"Flash"] forState:UIControlStateNormal];
    self.pickerReference.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
  }
}

- (IBAction)selfieSelected:(id)sender {
  if (self.pickerReference.cameraDevice == UIImagePickerControllerCameraDeviceRear) {
    self.pickerReference.cameraDevice = UIImagePickerControllerCameraDeviceFront;
  } else {
    self.pickerReference.cameraDevice = UIImagePickerControllerCameraDeviceRear;
  }
}

- (IBAction)backSelected:(id)sender {
  [self.mainVC.picker dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelSelected:(id)sender {
  self.photoPreviewView.hidden = YES;
  self.photoPreviewView.image = nil;
  self.photoRect.hidden = YES;
  self.camRect.hidden = NO;
  self.shutterButton.hidden = NO;
  
}

- (IBAction)sendSelected:(id)sender {
  [self.imageDelegate selectedPhoto:self.photoPreviewView.image];
  [self.pickerReference dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)saveSelected:(id)sender {
  [self.imageDelegate savePhoto:self.photoPreviewView.image];
}

- (IBAction)viewPhoto:(id)sender {
  [self.pickerReference takePicture];
  self.shutterButton.hidden = YES;
  self.camRect.hidden = YES;
  self.photoPreviewView.hidden = NO;
  self.photoRect.hidden = NO;
}

- (void)setPickerReference:(UIImagePickerController *)pickerReference {
  _pickerReference = pickerReference;
  _pickerReference.delegate = self;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  NSLog(@"hello");
  UIImage *photo = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
  self.photoPreviewView.image = photo;
  CGFloat scalingFactor = self.photoPreviewView.bounds.size.width/self.photoPreviewView.image.size.width;
  self.photoPreviewView.frame = CGRectMake(0, 55, self.bounds.size.width, self.photoPreviewView.image.size.height * scalingFactor);
  NSLog(@"image %@", self.photoPreviewView.image);
}

@end
