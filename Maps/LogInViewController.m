//
//  LogInViewController.m
//  Teleporter
//
//  Created by Nikita Rau on 7/8/15.
//
//

#import "LogInViewController.h"
#import "RegistrationViewController.h"

#import <Parse/Parse.h>

@interface LogInViewController ()
<UITextFieldDelegate>
@end

@implementation LogInViewController

- (void)processFieldEntries {
  // Get the username text, store it in the app delegate for now
  NSString *username = self.usernameField.text;
  NSString *password = self.passwordField.text;
  NSString *noUsernameText = @"username";
  NSString *noPasswordText = @"password";
  NSString *errorText = @"No";
  NSString *errorTextJoin = @" or ";
//  NSString *errorTextHandling = @" entered";
  BOOL textError = NO;
  
  // Messaging nil will return 0, so these checks implicitly check for nil text
  if (username.length == 0 || password.length == 0) {
    textError = YES;
    
    // Set up the keyboard for the first field missing input
    if (password.length == 0) {
      [self.passwordField becomeFirstResponder];
    }
    if (username.length == 0) {
      [self.usernameField becomeFirstResponder];
    }
  }
  
  if ([username length] == 0) {
    textError = YES;
    errorText = [errorText stringByAppendingString:noUsernameText];
  }
  
  if ([password length] == 0) {
    textError = YES;
    if ([username length] == 0) {
      errorText = [errorText stringByAppendingString:errorTextJoin];
    }
    errorText = [errorText stringByAppendingString:noPasswordText];
  }
  
  if (textError) {
    // show user what's wrong
    NSLog(@"%@", errorText);
    return;
  }
  
  // Log in a user
  [PFUser logInWithUsernameInBackground:username
                   password:password
                      block:
   ^(PFUser *user, NSError *error) {
     if (user) { //Login successful
       [self.delegate logInViewControllerDidLogIn:self];
     } else { //Login failed
       NSString *alertTitle = nil;
       if (error) {
         // Something else went wrong
         alertTitle = [error userInfo][@"error"];
       }
       UIAlertView *alertView =
       [[UIAlertView alloc] initWithTitle:alertTitle
                                  message:nil
                                 delegate:self
                        cancelButtonTitle:nil
                        otherButtonTitles:@"OK", nil];
       [alertView show];
       
       // Bring the keyboard back up, because they'll probably need to change something
       [self.usernameField becomeFirstResponder];
     }
   }];
  
}

- (void)presentRegistrationViewController {
  RegistrationViewController *viewController =
  [[RegistrationViewController alloc] initWithNibName:nil bundle:nil];
  
  //viewController.delegate = self;
  [self.navigationController presentViewController:viewController animated:YES completion:nil];
}

- (void)registrationViewControllerDidRegister:(RegistrationViewController *)controller {
  // Sign up successful
  [self.delegate logInViewControllerDidLogIn:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
