//
//  RegistrationViewController.h
//  Teleporter
//
//  Created by Nikita Rau on 7/8/15.
//
//

#import <UIKit/UIKit.h>

@class RegistrationViewController;

@protocol RegistrationViewControllerDelegate <NSObject>
- (void)registrationViewControllerDidRegister:(RegistrationViewController *)controller;
@end

@interface RegistrationViewController : UIViewController

@property (nonatomic, weak) id<RegistrationViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITextField *usernameField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;
@property (nonatomic, strong) IBOutlet UITextField *passwordAgainField;


@end
