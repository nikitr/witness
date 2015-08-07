//
//  LogInViewController.h
//  Teleporter
//
//  Created by Nikita Rau on 7/8/15.
//
//

#import <UIKit/UIKit.h>

@class LogInViewController;

@protocol LogInViewControllerDelegate <NSObject>
- (void)logInViewControllerDidLogIn:(LogInViewController *)controller;
@end

@interface LogInViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) id<LogInViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITextField *usernameField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;


@end
