//
//  ProfileSettingsViewController.m
//  Maps
//
//  Created by Sean Vasquez on 7/14/15.
//  Copyright (c) 2015 Sean Vasquez. All rights reserved.
//

#import "ProfileSettingsViewController.h"
#import "Parse/Parse.h"

@interface ProfileSettingsViewController ()

@property (nonatomic) IBOutlet UITextField *username;
@property (nonatomic) IBOutlet UITextField *password;
@property (nonatomic) IBOutlet UITextField *email;
@property (nonatomic) IBOutlet UITextField *rePassword;
@property (nonatomic) IBOutlet UIButton *createAccount;

@end

@implementation ProfileSettingsViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}
- (IBAction)createAccountPressed:(id)sender {
  
  PFQuery *nameQuery = [PFUser query];
  [nameQuery whereKey:@"username" equalTo:self.username.text];
  [nameQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (!error) {
      if (objects.count != 0) {
        NSLog(@"username already taken");
      } else {
        if (!([self.password.text isEqualToString:self.rePassword.text])) {
          NSLog(@"passwords dont match");
        } else if (self.password.text.length < 7){
          NSLog(@"passwords must be at least 7 characters");

        } else { //everything is okay
          
          PFUser *currentUser = [PFUser currentUser];
          
          currentUser[@"username"] = self.username.text;
          
          currentUser[@"password"] = self.password.text;
          currentUser[@"email"] = self.email.text;
          NSLog(@"verification email sent");
          [currentUser saveInBackground];
        }
      }
      
    } else {
      // Log details of the failure

      NSLog(@"Error: %@ %@", error, [error userInfo]);
    }
  }];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end
