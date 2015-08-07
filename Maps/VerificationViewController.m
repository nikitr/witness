//
//  VerificationViewController.m
//  Maps
//
//  Created by Sean Vasquez on 7/15/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import "VerificationViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Parse/Parse.h>

@interface VerificationViewController () <FBSDKLoginButtonDelegate>
@property (weak, nonatomic) IBOutlet FBSDKLoginButton *loginButton;
@end

@implementation VerificationViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  if ([FBSDKAccessToken currentAccessToken]) {
    // User is logged in, do work such as go to next view controller.
  }
  self.loginButton.delegate = self;
}

- (void) loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
  
}

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
              error:(NSError *)error {
  PFUser *currentUser = [PFUser currentUser];
  if (result.grantedPermissions.count > 0) {
    currentUser[@"FBVerified"] = @YES;
    NSLog(@"%lu", result.grantedPermissions.count);
  } else {
    currentUser[@"FBVerified"] = @NO;
  }
  [currentUser saveInBackground];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end