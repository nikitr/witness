//
//  RegistrationViewController.m
//  Teleporter
//
//  Created by Nikita Rau on 7/8/15.
//
//

#import "RegistrationViewController.h"

#import <Parse/Parse.h>

@interface RegistrationViewController () <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIButton *createButton;

@end

@implementation RegistrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField == self.usernameField) {
    [self.passwordField becomeFirstResponder];
  }
  if (textField == self.passwordField) {
    [self.passwordField becomeFirstResponder];
  }
  if (textField == self.passwordAgainField) {
    [self.passwordAgainField resignFirstResponder];
    [self processFieldEntries];
  }
  
  return YES;
}

#pragma mark -
#pragma mark IBActions
- (IBAction)createPressed:(id)sender {
  [self dismissKeyboard];
  [self processFieldEntries];
}

#pragma mark -
#pragma mark Register

- (void)processFieldEntries {
  NSString *username = self.usernameField.text;
  NSString *password = self.passwordField.text;
  NSString *passwordAgain = self.passwordAgainField.text;
  NSString *errorText = @"Please ";
  NSString *usernameBlankText = @"enter a username";
  NSString *passwordBlankText = @"enter a password";
  NSString *joinText = @", and ";
  NSString *passwordMismatchText = @"enter the same password twice";
  
  BOOL textError = NO;
  
  if (username.length == 0 || password.length == 0 || passwordAgain == 0) {
    textError = YES;
    
    // Set up the keyboard for the first field missing input:
    if (passwordAgain.length == 0) {
      [self.passwordAgainField becomeFirstResponder];
    }
    if (password.length == 0) {
      [self.passwordField becomeFirstResponder];
    }
    if (username.length == 0) {
      errorText = [errorText stringByAppendingString:usernameBlankText];
    }
    
    if (password.length == 0 || passwordAgain.length == 0) {
      if (username.length == 0) {
        errorText = [errorText stringByAppendingString:joinText];
      }
      errorText = [errorText stringByAppendingString:passwordBlankText];
    }
  } else if ([password compare:passwordAgain] != NSOrderedSame) {
    // Check for equal password strings.
    textError = YES;
    errorText = [errorText stringByAppendingString:passwordMismatchText];
    [self.passwordField becomeFirstResponder];
  }
  
  if (textError) {
    // Show the user what's wrong
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorText message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
    return;
  }
  
  PFUser *user = [PFUser user];
  user.username = username;
  user.password = password;
  [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    if (error) {
      // Display an alert view to show the error message
      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error userInfo][@"error"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
      [alertView show];
      // Bring the keyboard back up, because they probably need to change something
      [self.usernameField becomeFirstResponder];
      return;
    }
    
    // Dismiss the view controller
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Call the delegate method that's notified when a sign up is successful
    [self.delegate registrationViewControllerDidRegister:self];
    NSLog(@"ok it works");
    
  }];
}

#pragma mark -
#pragma mark Keyboard

- (void)dismissKeyboard {
  [self.view endEditing:YES];
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
